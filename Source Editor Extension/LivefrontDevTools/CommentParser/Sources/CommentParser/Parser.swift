/// A state machine which parses lines and generates output.
public class Parser {

    // MARK: Private Properties

    /// The current comment block.
    private var commentBlock = CommentBlock()

    /// The current parsing mode. The mode indicates the type of data being parsed in the recently
    /// supplied lines.
    private var mode: ParsingMode = .nonComment

    /// The final output text.
    private var output = [String]()

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
        output += commentBlock.finalizeAndGenerateOutput(mode: mode, indentationGuide: "")
        commentBlock = CommentBlock()
        mode = .nonComment
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
            commentBlock.addCommentLine(targeted: targeted, text: text)
        case let (.headerCommentDiscussion(currentTokens), .headerCommentGeneral(tokens, targeted, text)):
            commentBlock.addCommentLine(targeted: targeted, text: text)
            mode = .headerCommentDiscussion(currentTokens: currentTokens + tokens)
        case let (.headerCommentDiscussion, .headerCommentMultiParameterHeader(targeted, text)):
            commentBlock.addCommentLine(targeted: targeted, text: text)
        case let (.headerCommentDiscussion(currentTokens), .headerCommentParameterStart(name, tokens, targeted, text)):
            commentBlock.addCommentLine(targeted: targeted, text: text)
            commentBlock.discussionTokens += currentTokens
            mode = .headerCommentParameter(currentName: name, currentTokens: tokens)
        case let (.headerCommentDiscussion(currentTokens), .headerCommentReturnStart(tokens, targeted, text)):
            commentBlock.addCommentLine(targeted: targeted, text: text)
            commentBlock.discussionTokens += currentTokens
            mode = .headerCommentReturn(currentTokens: (commentBlock.returnValue?.tokens ?? []) + tokens)
        case let (.headerCommentDiscussion, .inlineCommentBlank(targeted, text)):
            commentBlock.addCommentLine(targeted: targeted, text: text)
            // When an inline comment touches a header comment, assume the inline slashes were a
            // typo. No mode change is necessary.
        case let (.headerCommentDiscussion(currentTokens), .inlineCommentGeneral(tokens, targeted, text)):
            // When an inline comment touches a header comment, assume the inline slashes were a
            // typo.
            commentBlock.addCommentLine(targeted: targeted, text: text)
            mode = .headerCommentDiscussion(currentTokens: currentTokens + tokens)
        case let (.headerCommentDiscussion, .nonComment(text)):
            finalizeCommentBlock(text: text)
            mode = .nonComment

        // Header Comment General Mode
        case let (.headerCommentGeneral(currentTokens), .headerCommentBlank(targeted, text)):
            commentBlock.addCommentLine(targeted: targeted, text: text)
            commentBlock.generalTokens = currentTokens
            mode = .headerCommentDiscussion(currentTokens: [])
        case let (.headerCommentGeneral(currentTokens), .headerCommentGeneral(tokens, targeted, text)):
            commentBlock.addCommentLine(targeted: targeted, text: text)
            mode = .headerCommentGeneral(currentTokens: currentTokens + tokens)
        case let (.headerCommentGeneral, .headerCommentMultiParameterHeader(targeted, text)):
            commentBlock.addCommentLine(targeted: targeted, text: text)
        case let (.headerCommentGeneral(currentTokens), .headerCommentParameterStart(name, tokens, targeted, text)):
            commentBlock.addCommentLine(targeted: targeted, text: text)
            commentBlock.generalTokens = currentTokens
            mode = .headerCommentParameter(currentName: name, currentTokens: tokens)
        case let (.headerCommentGeneral(currentTokens), .headerCommentReturnStart(tokens, targeted, text)):
            commentBlock.addCommentLine(targeted: targeted, text: text)
            commentBlock.generalTokens = currentTokens
            mode = .headerCommentReturn(currentTokens: (commentBlock.returnValue?.tokens ?? []) + tokens)
        case let (.headerCommentGeneral(currentTokens), .inlineCommentBlank(targeted, text)):
            // When an inline comment touches a header comment, assume the inline slashes were a
            // typo.
            commentBlock.addCommentLine(targeted: targeted, text: text)
            commentBlock.generalTokens = currentTokens
            mode = .headerCommentDiscussion(currentTokens: [])
        case let (.headerCommentGeneral(currentTokens), .inlineCommentGeneral(tokens, targeted, text)):
            // When an inline comment touches a header comment, assume the inline slashes were a
            // typo.
            commentBlock.addCommentLine(targeted: targeted, text: text)
            mode = .headerCommentGeneral(currentTokens: currentTokens + tokens)
        case let (.headerCommentGeneral, .nonComment(text)):
            finalizeCommentBlock(text: text)
            mode = .nonComment

        // Header Comment Parameter Mode
        case let (.headerCommentParameter(currentName, currentTokens), .headerCommentBlank(targeted, text)):
            commentBlock.addCommentLine(targeted: targeted, text: text)
            commentBlock.parameters.append(Parameter(name: currentName, tokens: currentTokens))
            mode = .headerCommentDiscussion(currentTokens: [])
        case let (.headerCommentParameter(currentName, currentTokens), .headerCommentGeneral(tokens, targeted, text)):
            commentBlock.addCommentLine(targeted: targeted, text: text)
            mode = .headerCommentParameter(currentName: currentName, currentTokens: currentTokens + tokens)
        case let (.headerCommentParameter, .headerCommentMultiParameterHeader(targeted, text)):
            commentBlock.addCommentLine(targeted: targeted, text: text)
        case let (.headerCommentParameter(currentName, currentTokens), .headerCommentParameterStart(name, tokens, targeted, text)):
            commentBlock.addCommentLine(targeted: targeted, text: text)
            commentBlock.parameters.append(Parameter(name: currentName, tokens: currentTokens))
            mode = .headerCommentParameter(currentName: name, currentTokens: tokens)
        case let (.headerCommentParameter(currentName, currentTokens), .headerCommentReturnStart(tokens, targeted, text)):
            commentBlock.addCommentLine(targeted: targeted, text: text)
            commentBlock.parameters.append(Parameter(name: currentName, tokens: currentTokens))
            mode = .headerCommentReturn(currentTokens: (commentBlock.returnValue?.tokens ?? []) + tokens)
        case let (.headerCommentParameter(currentName, currentTokens), .inlineCommentBlank(targeted, text)):
            // When an inline comment touches a header comment, assume the inline slashes were a
            // typo.
            commentBlock.addCommentLine(targeted: targeted, text: text)
            commentBlock.parameters.append(Parameter(name: currentName, tokens: currentTokens))
            mode = .headerCommentDiscussion(currentTokens: [])
        case let (.headerCommentParameter(currentName, currentTokens), .inlineCommentGeneral(tokens, targeted, text)):
            // When an inline comment touches a header comment, assume the inline slashes were a
            // typo.
            commentBlock.addCommentLine(targeted: targeted, text: text)
            mode = .headerCommentParameter(currentName: currentName, currentTokens: currentTokens + tokens)
        case let (.headerCommentParameter, .nonComment(text)):
            finalizeCommentBlock(text: text)
            mode = .nonComment

        // Header Comment Return Mode
        case let (.headerCommentReturn(currentTokens), .headerCommentBlank(targeted, text)):
            commentBlock.addCommentLine(targeted: targeted, text: text)
            commentBlock.returnValue = Return(tokens: currentTokens)
            mode = .headerCommentDiscussion(currentTokens: [])
        case let (.headerCommentReturn(currentTokens), .headerCommentGeneral(tokens, targeted, text)):
            commentBlock.addCommentLine(targeted: targeted, text: text)
            mode = .headerCommentReturn(currentTokens: currentTokens + tokens)
        case let (.headerCommentReturn, .headerCommentMultiParameterHeader(targeted, text)):
            commentBlock.addCommentLine(targeted: targeted, text: text)
        case let (.headerCommentReturn(currentTokens), .headerCommentParameterStart(name, tokens, targeted, text)):
            commentBlock.addCommentLine(targeted: targeted, text: text)
            commentBlock.returnValue = Return(tokens: currentTokens)
            mode = .headerCommentParameter(currentName: name, currentTokens: tokens)
        case let (.headerCommentReturn(currentTokens), .headerCommentReturnStart(tokens, targeted, text)):
            commentBlock.addCommentLine(targeted: targeted, text: text)
            // This shouldn't happen, but if it does, just combine the multiple return descriptions.
            mode = .headerCommentReturn(currentTokens: currentTokens + tokens)
        case let (.headerCommentReturn(currentTokens), .inlineCommentBlank(targeted, text)):
            // When an inline comment touches a header comment, assume the inline slashes were a
            // typo.
            commentBlock.addCommentLine(targeted: targeted, text: text)
            commentBlock.returnValue = Return(tokens: currentTokens)
            mode = .headerCommentDiscussion(currentTokens: [])
        case let (.headerCommentReturn(currentTokens), .inlineCommentGeneral(tokens, targeted, text)):
            // When an inline comment touches a header comment, assume the inline slashes were a
            // typo.
            commentBlock.addCommentLine(targeted: targeted, text: text)
            mode = .headerCommentReturn(currentTokens: currentTokens + tokens)
        case let (.headerCommentReturn, .nonComment(text)):
            finalizeCommentBlock(text: text)
            mode = .nonComment

        // Inline Comment Mode
        case let (.inlineComment(currentTokens), .headerCommentBlank(targeted, text)):
            // When an inline comment touches a header comment, assume the inline slashes were a
            // typo.
            commentBlock.addCommentLine(targeted: targeted, text: text)
            mode = .headerCommentGeneral(currentTokens: currentTokens)
        case let (.inlineComment(currentTokens), .headerCommentGeneral(tokens, targeted, text)):
            // When an inline comment touches a header comment, assume the inline slashes were a
            // typo.
            commentBlock.addCommentLine(targeted: targeted, text: text)
            mode = .headerCommentGeneral(currentTokens: currentTokens + tokens)
        case let (.inlineComment, .headerCommentMultiParameterHeader(targeted, text)):
            commentBlock.addCommentLine(targeted: targeted, text: text)
        case let (.inlineComment(currentTokens), .headerCommentParameterStart(name, tokens, targeted, text)):
            // When an inline comment touches a header comment, assume the inline slashes were a
            // typo.
            commentBlock.addCommentLine(targeted: targeted, text: text)
            commentBlock.generalTokens = currentTokens
            mode = .headerCommentParameter(currentName: name, currentTokens: tokens)
        case let (.inlineComment(currentTokens), .headerCommentReturnStart(tokens, targeted, text)):
            // When an inline comment touches a header comment, assume the inline slashes were a
            // typo.
            commentBlock.addCommentLine(targeted: targeted, text: text)
            commentBlock.generalTokens = currentTokens
            mode = .headerCommentReturn(currentTokens: (commentBlock.returnValue?.tokens ?? []) + tokens)
        case let (.inlineComment, .inlineCommentBlank(targeted, text)):
            commentBlock.addCommentLine(targeted: targeted, text: text)
        case let (.inlineComment(currentTokens), .inlineCommentGeneral(tokens, targeted, text)):
            commentBlock.addCommentLine(targeted: targeted, text: text)
            mode = .inlineComment(currentTokens: currentTokens + tokens)
        case let (.inlineComment, .nonComment(text)):
            finalizeCommentBlock(text: text)
            mode = .nonComment

        // Non Comment Mode
        case let (.nonComment, .headerCommentBlank(targeted, text)):
            commentBlock.addCommentLine(targeted: targeted, text: text)
            mode = .headerCommentGeneral(currentTokens: [])
        case let (.nonComment, .headerCommentGeneral(tokens, targeted, text)):
            commentBlock.addCommentLine(targeted: targeted, text: text)
            mode = .headerCommentGeneral(currentTokens: tokens)
        case let (.nonComment, .headerCommentMultiParameterHeader(targeted, text)):
            commentBlock.addCommentLine(targeted: targeted, text: text)
        case let (.nonComment, .headerCommentParameterStart(name, tokens, targeted, text)):
            commentBlock.addCommentLine(targeted: targeted, text: text)
            mode = .headerCommentParameter(currentName: name, currentTokens: tokens)
        case let (.nonComment, .headerCommentReturnStart(tokens, targeted, text)):
            commentBlock.addCommentLine(targeted: targeted, text: text)
            mode = .headerCommentReturn(currentTokens: tokens)
        case let (.nonComment, .inlineCommentBlank(targeted, text)):
            commentBlock.addCommentLine(targeted: targeted, text: text)
            mode = .inlineComment(currentTokens: [])
        case let (.nonComment, .inlineCommentGeneral(tokens, targeted, text)):
            commentBlock.addCommentLine(targeted: targeted, text: text)
            mode = .inlineComment(currentTokens: tokens)
        case let (.nonComment, .nonComment(text)):
            output.append(text)
        }
    } 

    // MARK: Private Methods

    /// Finalize the in-progress comment block.
    /// - Parameter text: The current line of text.
    private func finalizeCommentBlock(text: String) {
        output += commentBlock.finalizeAndGenerateOutput(mode: mode, indentationGuide: text)
        commentBlock = CommentBlock()
        output.append(text)
    }
}
