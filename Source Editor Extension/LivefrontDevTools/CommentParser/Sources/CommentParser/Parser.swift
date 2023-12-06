/// A state machine which parses lines and generates output.
public class Parser {

    // MARK: Private Properties

    /// A buffer of unmodified lines from the current comment block. This is used to revert to the
    /// original unformatted comment block in the event that the current comment block is not
    /// targeted for formatting.
    private var commentBlockBuffer = [String]()

    /// The tokens for the discussion section of the current comment block.
    private var discussionTokens = [String]()

    /// The padding guild is used to determine how much whitespace to add at the beginning of each
    /// line of a comment block. If the guide begins with whitespace, that same amount of whitespace
    /// will be added to each line. Usually the padding guide for a comment block is determined by
    /// the non-comment source code line immediately following the comment block. If no subsequent
    /// line exists, or if the following line is empty, a fallback padding guide is used. The
    /// fallback guide uses the padding from the first line of the comment block.
    private var fallbackPaddingGuide: String?

    /// The tokens for the general description section of the current comment block.
    private var generalTokens = [String]()

    /// `true` iff the current comment block should be formatted.
    private var isTargetedComment = false

    /// The current parsing mode. The mode indicates the type of data being parsed in the recently
    /// supplied lines.
    private var mode: ParsingMode = .nonComment

    /// The final output text.
    private var output = [String]()

    /// The parameters parsed from the current comment block.
    private var parameters = [Parameter]()

    /// The return value parsed from the current comment block.
    private var returnValue: Return?
    
    /// The zero-indexed line ranges targeted for formatting.
    private let targetRanges: [ClosedRange<Int>]

    // MARK: Initialization Methods
    
    /// Initialize a `Parser`.
    ///
    /// - Parameter targetRanges: The zero-indexed line ranges targeted for formatting.
    ///
    public init(targetRanges: [ClosedRange<Int>]) {
        self.targetRanges = targetRanges
    }

    // MARK: Instance Methods

    /// Generates the final formatted lines.
    ///
    /// - Returns: The formatted lines of text.
    ///
    public func generateOutput() -> [String] {
        finalizeCommentBlock(paddingGuide: "")
        return output
    }

    /// Combines a line of input and combines it with previously parsed lines to generate formatted
    /// output.
    ///
    /// - Parameter line: The line of input.
    ///
    public func parseLine(_ text: String, lineNumber: Int) {
        let lineType = Lexer.lineType(text, lineNumber: lineNumber, targetRanges: targetRanges)

        switch (mode, lineType) {

        // Header Comment Discussion Mode
        case let (.headerCommentDiscussion, .headerCommentBlank(targeted, text)):
            commonCommentHandling(targeted: targeted, text: text)
        case let (.headerCommentDiscussion(currentTokens), .headerCommentGeneral(tokens, targeted, text)):
            commonCommentHandling(targeted: targeted, text: text)
            mode = .headerCommentDiscussion(currentTokens: currentTokens + tokens)
        case let (.headerCommentDiscussion, .headerCommentMultiParameterHeader(targeted, text)):
            commonCommentHandling(targeted: targeted, text: text)
        case let (.headerCommentDiscussion(currentTokens), .headerCommentParameterStart(name, tokens, targeted, text)):
            commonCommentHandling(targeted: targeted, text: text)
            discussionTokens = discussionTokens + currentTokens
            mode = .headerCommentParameter(currentName: name, currentTokens: tokens)
        case let (.headerCommentDiscussion(currentTokens), .headerCommentReturnStart(tokens, targeted, text)):
            commonCommentHandling(targeted: targeted, text: text)
            discussionTokens = discussionTokens + currentTokens
            mode = .headerCommentReturn(currentTokens: (returnValue?.tokens ?? []) + tokens)
        case let (.headerCommentDiscussion, .inlineCommentBlank(targeted, text)):
            commonCommentHandling(targeted: targeted, text: text)
            // When an inline comment touches a header comment, assume the inline slashes were a
            // typo. No mode change is necessary.
        case let (.headerCommentDiscussion(currentTokens), .inlineCommentGeneral(tokens, targeted, text)):
            commonCommentHandling(targeted: targeted, text: text)
            // When an inline comment touches a header comment, assume the inline slashes were a
            // typo.
            mode = .headerCommentDiscussion(currentTokens: currentTokens + tokens)
        case let (.headerCommentDiscussion, .nonComment(text)):
            finalizeCommentBlock(paddingGuide: text)
            output.append(text)
            mode = .nonComment

        // Header Comment General Mode
        case let (.headerCommentGeneral(currentTokens), .headerCommentBlank(targeted, text)):
            commonCommentHandling(targeted: targeted, text: text)
            generalTokens = currentTokens
            mode = .headerCommentDiscussion(currentTokens: [])
        case let (.headerCommentGeneral(currentTokens), .headerCommentGeneral(tokens, targeted, text)):
            commonCommentHandling(targeted: targeted, text: text)
            mode = .headerCommentGeneral(currentTokens: currentTokens + tokens)
        case let (.headerCommentGeneral, .headerCommentMultiParameterHeader(targeted, text)):
            commonCommentHandling(targeted: targeted, text: text)
        case let (.headerCommentGeneral(currentTokens), .headerCommentParameterStart(name, tokens, targeted, text)):
            commonCommentHandling(targeted: targeted, text: text)
            generalTokens = currentTokens
            mode = .headerCommentParameter(currentName: name, currentTokens: tokens)
        case let (.headerCommentGeneral(currentTokens), .headerCommentReturnStart(tokens, targeted, text)):
            commonCommentHandling(targeted: targeted, text: text)
            generalTokens = currentTokens
            mode = .headerCommentReturn(currentTokens: (returnValue?.tokens ?? []) + tokens)
        case let (.headerCommentGeneral(currentTokens), .inlineCommentBlank(targeted, text)):
            commonCommentHandling(targeted: targeted, text: text)
            generalTokens = currentTokens
            // When an inline comment touches a header comment, assume the inline slashes were a
            // typo.
            mode = .headerCommentDiscussion(currentTokens: [])
        case let (.headerCommentGeneral(currentTokens), .inlineCommentGeneral(tokens, targeted, text)):
            commonCommentHandling(targeted: targeted, text: text)
            // When an inline comment touches a header comment, assume the inline slashes were a
            // typo.
            mode = .headerCommentGeneral(currentTokens: currentTokens + tokens)
        case let (.headerCommentGeneral, .nonComment(text)):
            finalizeCommentBlock(paddingGuide: text)
            output.append(text)
            mode = .nonComment

        // Header Comment Parameter Mode
        case let (.headerCommentParameter(currentName, currentTokens), .headerCommentBlank(targeted, text)):
            commonCommentHandling(targeted: targeted, text: text)
            parameters.append(Parameter(name: currentName, tokens: currentTokens))
            mode = .headerCommentDiscussion(currentTokens: [])
        case let (.headerCommentParameter(currentName, currentTokens), .headerCommentGeneral(tokens, targeted, text)):
            commonCommentHandling(targeted: targeted, text: text)
            mode = .headerCommentParameter(currentName: currentName, currentTokens: currentTokens + tokens)
        case let (.headerCommentParameter, .headerCommentMultiParameterHeader(targeted, text)):
            commonCommentHandling(targeted: targeted, text: text)
        case let (.headerCommentParameter(currentName, currentTokens), .headerCommentParameterStart(name, tokens, targeted, text)):
            commonCommentHandling(targeted: targeted, text: text)
            parameters.append(Parameter(name: currentName, tokens: currentTokens))
            mode = .headerCommentParameter(currentName: name, currentTokens: tokens)
        case let (.headerCommentParameter(currentName, currentTokens), .headerCommentReturnStart(tokens, targeted, text)):
            commonCommentHandling(targeted: targeted, text: text)
            parameters.append(Parameter(name: currentName, tokens: currentTokens))
            mode = .headerCommentReturn(currentTokens: (returnValue?.tokens ?? []) + tokens)
        case let (.headerCommentParameter(currentName, currentTokens), .inlineCommentBlank(targeted, text)):
            commonCommentHandling(targeted: targeted, text: text)
            parameters.append(Parameter(name: currentName, tokens: currentTokens))
            // When an inline comment touches a header comment, assume the inline slashes were a
            // typo.
            mode = .headerCommentDiscussion(currentTokens: [])
        case let (.headerCommentParameter(currentName, currentTokens), .inlineCommentGeneral(tokens, targeted, text)):
            commonCommentHandling(targeted: targeted, text: text)
            // When an inline comment touches a header comment, assume the inline slashes were a
            // typo.
            mode = .headerCommentParameter(currentName: currentName, currentTokens: currentTokens + tokens)
        case let (.headerCommentParameter, .nonComment(text)):
            finalizeCommentBlock(paddingGuide: text)
            output.append(text)
            mode = .nonComment

        // Header Comment Return Mode
        case let (.headerCommentReturn(currentTokens), .headerCommentBlank(targeted, text)):
            commonCommentHandling(targeted: targeted, text: text)
            returnValue = Return(tokens: currentTokens)
            mode = .headerCommentDiscussion(currentTokens: [])
        case let (.headerCommentReturn(currentTokens), .headerCommentGeneral(tokens, targeted, text)):
            commonCommentHandling(targeted: targeted, text: text)
            mode = .headerCommentReturn(currentTokens: currentTokens + tokens)
        case let (.headerCommentReturn, .headerCommentMultiParameterHeader(targeted, text)):
            commonCommentHandling(targeted: targeted, text: text)
        case let (.headerCommentReturn(currentTokens), .headerCommentParameterStart(name, tokens, targeted, text)):
            commonCommentHandling(targeted: targeted, text: text)
            returnValue = Return(tokens: currentTokens)
            mode = .headerCommentParameter(currentName: name, currentTokens: tokens)
        case let (.headerCommentReturn(currentTokens), .headerCommentReturnStart(tokens, targeted, text)):
            commonCommentHandling(targeted: targeted, text: text)
            // This shouldn't happen, but if it does, just combine the multiple return descriptions.
            mode = .headerCommentReturn(currentTokens: currentTokens + tokens)
        case let (.headerCommentReturn(currentTokens), .inlineCommentBlank(targeted, text)):
            commonCommentHandling(targeted: targeted, text: text)
            returnValue = Return(tokens: currentTokens)
            // When an inline comment touches a header comment, assume the inline slashes were a
            // typo.
            mode = .headerCommentDiscussion(currentTokens: [])
        case let (.headerCommentReturn(currentTokens), .inlineCommentGeneral(tokens, targeted, text)):
            commonCommentHandling(targeted: targeted, text: text)
            // When an inline comment touches a header comment, assume the inline slashes were a
            // typo.
            mode = .headerCommentReturn(currentTokens: currentTokens + tokens)
        case let (.headerCommentReturn, .nonComment(text)):
            finalizeCommentBlock(paddingGuide: text)
            output.append(text)
            mode = .nonComment

        // Inline Comment Mode
        case let (.inlineComment(currentTokens), .headerCommentBlank(targeted, text)):
            commonCommentHandling(targeted: targeted, text: text)
            // When an inline comment touches a header comment, assume the inline slashes were a
            // typo.
            mode = .headerCommentGeneral(currentTokens: currentTokens)
        case let (.inlineComment(currentTokens), .headerCommentGeneral(tokens, targeted, text)):
            commonCommentHandling(targeted: targeted, text: text)
            // When an inline comment touches a header comment, assume the inline slashes were a
            // typo.
            mode = .headerCommentGeneral(currentTokens: currentTokens + tokens)
        case let (.inlineComment, .headerCommentMultiParameterHeader(targeted, text)):
            commonCommentHandling(targeted: targeted, text: text)
        case let (.inlineComment(currentTokens), .headerCommentParameterStart(name, tokens, targeted, text)):
            commonCommentHandling(targeted: targeted, text: text)
            // When an inline comment touches a header comment, assume the inline slashes were a
            // typo.
            generalTokens = currentTokens
            mode = .headerCommentParameter(currentName: name, currentTokens: tokens)
        case let (.inlineComment(currentTokens), .headerCommentReturnStart(tokens, targeted, text)):
            commonCommentHandling(targeted: targeted, text: text)
            // When an inline comment touches a header comment, assume the inline slashes were a
            // typo.
            generalTokens = currentTokens
            mode = .headerCommentReturn(currentTokens: (returnValue?.tokens ?? []) + tokens)
        case let (.inlineComment, .inlineCommentBlank(targeted, text)):
            commonCommentHandling(targeted: targeted, text: text)
        case let (.inlineComment(currentTokens), .inlineCommentGeneral(tokens, targeted, text)):
            commonCommentHandling(targeted: targeted, text: text)
            mode = .inlineComment(currentTokens: currentTokens + tokens)
        case let (.inlineComment, .nonComment(text)):
            finalizeCommentBlock(paddingGuide: text)
            output.append(text)
            mode = .nonComment

        // Non Comment Mode
        case let (.nonComment, .headerCommentBlank(targeted, text)):
            commonCommentHandling(targeted: targeted, text: text)
            fallbackPaddingGuide = text
            mode = .headerCommentGeneral(currentTokens: [])
        case let (.nonComment, .headerCommentGeneral(tokens, targeted, text)):
            commonCommentHandling(targeted: targeted, text: text)
            fallbackPaddingGuide = text
            mode = .headerCommentGeneral(currentTokens: tokens)
        case let (.nonComment, .headerCommentMultiParameterHeader(targeted, text)):
            commonCommentHandling(targeted: targeted, text: text)
            fallbackPaddingGuide = text
        case let (.nonComment, .headerCommentParameterStart(name, tokens, targeted, text)):
            commonCommentHandling(targeted: targeted, text: text)
            fallbackPaddingGuide = text
            mode = .headerCommentParameter(currentName: name, currentTokens: tokens)
        case let (.nonComment, .headerCommentReturnStart(tokens, targeted, text)):
            commonCommentHandling(targeted: targeted, text: text)
            fallbackPaddingGuide = text
            mode = .headerCommentReturn(currentTokens: tokens)
        case let (.nonComment, .inlineCommentBlank(targeted, text)):
            commonCommentHandling(targeted: targeted, text: text)
            fallbackPaddingGuide = text
            mode = .inlineComment(currentTokens: [])
        case let (.nonComment, .inlineCommentGeneral(tokens, targeted, text)):
            commonCommentHandling(targeted: targeted, text: text)
            fallbackPaddingGuide = text
            mode = .inlineComment(currentTokens: tokens)
        case let (.nonComment, .nonComment(text)):
            output.append(text)
        }
    }

    // MARK: Private Methods
    
    /// Perform parsing common to all comment line types.
    ///
    /// - Parameters:
    ///   - targeted: `true` iff this line was contained in a selection range.
    ///   - text: The original unmodified line of text.
    ///
    private func commonCommentHandling(targeted: Bool, text: String) {
        commentBlockBuffer.append(text)
        isTargetedComment = isTargetedComment || targeted
    }

    /// Uses the temporary comment block values to generate a formatted comment block and add it to
    /// the output. The temporary values are then erased in preparation for the next comment block.
    ///
    /// - Parameter paddingGuide: A string which indicates the amount of whitespace to insert at the
    ///   beginning of every line in the comment block. This is determined by the amount of
    ///   whitespace at the beginning of the padding guide.
    ///
    private func finalizeCommentBlock(paddingGuide: String) {
        defer {
            // Clean up.
            commentBlockBuffer = []
            discussionTokens = []
            fallbackPaddingGuide = nil
            generalTokens = []
            isTargetedComment = false
            mode = .nonComment
            parameters = []
            returnValue = nil
        }

        // Skip formatting this comment block if it was not targeted.
        guard isTargetedComment else {
            output.append(contentsOf: commentBlockBuffer)
            return
        }

        // Finalize in-progress data.
        switch mode {
        case let .inlineComment(currentTokens):
            generalTokens = currentTokens
        case let .headerCommentDiscussion(currentTokens):
            discussionTokens = discussionTokens + currentTokens
        case let .headerCommentGeneral(currentTokens):
            generalTokens = currentTokens
        case let .headerCommentParameter(currentName, currentTokens):
            parameters.append(Parameter(name: currentName, tokens: currentTokens))
        case let .headerCommentReturn(currentTokens):
            returnValue = Return(tokens: currentTokens)
        case .nonComment:
            break
        }

        // Build the prefix based on the mode and leading whitespace of the padding guide.
        let finalPaddingGuide = paddingGuide.allSatisfy { $0.isWhitespace } ?
            fallbackPaddingGuide ?? "" : paddingGuide
        let padding = finalPaddingGuide.prefix { $0.isWhitespace }
        let prefix: String
        switch mode {
        case .headerCommentDiscussion,
             .headerCommentGeneral,
             .headerCommentParameter,
             .headerCommentReturn:
            prefix = padding + "///"
        case .inlineComment:
            prefix = padding + "//"
        case .nonComment:
            prefix = ""
        }

        // Build groups of lines representing the sections of the comment.
        var sections = [[String]]()

        // Generate the general output.
        if !generalTokens.isEmpty {
            sections.append(generalTokens.asGeneralCommentLines(prefix: prefix))
        }

        // Parameters / Returns block.
        if parameters.count == 1 {
            var section = [String]()
            // Generate the parameter output.
            section.append(contentsOf: parameters[0].asSingleParameterLines(prefix: prefix))
            // Generate the return output.
            if let returnValue {
                section.append(contentsOf: returnValue.asReturnLines(prefix: prefix))
            }
            sections.append(section)
        } else if parameters.count > 1 {
            var section = [String]()
            // Generate the parameter output.
            section.append(prefix + " - Parameters:")
            for parameter in parameters {
                section.append(contentsOf: parameter.asMultiParameterLines(prefix: prefix))
            }
            // Generate the return output.
            if let returnValue {
                section.append(contentsOf: returnValue.asReturnLines(prefix: prefix))
            }
            sections.append(section)
        } else {
            // Generate the return output.
            if let returnValue {
                var section = [String]()
                section.append(contentsOf: returnValue.asReturnLines(prefix: prefix))
                sections.append(section)
            }
        }

        // Generate the discussion output.
        if !discussionTokens.isEmpty {
            sections.append(discussionTokens.asGeneralCommentLines(prefix: prefix))
        }

        // Add the sections to the output with a blank line between each section.
        output.append(contentsOf: sections.joined(separator: [prefix]))

        // Add an extra blank line if the comment block ended with parameters or returns.
        if (!parameters.isEmpty || returnValue != nil) && discussionTokens.isEmpty {
            output.append(prefix)
        }
    }
}
