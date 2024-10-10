// MARK: - BlockType

/// The type of the code block to be sorted. The blocks will be sorted first by type
/// (property vs function, etc) in the order of the integer raw values, and then alphabetically
/// within types (propertyA before propertyB, etc).
///
enum BlockType: Int, CaseIterable {
    // MARK: Cases

    /// An import and any associated comments.
    case importType = 0

    /// A typealias and any associated comments.
    case alias = 1

    /// A nested struct, class, or other type and any associated comments or body.
    case nestedType = 2

    /// A property and any associated comments or body.
    case property = 3

    /// A function and any associated comments or body.
    case function = 4

    /// An initialization function and any associated comments or body.
    case initType = 5

    // MARK: Properties

    /// The keywords of code that represent each type of block.
    var keywords: [String] {
        switch self {
        case .importType:
            ["import"]
        case .alias:
            ["typealias"]
        case .nestedType:
            ["struct", "class", "actor", "enum", "extension", "protocol"]
        case .property:
            ["var", "let", "case"]
        case .function:
            ["func"]
        case .initType:
            ["init"]
        }
    }
}
