import Foundation

/// An object that used to group sortable blocks of Swift code, such as a variable with preceding
/// comments or a function with documentation comments and a body of code.
///
class Block {
    // MARK: Properties

    /// The content of the block that will be placed into alphabetical order (such as the variable
    /// declaration or function).
    var content: [String]

    /// Manually track when a block of code is completed (comments, for example, are
    /// definitionally incomplete).
    var isComplete: Bool

    /// The word used to sort the block (such as the variable or function name).
    var key: String

    /// Keep track of the number of opening and closing brackets to know when the block of
    /// code is completed.
    var parensCount: Int?

    /// The type of the code block.
    var type: BlockType?

    // MARK: Initialization

    /// Initializes a new `Block`.
    ///
    /// - Parameters:
    ///   - content: The content of the block of code.
    ///   - key: The word used to sort the block.
    ///   - parensCount: The net number of opening and closing brackets in the block.
    ///   - type: The type of the code block.
    ///
    init(content: [String], key: String, parensCount: Int?, type: BlockType) {
        self.content = content
        isComplete = parensCount == 0
        self.key = key
        self.parensCount = parensCount
        self.type = type
    }

    /// Initializes a new `Block`.
    ///
    /// - Parameters:
    ///   - content: The content of the block of code.
    ///   - isComplete: If the code block is complete or not.
    ///   - key: The word used to sort the block.
    ///
    init(content: [String], isComplete: Bool, key: String) {
        self.content = content
        self.isComplete = isComplete
        self.key = key
    }
}

/// The blocks will be sorted first by type (property vs function, etc), then alphabetically within types.
enum BlockType: Int, CaseIterable {
    /// A typealias as its associated comments.
    case alias = 0

    /// A nested struct or class.
    case nestedType = 1

    /// A property and its associated comments or body.
    case property = 2

    /// A function and its associated comments or body.
    case function = 3
}

extension String {
    /// Determine if a string (representing a line of code) is one of the types used for sorting code into blocks.
    func blockType() -> BlockType? {
        if contains("typealias") { return .alias }

        if contains("struct") || contains("class") || contains("enum") { return .nestedType }

        if contains("var") || contains("let") { return .property }

        if contains("func") { return .function }

        return nil
    }

    /// Determine the name to use for sorting by looking at the word right after the keyword.
    func name(ofType type: BlockType) -> String {
        // Separate the line of code by spaces.
        let parsed = components(separatedBy: .whitespacesAndNewlines)

        // Search the string for the relevant keyword depending on the type.
        var index = 0
        switch type {
        case .alias:
            index = parsed.firstIndex(of: "typealias") ?? 0
        case .nestedType:
            index = parsed.firstIndex(of: "struct") ??
                parsed.firstIndex(of: "class") ??
                parsed.firstIndex(of: "enum") ?? 0
        case .property:
            index = parsed.firstIndex(of: "var") ??
                parsed.firstIndex(of: "let") ?? 0
        case .function:
            index = parsed.firstIndex(of: "func") ?? 0
        }

        // Return the word right after the relevant keyword.
        return parsed[index + 1]
    }
}
