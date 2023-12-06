import Foundation

/// Functions for tokenizing and classifying raw lines of input.
enum Lexer {
    /// Tokenizes the given line of text and classifies it as one of the line types supported by the
    /// parser.
    ///
    /// - Parameters:
    ///   - text: The original line of text.
    ///   - lineNumber: The zero-indexed line number of the line.
    ///   - targetRanges: The collection of zero-indexed line number ranges of currently selected
    ///     lines of text.
    /// - Returns: The identified line type with tokenized data.
    ///
    static func lineType(
        _ text: String,
        lineNumber: Int,
        targetRanges: [ClosedRange<Int>]
    ) -> LineType {
        let targeted = targetRanges.isEmpty || targetRanges.contains { $0.contains(lineNumber) }

        // Split line by whitespace into tokens.
        var tokens = text
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }

        // Detect and correct a missing space after comment slashes.
        if tokens.first?.starts(with: "//") ?? false {
            let originalFirstToken = tokens.removeFirst()

            // Remove all leading slashes from the token and insert the remaining string as a
            // separate token.
            if let firstNonSlashIndex = originalFirstToken.firstIndex(where: { $0 != "/" }) {
                let remainder = String(originalFirstToken.suffix(from: firstNonSlashIndex))
                tokens.insert(remainder, at: 0)
            }

            // Add back the slashes.
            if originalFirstToken.starts(with: "///") {
                tokens.insert("///", at: 0)
            } else {
                tokens.insert("//", at: 0)
            }
        }

        // Detect the beginning of a return block.
        // Ex: /// - Returns: …
        if tokens.starts(with: ["///", "-", "Returns:"]) ||
           tokens.starts(with: ["//", "-", "Returns:"]) {
            return .headerCommentReturnStart(
                tokens: Array(tokens.dropFirst(3)),
                targeted: targeted,
                text: text
            )
        }

        // Detect the beginning of a multiple parameter block.
        // Ex: /// - Parameters:
        if tokens.starts(with: ["///", "-", "Parameters:"]) ||
           tokens.starts(with: ["//", "-", "Parameters:"]) {
            return .headerCommentMultiParameterHeader(targeted: targeted, text: text)
        }

        // Detect the beginning of a sole parameter block.
        // Ex: /// - Parameter name: …
        if (tokens.starts(with: ["///", "-", "Parameter"]) ||
            tokens.starts(with: ["//", "-", "Parameter"])),
           tokens.count >= 4,
           tokens[3].hasSuffix(":") {
            return .headerCommentParameterStart(
                name: String(tokens[3].dropLast()),
                tokens: Array(tokens.dropFirst(4)),
                targeted: targeted,
                text: text
            )
        }

        // Detect the beginning a parameter block within a multiple parameter block.
        // Ex: ///   - name: …
        if (tokens.starts(with: ["///", "-"]) ||
            tokens.starts(with: ["//", "-"])),
           tokens.count >= 3,
           tokens[2].hasSuffix(":") {
            return .headerCommentParameterStart(
                name: String(tokens[2].dropLast()),
                tokens: Array(tokens.dropFirst(3)),
                targeted: targeted,
                text: text
            )
        }

        // Detect a blank comment line within a header comment.
        // Ex: ///
        if tokens == ["///"] {
            return .headerCommentBlank(targeted: targeted, text: text)
        }

        // Detect a blank comment line within an in-line comment.
        // Ex: //
        if tokens == ["//"] {
            return .inlineCommentBlank(targeted: targeted, text: text)
        }

        // Detect a generic comment line within a header comment.
        // Ex: /// This is a comment.
        if tokens.starts(with: ["///"]) {
            return .headerCommentGeneral(
                tokens: Array(tokens.dropFirst()),
                targeted: targeted,
                text: text
            )
        }

        // Detect an in-line comment line.
        // Ex: // This is not a header comment.
        if tokens.starts(with: ["//"]) {
            return .inlineCommentGeneral(
                tokens: Array(tokens.dropFirst()),
                targeted: targeted,
                text: text
            )
        }

        // Default to a non-comment line of source code.
        return .nonComment(text: text)
    }
}
