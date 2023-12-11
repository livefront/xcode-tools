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
        finalizeCommentBlock(indentationGuide: "")
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
            commentBlock.saveOriginalLine(targeted: targeted, text: text)
        case let (.headerCommentDiscussion, .headerCommentGeneral(tokens, targeted, text)):
            commentBlock.saveOriginalLine(targeted: targeted, text: text)
            commentBlock.appendDiscussionTokens(tokens)
        case let (.headerCommentDiscussion, .headerCommentMultiParameterHeader(targeted, text)):
            commentBlock.saveOriginalLine(targeted: targeted, text: text)
        case let (.headerCommentDiscussion, .headerCommentParameterStart(name, tokens, targeted, text)):
            commentBlock.saveOriginalLine(targeted: targeted, text: text)
            commentBlock.appendParameter(name: name, tokens: tokens)
            mode = .headerCommentParameter
        case let (.headerCommentDiscussion, .headerCommentReturnsStart(tokens, targeted, text)):
            commentBlock.saveOriginalLine(targeted: targeted, text: text)
            commentBlock.appendReturnsTokens(tokens)
            mode = .headerCommentReturns
        case let (.headerCommentDiscussion, .headerCommentThrowsStart(tokens, targeted, text)):
            commentBlock.saveOriginalLine(targeted: targeted, text: text)
            commentBlock.appendThrowsTokens(tokens)
            mode = .headerCommentThrows
        case let (.headerCommentDiscussion, .inlineCommentBlank(targeted, text)):
            commentBlock.saveOriginalLine(targeted: targeted, text: text)
            // When an inline comment touches a header comment, assume the inline slashes were a
            // typo. No mode change is necessary.
        case let (.headerCommentDiscussion, .inlineCommentGeneral(tokens, targeted, text)):
            // When an inline comment touches a header comment, assume the inline slashes were a
            // typo.
            commentBlock.saveOriginalLine(targeted: targeted, text: text)
            commentBlock.appendDiscussionTokens(tokens)
            mode = .headerCommentDiscussion
        case let (.headerCommentDiscussion, .nonComment(text)):
            finalizeCommentBlock(indentationGuide: text)
            output.append(text)
            mode = .nonComment

        // Header Comment General Mode
        case let (.headerCommentGeneral, .headerCommentBlank(targeted, text)):
            commentBlock.saveOriginalLine(targeted: targeted, text: text)
            mode = .headerCommentDiscussion
        case let (.headerCommentGeneral, .headerCommentGeneral(tokens, targeted, text)):
            commentBlock.saveOriginalLine(targeted: targeted, text: text)
            commentBlock.appendGeneralTokens(tokens)
        case let (.headerCommentGeneral, .headerCommentMultiParameterHeader(targeted, text)):
            commentBlock.saveOriginalLine(targeted: targeted, text: text)
        case let (.headerCommentGeneral, .headerCommentParameterStart(name, tokens, targeted, text)):
            commentBlock.saveOriginalLine(targeted: targeted, text: text)
            commentBlock.appendParameter(name: name, tokens: tokens)
            mode = .headerCommentParameter
        case let (.headerCommentGeneral, .headerCommentReturnsStart(tokens, targeted, text)):
            commentBlock.saveOriginalLine(targeted: targeted, text: text)
            commentBlock.appendReturnsTokens(tokens)
            mode = .headerCommentReturns
        case let (.headerCommentGeneral, .headerCommentThrowsStart(tokens, targeted, text)):
            commentBlock.saveOriginalLine(targeted: targeted, text: text)
            commentBlock.appendThrowsTokens(tokens)
            mode = .headerCommentThrows
        case let (.headerCommentGeneral, .inlineCommentBlank(targeted, text)):
            // When an inline comment touches a header comment, assume the inline slashes were a
            // typo.
            commentBlock.saveOriginalLine(targeted: targeted, text: text)
            mode = .headerCommentDiscussion
        case let (.headerCommentGeneral, .inlineCommentGeneral(tokens, targeted, text)):
            // When an inline comment touches a header comment, assume the inline slashes were a
            // typo.
            commentBlock.saveOriginalLine(targeted: targeted, text: text)
            commentBlock.appendGeneralTokens(tokens)
        case let (.headerCommentGeneral, .nonComment(text)):
            finalizeCommentBlock(indentationGuide: text)
            output.append(text)
            mode = .nonComment

        // Header Comment Parameter Mode
        case let (.headerCommentParameter, .headerCommentBlank(targeted, text)):
            commentBlock.saveOriginalLine(targeted: targeted, text: text)
            mode = .headerCommentDiscussion
        case let (.headerCommentParameter, .headerCommentGeneral(tokens, targeted, text)):
            commentBlock.saveOriginalLine(targeted: targeted, text: text)
            commentBlock.appendParameter(tokens: tokens)
        case let (.headerCommentParameter, .headerCommentMultiParameterHeader(targeted, text)):
            commentBlock.saveOriginalLine(targeted: targeted, text: text)
        case let (.headerCommentParameter, .headerCommentParameterStart(name, tokens, targeted, text)):
            commentBlock.saveOriginalLine(targeted: targeted, text: text)
            commentBlock.appendParameter(name: name, tokens: tokens)
        case let (.headerCommentParameter, .headerCommentReturnsStart(tokens, targeted, text)):
            commentBlock.saveOriginalLine(targeted: targeted, text: text)
            commentBlock.appendReturnsTokens(tokens)
            mode = .headerCommentReturns
        case let (.headerCommentParameter, .headerCommentThrowsStart(tokens, targeted, text)):
            commentBlock.saveOriginalLine(targeted: targeted, text: text)
            commentBlock.appendThrowsTokens(tokens)
            mode = .headerCommentThrows
        case let (.headerCommentParameter, .inlineCommentBlank(targeted, text)):
            // When an inline comment touches a header comment, assume the inline slashes were a
            // typo.
            commentBlock.saveOriginalLine(targeted: targeted, text: text)
            mode = .headerCommentDiscussion
        case let (.headerCommentParameter, .inlineCommentGeneral(tokens, targeted, text)):
            // When an inline comment touches a header comment, assume the inline slashes were a
            // typo.
            commentBlock.saveOriginalLine(targeted: targeted, text: text)
            commentBlock.appendParameter(tokens: tokens)
        case let (.headerCommentParameter, .nonComment(text)):
            finalizeCommentBlock(indentationGuide: text)
            output.append(text)
            mode = .nonComment

        // Header Comment Returns Mode
        case let (.headerCommentReturns, .headerCommentBlank(targeted, text)):
            commentBlock.saveOriginalLine(targeted: targeted, text: text)
            mode = .headerCommentDiscussion
        case let (.headerCommentReturns, .headerCommentGeneral(tokens, targeted, text)):
            commentBlock.saveOriginalLine(targeted: targeted, text: text)
            commentBlock.appendReturnsTokens(tokens)
        case let (.headerCommentReturns, .headerCommentMultiParameterHeader(targeted, text)):
            commentBlock.saveOriginalLine(targeted: targeted, text: text)
        case let (.headerCommentReturns, .headerCommentParameterStart(name, tokens, targeted, text)):
            commentBlock.saveOriginalLine(targeted: targeted, text: text)
            commentBlock.appendParameter(name: name, tokens: tokens)
            mode = .headerCommentParameter
        case let (.headerCommentReturns, .headerCommentReturnsStart(tokens, targeted, text)):
            commentBlock.saveOriginalLine(targeted: targeted, text: text)
            commentBlock.appendReturnsTokens(tokens)
        case let (.headerCommentReturns, .headerCommentThrowsStart(tokens, targeted, text)):
            commentBlock.saveOriginalLine(targeted: targeted, text: text)
            commentBlock.appendThrowsTokens(tokens)
            mode = .headerCommentThrows
        case let (.headerCommentReturns, .inlineCommentBlank(targeted, text)):
            // When an inline comment touches a header comment, assume the inline slashes were a
            // typo.
            commentBlock.saveOriginalLine(targeted: targeted, text: text)
            mode = .headerCommentDiscussion
        case let (.headerCommentReturns, .inlineCommentGeneral(tokens, targeted, text)):
            // When an inline comment touches a header comment, assume the inline slashes were a
            // typo.
            commentBlock.saveOriginalLine(targeted: targeted, text: text)
            commentBlock.appendReturnsTokens(tokens)
        case let (.headerCommentReturns, .nonComment(text)):
            finalizeCommentBlock(indentationGuide: text)
            output.append(text)
            mode = .nonComment

        // Header Comment Throws Mode
        case let (.headerCommentThrows, .headerCommentBlank(targeted, text)):
            commentBlock.saveOriginalLine(targeted: targeted, text: text)
            mode = .headerCommentDiscussion
        case let (.headerCommentThrows, .headerCommentGeneral(tokens, targeted, text)):
            commentBlock.saveOriginalLine(targeted: targeted, text: text)
            commentBlock.appendThrowsTokens(tokens)
        case let (.headerCommentThrows, .headerCommentMultiParameterHeader(targeted, text)):
            commentBlock.saveOriginalLine(targeted: targeted, text: text)
        case let (.headerCommentThrows, .headerCommentParameterStart(name, tokens, targeted, text)):
            commentBlock.saveOriginalLine(targeted: targeted, text: text)
            commentBlock.appendParameter(name: name, tokens: tokens)
            mode = .headerCommentParameter
        case let (.headerCommentThrows, .headerCommentReturnsStart(tokens, targeted, text)):
            commentBlock.saveOriginalLine(targeted: targeted, text: text)
            commentBlock.appendReturnsTokens(tokens)
            mode = .headerCommentReturns
        case let (.headerCommentThrows, .headerCommentThrowsStart(tokens, targeted, text)):
            commentBlock.saveOriginalLine(targeted: targeted, text: text)
            commentBlock.appendThrowsTokens(tokens)
        case let (.headerCommentThrows, .inlineCommentBlank(targeted, text)):
            // When an inline comment touches a header comment, assume the inline slashes were a
            // typo.
            commentBlock.saveOriginalLine(targeted: targeted, text: text)
            mode = .headerCommentDiscussion
        case let (.headerCommentThrows, .inlineCommentGeneral(tokens, targeted, text)):
            // When an inline comment touches a header comment, assume the inline slashes were a
            // typo.
            commentBlock.saveOriginalLine(targeted: targeted, text: text)
            commentBlock.appendThrowsTokens(tokens)
        case let (.headerCommentThrows, .nonComment(text)):
            finalizeCommentBlock(indentationGuide: text)
            output.append(text)
            mode = .nonComment

        // Inline Comment Mode
        case let (.inlineComment, .headerCommentBlank(targeted, text)):
            // When an inline comment touches a header comment, assume the inline slashes were a
            // typo.
            commentBlock.saveOriginalLine(targeted: targeted, text: text)
            mode = .headerCommentGeneral
        case let (.inlineComment, .headerCommentGeneral(tokens, targeted, text)):
            // When an inline comment touches a header comment, assume the inline slashes were a
            // typo.
            commentBlock.saveOriginalLine(targeted: targeted, text: text)
            commentBlock.appendGeneralTokens(tokens)
            mode = .headerCommentGeneral
        case let (.inlineComment, .headerCommentMultiParameterHeader(targeted, text)):
            commentBlock.saveOriginalLine(targeted: targeted, text: text)
        case let (.inlineComment, .headerCommentParameterStart(name, tokens, targeted, text)):
            // When an inline comment touches a header comment, assume the inline slashes were a
            // typo.
            commentBlock.saveOriginalLine(targeted: targeted, text: text)
            commentBlock.appendParameter(name: name, tokens: tokens)
            mode = .headerCommentParameter
        case let (.inlineComment, .headerCommentReturnsStart(tokens, targeted, text)):
            // When an inline comment touches a header comment, assume the inline slashes were a
            // typo.
            commentBlock.saveOriginalLine(targeted: targeted, text: text)
            commentBlock.appendReturnsTokens(tokens)
            mode = .headerCommentReturns
        case let (.inlineComment, .headerCommentThrowsStart(tokens, targeted, text)):
            // When an inline comment touches a header comment, assume the inline slashes were a
            // typo.
            commentBlock.saveOriginalLine(targeted: targeted, text: text)
            commentBlock.appendThrowsTokens(tokens)
            mode = .headerCommentThrows
        case let (.inlineComment, .inlineCommentBlank(targeted, text)):
            commentBlock.saveOriginalLine(targeted: targeted, text: text)
        case let (.inlineComment, .inlineCommentGeneral(tokens, targeted, text)):
            commentBlock.saveOriginalLine(targeted: targeted, text: text)
            commentBlock.appendGeneralTokens(tokens)
        case let (.inlineComment, .nonComment(text)):
            finalizeCommentBlock(indentationGuide: text)
            output.append(text)
            mode = .nonComment

        // Non Comment Mode
        case let (.nonComment, .headerCommentBlank(targeted, text)):
            commentBlock.saveOriginalLine(targeted: targeted, text: text)
            mode = .headerCommentGeneral
        case let (.nonComment, .headerCommentGeneral(tokens, targeted, text)):
            commentBlock.saveOriginalLine(targeted: targeted, text: text)
            commentBlock.appendGeneralTokens(tokens)
            mode = .headerCommentGeneral
        case let (.nonComment, .headerCommentMultiParameterHeader(targeted, text)):
            commentBlock.saveOriginalLine(targeted: targeted, text: text)
        case let (.nonComment, .headerCommentParameterStart(name, tokens, targeted, text)):
            commentBlock.saveOriginalLine(targeted: targeted, text: text)
            commentBlock.appendParameter(name: name, tokens: tokens)
            mode = .headerCommentParameter
        case let (.nonComment, .headerCommentReturnsStart(tokens, targeted, text)):
            commentBlock.saveOriginalLine(targeted: targeted, text: text)
            commentBlock.appendReturnsTokens(tokens)
            mode = .headerCommentReturns
        case let (.nonComment, .headerCommentThrowsStart(tokens, targeted, text)):
            commentBlock.saveOriginalLine(targeted: targeted, text: text)
            commentBlock.appendThrowsTokens(tokens)
            mode = .headerCommentThrows
        case let (.nonComment, .inlineCommentBlank(targeted, text)):
            commentBlock.saveOriginalLine(targeted: targeted, text: text)
            mode = .inlineComment
        case let (.nonComment, .inlineCommentGeneral(tokens, targeted, text)):
            commentBlock.saveOriginalLine(targeted: targeted, text: text)
            commentBlock.appendGeneralTokens(tokens)
            mode = .inlineComment
        case let (.nonComment, .nonComment(text)):
            output.append(text)
        }
    }

    // MARK: Private Methods

    /// Finalize the in-progress comment block. The block's output is added to the parser output and
    /// the comment block is reset to empty.
    ///
    /// - Parameter indentationGuide: A string which indicates the amount of whitespace to insert at
    ///   the beginning of every line in the comment block. This is determined by the amount of
    ///   whitespace at the beginning of the indentation guide.
    ///
    private func finalizeCommentBlock(indentationGuide: String) {
        guard let commentType = mode.commentType else { return }
        output.append(
            contentsOf: commentBlock.generateOutput(
                type: commentType,
                indentationGuide: indentationGuide
            )
        )
        commentBlock = CommentBlock()
    }
}
