/// Models a return description in a header comment.
struct Return {
    /// The token strings of the return description.
    let tokens: [String]

    /// Formats the return description for a header comment block.
    ///
    /// - Parameter prefix: A string added to the beginning of each line of text.
    /// - Returns: An array of formatted lines.
    ///
    func asReturnLines(prefix: String) -> [String] {
        tokens.formattedLines(
            prefix: prefix,
            firstLineStart: " - Returns: ",
            additionalLineStart: "   "
        )
    }
}
