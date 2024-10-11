// MARK: StringExtensions

extension String {
    // MARK: Properties

    /// Determine if a string (representing a line of code) is one of the `BlockType`s used for
    /// sorting code into blocks.
    var blockType: BlockType? {
        for blockType in BlockType.allCases where contains(any: blockType.keywords) {
            return blockType
        }
        return nil
    }

    /// Return only the lowercased letters and numbers of a string, ignoring special characters.
    var lowercasedNonSpecial: String { filter { $0.isLetter || $0.isNumber }.lowercased() }

    // MARK: Methods

    /// Determines if a string contains any of substrings included in the array.
    ///
    /// - Parameter strings: The array of substrings that the string might contain.
    /// - Returns: `true` if the string contains any of the substrings from the array.
    ///
    func contains(any strings: [String]) -> Bool {
        strings.contains { contains($0) }
    }

    /// Determine the name to use for sorting by looking at the word right after the keyword.
    ///
    /// - Parameter type: The `BlockType` of the string used to search for the keyword.
    /// - Returns: The substring that appears immediately after the keyword of the string.
    ///
    func name(ofType type: BlockType) -> String {
        // Separate the line of code by spaces.
        let parsed = components(separatedBy: .whitespacesAndNewlines)

        // Find the index of the keyword that defines the type.
        let index = type.keywords.compactMap { parsed.firstIndex(of: $0) }.first ?? 0

        // Return the word immediately following the keyword.
        return parsed[index + 1].lowercasedNonSpecial
    }
}
