// MARK: - Block

/// An object that is used to group sortable blocks of Swift code, such as a variable with preceding
/// comments or a function with documentation comments and a body of code.
///
struct Block {
    // MARK: Properties

    /// The content of the block that will be placed into alphabetical order (such as the variable
    /// declaration or function).
    var content: [String] = []

    /// The word used to sort the block (such as the variable or function name).
    var key = ""

    /// The line of code containing the type and keyword.
    var keyLine: String?

    /// Keep track of the net number of opening and closing parentheses, brackets, or angle brackets
    /// to know when the block of code is completed.
    var netParens = 0

    /// The type of the code block.
    var type: BlockType?

    // MARK: Computed Properties

    /// Determine if a block is complete.
    var isComplete: Bool {
        type != nil &&
            (!key.isEmpty || type == .initType) &&
            !content.isEmpty &&
            netParens == 0
    }
}
