/// Models a single parameter in a header comment.
struct Parameter {
    /// The name of the parameter.
    let name: String

    /// The token strings of the parameter description.
    let tokens: [String]

    /// Formats the parameter as one of multiple parameters in a header comment block.
    ///
    /// - Parameter prefix: A string added to the beginning of each line of text.
    /// - Returns: An array of formatted lines.
    ///
    func asMultiParameterLines(prefix: String) -> [String] {
        tokens.formattedLines(
            prefix: prefix,
            firstLineStart: "   - \(name): ",
            additionalLineStart: "     "
        )
    }

    /// Formats the parameter as a sole parameter in a header comment block.
    ///
    /// - Parameter prefix: A string added to the beginning of each line of text.
    /// - Returns: An array of formatted lines.
    ///
    func asSingleParameterLines(prefix: String) -> [String] {
        tokens.formattedLines(
            prefix: prefix,
            firstLineStart: " - Parameter \(name): ",
            additionalLineStart: "   "
        )
    }

}
