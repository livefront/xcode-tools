/// A type of text line recognized by the parser.
enum LineType: Equatable {
    /// A line in a header comment containing only leading slashes and whitespace.
    case headerCommentBlank(targeted: Bool, text: String)

    /// A line in a header comment without any leading symbols or keywords indicating any particular
    /// context. This may be part of the general block of text or it might be an additional line in
    /// the description of a parameter, returns, or throws block.
    ///
    /// - Parameters:
    ///   - tokens: The whitespace-separated parts of the text.
    ///   - targeted: `true` iff this line was contained in a selection range.
    ///   - text: The original unmodified line of text.
    ///
    case headerCommentGeneral(tokens: [String], targeted: Bool, text: String)

    /// A line which signals the start or a parameter section in which there are multiple
    /// parameters.
    ///
    /// - Parameters:
    ///   - targeted: `true` iff this line was contained in a selection range.
    ///   - text: The original unmodified line of text.
    ///
    case headerCommentMultiParameterHeader(targeted: Bool, text: String)

    /// A line which signals the start of a parameter description block.
    ///
    /// - Parameters:
    ///   - name: The name of the parameter.
    ///   - tokens: The whitespace-separated parts of the text.
    ///   - targeted: `true` iff this line was contained in a selection range.
    ///   - text: The original unmodified line of text.
    ///
    case headerCommentParameterStart(name: String, tokens: [String], targeted: Bool, text: String)

    /// A line which signals the start of a returns description block.
    ///
    /// - Parameters:
    ///   - tokens: The whitespace-separated parts of the text.
    ///   - targeted: `true` iff this line was contained in a selection range.
    ///   - text: The original unmodified line of text.
    ///
    case headerCommentReturnsStart(tokens: [String], targeted: Bool, text: String)

    /// A line which signals the start of a throws description block.
    ///
    /// - Parameters:
    ///   - tokens: The whitespace-separated parts of the text.
    ///   - targeted: `true` iff this line was contained in a selection range.
    ///   - text: The original unmodified line of text.
    ///
    case headerCommentThrowsStart(tokens: [String], targeted: Bool, text: String)

    /// A line in a simple in-line comment containing only leading slashes and whitespace. If this
    /// line touches a header comment line it will be assumed that this line has a typo and should
    /// actually be part of the header comment.
    case inlineCommentBlank(targeted: Bool, text: String)

    /// A line in a simple in-line comment. A comment which uses "//". If this line touches a header
    /// comment line it will be assumed that this line has a typo and should actually be part of the
    /// header comment.
    ///
    /// - Parameters:
    ///   - tokens: The whitespace-separated parts of the text.
    ///   - targeted: `true` iff this line was contained in a selection range.
    ///   - text: The original unmodified line of text.
    ///
    case inlineCommentGeneral(tokens: [String], targeted: Bool, text: String)

    /// A non-comment line of source code.
    ///
    /// - Parameters:
    ///   - text: The original unmodified line of text.
    ///
    case nonComment(text: String)
}
