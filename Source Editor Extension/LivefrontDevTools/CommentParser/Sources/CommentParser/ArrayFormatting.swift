/// The maximum number of characters a line of source code is typically allowed to have.
private let lineLengthLimit = 100

extension Array where Element == String {

    /// Formats an array of string tokens in the style of a general comment block of text.
    ///
    /// - Parameter prefix: A string added to the beginning of each line of text.
    /// - Returns: An array of formatted lines.
    ///
    func asGeneralCommentLines(prefix: String) -> [String] {
        formattedLines(
            prefix: prefix,
            firstLineStart: " ",
            additionalLineStart: " "
        )
    }

    /// Formats an array of string tokens in the style of the returns description for a header
    /// comment block.
    ///
    /// - Parameter prefix: A string added to the beginning of each line of text.
    /// - Returns: An array of formatted lines.
    ///
    func asReturnsLines(prefix: String) -> [String] {
        formattedLines(
            prefix: prefix,
            firstLineStart: " - Returns: ",
            additionalLineStart: "   "
        )
    }

    /// Formats an array of string tokens in the style of the throws description for a header
    /// comment block.
    ///
    /// - Parameter prefix: A string added to the beginning of each line of text.
    /// - Returns: An array of formatted lines.
    ///
    func asThrowsLines(prefix: String) -> [String] {
        formattedLines(
            prefix: prefix,
            firstLineStart: " - Throws: ",
            additionalLineStart: "   "
        )
    }

    /// Combines the array of string tokens into a single block of text. The trailing edge of the
    /// block should attempt to stay under line length limit if possible.
    ///
    /// - Parameters:
    ///   - prefix: A string added to the beginning of each line of text.
    ///   - firstLineStart: An additional string to add after the prefix on the first line only.
    ///   - additionalLineStart: An additional string to add after the prefix for all lines except
    ///     the first line.
    /// - Returns: An array of formatted lines.
    ///
    func formattedLines(
        prefix: String,
        firstLineStart: String,
        additionalLineStart: String
    ) -> [String] {
        var currentCombinedPrefix = prefix + firstLineStart
        var currentLine = currentCombinedPrefix
        var lines = [String]()
        for token in self {
            if currentLine == currentCombinedPrefix {
                currentLine = currentLine + token
            } else if (currentLine + " " + token).count <= lineLengthLimit {
                currentLine = currentLine + " " + token
            } else {
                lines.append(currentLine)
                currentCombinedPrefix = prefix + additionalLineStart
                currentLine = currentCombinedPrefix + token
            }
        }
        lines.append(currentLine)
        return lines
    }
}
