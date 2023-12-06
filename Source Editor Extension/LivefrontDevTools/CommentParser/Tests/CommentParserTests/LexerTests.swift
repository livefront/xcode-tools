import XCTest
@testable import CommentParser

final class LexerTests: XCTestCase {
    
    /// A blank line within a header comment should be interpreted as
    /// `LineType.headerCommentBlank`.
    func testHeaderCommentBlank() {
        // Normal
        XCTAssertEqual(
            Lexer.lineType("///", lineNumber: 0, targetRanges: [0...1]),
            .headerCommentBlank(
                targeted: true,
                text: "///"
            )
        )

        // Extra slashes typo
        XCTAssertEqual(
            Lexer.lineType("//////", lineNumber: 0, targetRanges: [0...1]),
            .headerCommentBlank(
                targeted: true,
                text: "//////"
            )
        )

        // Not targeted
        XCTAssertEqual(
            Lexer.lineType("///", lineNumber: 10, targetRanges: [0...1]),
            .headerCommentBlank(
                targeted: false,
                text: "///"
            )
        )

        // No target ranges
        XCTAssertEqual(
            Lexer.lineType("///", lineNumber: 0, targetRanges: []),
            .headerCommentBlank(
                targeted: true,
                text: "///"
            )
        )
    }

    /// A generic line within a header comment should be interpreted as
    /// `LineType.headerCommentGeneral`.
    func testHeaderCommentGeneral() {
        // Normal
        XCTAssertEqual(
            Lexer.lineType("/// Token", lineNumber: 0, targetRanges: [0...1]),
            .headerCommentGeneral(
                tokens: ["Token"],
                targeted: true,
                text: "/// Token"
            )
        )

        // Missing space typo
        XCTAssertEqual(
            Lexer.lineType("///Token", lineNumber: 0, targetRanges: [0...1]),
            .headerCommentGeneral(
                tokens: ["Token"],
                targeted: true,
                text: "///Token"
            )
        )

        // Extra slashes typo
        XCTAssertEqual(
            Lexer.lineType("///// Token", lineNumber: 0, targetRanges: [0...1]),
            .headerCommentGeneral(
                tokens: ["Token"],
                targeted: true,
                text: "///// Token"
            )
        )

        // Missing space plus extra slashes typo
        XCTAssertEqual(
            Lexer.lineType("/////Token", lineNumber: 0, targetRanges: [0...1]),
            .headerCommentGeneral(
                tokens: ["Token"],
                targeted: true,
                text: "/////Token"
            )
        )

        // Not targeted
        XCTAssertEqual(
            Lexer.lineType("/// Token", lineNumber: 10, targetRanges: [0...1]),
            .headerCommentGeneral(
                tokens: ["Token"],
                targeted: false,
                text: "/// Token"
            )
        )

        // No target ranges
        XCTAssertEqual(
            Lexer.lineType("/// Token", lineNumber: 0, targetRanges: []),
            .headerCommentGeneral(
                tokens: ["Token"],
                targeted: true,
                text: "/// Token"
            )
        )
    }

    /// The beginning of a multi-parameter block should be interpreted as
    /// `LineType.headerCommentMultiParameterHeader`.
    func testHeaderCommentMultiParameterHeader() {
        // Normal
        XCTAssertEqual(
            Lexer.lineType("/// - Parameters:", lineNumber: 0, targetRanges: [0...1]),
            .headerCommentMultiParameterHeader(
                targeted: true,
                text: "/// - Parameters:"
            )
        )

        // Slash typo
        XCTAssertEqual(
            Lexer.lineType("// - Parameters:", lineNumber: 0, targetRanges: [0...1]),
            .headerCommentMultiParameterHeader(
                targeted: true,
                text: "// - Parameters:"
            )
        )

        // Not targeted
        XCTAssertEqual(
            Lexer.lineType("/// - Parameters:", lineNumber: 10, targetRanges: [0...1]),
            .headerCommentMultiParameterHeader(
                targeted: false,
                text: "/// - Parameters:"
            )
        )

        // No target ranges
        XCTAssertEqual(
            Lexer.lineType("/// - Parameters:", lineNumber: 0, targetRanges: []),
            .headerCommentMultiParameterHeader(
                targeted: true,
                text: "/// - Parameters:"
            )
        )
    }

    /// The first line of a parameter within a multi-parameter block should be interpreted as
    /// `LineType.headerCommentParameterStart`.
    func testHeaderCommentParameterStartMultiParameter() {
        // Normal
        XCTAssertEqual(
            Lexer.lineType("/// - name: Token", lineNumber: 0, targetRanges: [0...1]),
            .headerCommentParameterStart(
                name: "name",
                tokens: ["Token"],
                targeted: true,
                text: "/// - name: Token"
            )
        )

        // Slash typo
        XCTAssertEqual(
            Lexer.lineType("// - name: Token", lineNumber: 0, targetRanges: [0...1]),
            .headerCommentParameterStart(
                name: "name",
                tokens: ["Token"],
                targeted: true,
                text: "// - name: Token"
            )
        )

        // Not targeted
        XCTAssertEqual(
            Lexer.lineType("/// - name: Token", lineNumber: 10, targetRanges: [0...1]),
            .headerCommentParameterStart(
                name: "name",
                tokens: ["Token"],
                targeted: false,
                text: "/// - name: Token"
            )
        )

        // No target ranges
        XCTAssertEqual(
            Lexer.lineType("/// - name: Token", lineNumber: 0, targetRanges: []),
            .headerCommentParameterStart(
                name: "name",
                tokens: ["Token"],
                targeted: true,
                text: "/// - name: Token"
            )
        )
    }

    /// The first line of a sole parameter block should be interpreted as
    /// `LineType.headerCommentParameterStart`.
    func testHeaderCommentParameterStartSoleParameter() {
        // Normal
        XCTAssertEqual(
            Lexer.lineType("/// - Parameter name: Token", lineNumber: 0, targetRanges: [0...1]),
            .headerCommentParameterStart(
                name: "name",
                tokens: ["Token"],
                targeted: true,
                text: "/// - Parameter name: Token"
            )
        )

        // Slash typo
        XCTAssertEqual(
            Lexer.lineType("// - Parameter name: Token", lineNumber: 0, targetRanges: [0...1]),
            .headerCommentParameterStart(
                name: "name",
                tokens: ["Token"],
                targeted: true,
                text: "// - Parameter name: Token"
            )
        )

        // Not targeted
        XCTAssertEqual(
            Lexer.lineType("/// - Parameter name: Token", lineNumber: 10, targetRanges: [0...1]),
            .headerCommentParameterStart(
                name: "name",
                tokens: ["Token"],
                targeted: false,
                text: "/// - Parameter name: Token"
            )
        )

        // No target ranges
        XCTAssertEqual(
            Lexer.lineType("/// - Parameter name: Token", lineNumber: 0, targetRanges: []),
            .headerCommentParameterStart(
                name: "name",
                tokens: ["Token"],
                targeted: true,
                text: "/// - Parameter name: Token"
            )
        )
    }

    /// The first line of a return value description should be interpreted as
    /// `LineType.headerCommentReturnStart`.
    func testHeaderCommentReturnStart() {
        // Normal
        XCTAssertEqual(
            Lexer.lineType("/// - Returns: Token", lineNumber: 0, targetRanges: [0...1]),
            .headerCommentReturnStart(
                tokens: ["Token"],
                targeted: true,
                text: "/// - Returns: Token"
            )
        )

        // Slash typo
        XCTAssertEqual(
            Lexer.lineType("// - Returns: Token", lineNumber: 0, targetRanges: [0...1]),
            .headerCommentReturnStart(
                tokens: ["Token"],
                targeted: true,
                text: "// - Returns: Token"
            )
        )

        // Not targeted
        XCTAssertEqual(
            Lexer.lineType("/// - Returns: Token", lineNumber: 10, targetRanges: [0...1]),
            .headerCommentReturnStart(
                tokens: ["Token"],
                targeted: false,
                text: "/// - Returns: Token"
            )
        )

        // No target ranges
        XCTAssertEqual(
            Lexer.lineType("/// - Returns: Token", lineNumber: 0, targetRanges: []),
            .headerCommentReturnStart(
                tokens: ["Token"],
                targeted: true,
                text: "/// - Returns: Token"
            )
        )
    }

    /// A blank line within an in-line comment should be interpreted as
    /// `LineType.inlineCommentBlank`.
    func testInlineCommentBlank() {
        // Normal
        XCTAssertEqual(
            Lexer.lineType("//", lineNumber: 0, targetRanges: [0...1]),
            .inlineCommentBlank(
                targeted: true,
                text: "//"
            )
        )

        // Not targeted
        XCTAssertEqual(
            Lexer.lineType("//", lineNumber: 10, targetRanges: [0...1]),
            .inlineCommentBlank(
                targeted: false,
                text: "//"
            )
        )

        // No target ranges
        XCTAssertEqual(
            Lexer.lineType("//", lineNumber: 0, targetRanges: []),
            .inlineCommentBlank(
                targeted: true,
                text: "//"
            )
        )
    }

    /// A generic line within an in-line comment should be interpreted as
    /// `LineType.inlineCommentGeneral`.
    func testInlineCommentGeneral() {
        // Normal
        XCTAssertEqual(
            Lexer.lineType("// Token", lineNumber: 0, targetRanges: [0...1]),
            .inlineCommentGeneral(
                tokens: ["Token"],
                targeted: true,
                text: "// Token"
            )
        )

        // Missing space typo
        XCTAssertEqual(
            Lexer.lineType("//Token", lineNumber: 0, targetRanges: [0...1]),
            .inlineCommentGeneral(
                tokens: ["Token"],
                targeted: true,
                text: "//Token"
            )
        )

        // Not targeted
        XCTAssertEqual(
            Lexer.lineType("// Token", lineNumber: 10, targetRanges: [0...1]),
            .inlineCommentGeneral(
                tokens: ["Token"],
                targeted: false,
                text: "// Token"
            )
        )

        // No target ranges
        XCTAssertEqual(
            Lexer.lineType("// Token", lineNumber: 0, targetRanges: []),
            .inlineCommentGeneral(
                tokens: ["Token"],
                targeted: true,
                text: "// Token"
            )
        )
    }

    /// A non-comment line of source code should be interpreted as `LineType.nonComment`.
    func testNonComment() {
        XCTAssertEqual(
            Lexer.lineType("Text", lineNumber: 0, targetRanges: [0...1]),
            .nonComment(
                text: "Text"
            )
        )
    }

}
