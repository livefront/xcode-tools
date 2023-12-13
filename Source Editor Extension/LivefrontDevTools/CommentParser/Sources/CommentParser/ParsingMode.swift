/// A mode the `Parser` may currently be in.
enum ParsingMode {
    /// Parsing a discussion block of text for a header comment. A comment which uses "///". This is
    /// the text that appears at the bottom of the comment block.
    case headerCommentDiscussion

    /// Parsing a general block of text for a header comment. A comment which uses "///". This is
    /// the text that appears at the top of the comment block.
    case headerCommentGeneral

    /// Parsing a parameter block of a header comment. Parameters appear after the general text and
    /// before the returns block.
    case headerCommentParameter

    /// Parsing a returns block of a header comment. The returns block appears after any parameters.
    case headerCommentReturns

    /// Parsing a throws block of a header comment. The throws block appears after any parameters or
    /// returns.
    case headerCommentThrows

    /// Parsing a simple in-line comment. A comment which uses "//".
    case inlineComment

    /// Parsing a non-comment section of the source code.
    case nonComment

    /// The parsing mode's corresponding comment type.
    var commentType: CommentType? {
        switch self {
        case .headerCommentDiscussion,
             .headerCommentGeneral,
             .headerCommentParameter,
             .headerCommentReturns,
             .headerCommentThrows:
                .header
        case .inlineComment:
                .inline
        case .nonComment:
            nil
        }
    }
}
