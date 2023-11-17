/// A mode the `Parser` may currently be in.
enum ParsingMode {
    /// Parsing a discussion block of text for a header comment. A comment which uses "///". This is
    /// the text that appears at the bottom of the comment block.
    ///
    /// - Parameters:
    ///   - currentTokens: The tokens which will make up the discussion section text.
    ///
    case headerCommentDiscussion(currentTokens: [String])

    /// Parsing a general block of text for a header comment. A comment which uses "///". This is
    /// the text that appears at the top of the comment block.
    ///
    /// - Parameters:
    ///   - currentTokens: The tokens which will make up the general section text.
    ///
    case headerCommentGeneral(currentTokens: [String])

    /// Parsing a parameter block of a header comment. Parameters appear after the general text and
    /// before the return block.
    ///
    /// - Parameters:
    ///   - currentName: The name of the parameter.
    ///   - currentTokens: The tokens which will make up the parameter description.
    ///
    case headerCommentParameter(currentName: String, currentTokens: [String])

    /// Parsing a return block of a header comment. The return block, if it exists, is the last item
    /// in a header comment.
    ///
    /// - Parameters:
    ///   - currentTokens: The tokens which will make up the return description.
    ///
    case headerCommentReturn(currentTokens: [String])

    /// Parsing a simple in-line comment. A comment which uses "//".
    ///
    /// - Parameters:
    ///   - currentTokens: The tokens which will make up the comment text.
    ///
    case inlineComment(currentTokens: [String])

    /// Parsing a non-comment section of the source code.
    case noComment
}
