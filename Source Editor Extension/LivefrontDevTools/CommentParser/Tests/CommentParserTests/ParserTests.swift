import XCTest
@testable import CommentParser

final class CommentParserTests: XCTestCase {
    
    /// A long discussion portion of a header comment should wrap to multiple lines.
    func testHeaderCommentDiscussionLong() {
        let input = """
/// This is general comment text that will have to wrap to multiple lines even when it is indented all the way to the left.
///
/// This is a discussion block that will be formatted separately from the general comment text because there is a blank line between them.
"""
        let expected = """
/// This is general comment text that will have to wrap to multiple lines even when it is indented
/// all the way to the left.
///
/// This is a discussion block that will be formatted separately from the general comment text
/// because there is a blank line between them.
"""
        verifyFormat(input: input, expected: expected, targetRanges: [])
    }

    /// A short discussion portion of a header comment should not wrap to multiple lines.
    func testHeaderCommentDiscussionShort() {
        let input = """
/// This is general comment text that will have to wrap to multiple lines even when it is indented all the way to the left.
///
/// This is a discussion block that will be formatted separately from the general comment.
"""
        let expected = """
/// This is general comment text that will have to wrap to multiple lines even when it is indented
/// all the way to the left.
///
/// This is a discussion block that will be formatted separately from the general comment.
"""
        verifyFormat(input: input, expected: expected, targetRanges: [])
    }

    /// An empty header comment should be removed.
    func testHeaderCommentEmpty() throws {
        let input = """
///
"""
        let expected = """
"""
        verifyFormat(input: input, expected: expected, targetRanges: [])
    }

    /// A header comment with long general text, discussion, parameters, and return should all wrap
    /// and format as expected.
    func testHeaderCommentFull() {
        let input = """
/// This is general comment text that will have to wrap to multiple lines even when it is indented all the way to the left.
/// - Parameters:
///   - paramA: This is parameter A's description.
///       It will have to wrap even when it is indented all the way to the left.
///   - paramB: This is parameter B's description.
/// - Returns: This is the description of the return value.
///     It will have to wrap even when it is indented all the way to the left.
///
/// This is a discussion block that will be formatted separately from the general comment text because there is a blank line between them.
"""
        let expected = """
/// This is general comment text that will have to wrap to multiple lines even when it is indented
/// all the way to the left.
///
/// - Parameters:
///   - paramA: This is parameter A's description. It will have to wrap even when it is indented all
///     the way to the left.
///   - paramB: This is parameter B's description.
/// - Returns: This is the description of the return value. It will have to wrap even when it is
///   indented all the way to the left.
///
/// This is a discussion block that will be formatted separately from the general comment text
/// because there is a blank line between them.
"""
        verifyFormat(input: input, expected: expected, targetRanges: [])
    }

    /// A long general header comment should wrap to multiple lines.
    func testHeaderCommentGeneralLong() {
        let input = """
/// This is general comment text that will have to wrap to multiple lines even when it is indented all the way to the left.
"""
        let expected = """
/// This is general comment text that will have to wrap to multiple lines even when it is indented
/// all the way to the left.
"""
        verifyFormat(input: input, expected: expected, targetRanges: [])
    }

    /// A short general header comment should not wrap.
    func testHeaderCommentGeneralShort() {
        let input = """
/// This is general comment text that will not wrap.
"""
        let expected = """
/// This is general comment text that will not wrap.
"""
        verifyFormat(input: input, expected: expected, targetRanges: [])
    }

    /// A header comment with multiple parameters should be correctly formatted including line
    /// wrapping.
    func testHeaderCommentParameterMultiple() {
        let input = """
/// - Parameters:
///   - paramA: This is parameter A's description. It will have to wrap even when it is indented all the way to the left.
///   - paramB: This is parameter B's description.
"""
        let expected = """
/// - Parameters:
///   - paramA: This is parameter A's description. It will have to wrap even when it is indented all
///     the way to the left.
///   - paramB: This is parameter B's description.
///
"""
        verifyFormat(input: input, expected: expected, targetRanges: [])
    }

    /// A header comment with a single long parameter description should wrap to multiple lines.
    func testHeaderCommentParameterSingleLong() {
        let input = """
/// - Parameter paramA: This is parameter A's description. It will have to wrap even when it is indented all the way to the left.
"""
        let expected = """
/// - Parameter paramA: This is parameter A's description. It will have to wrap even when it is
///   indented all the way to the left.
///
"""
        verifyFormat(input: input, expected: expected, targetRanges: [])
    }

    /// A header comment with a single short parameter description should not wrap.
    func testHeaderCommentParameterSingleShort() {
        let input = """
/// - Parameter paramA: This is parameter A's description.
"""
        let expected = """
/// - Parameter paramA: This is parameter A's description.
///
"""
        verifyFormat(input: input, expected: expected, targetRanges: [])
    }

    /// A header comment with a single parameter currently formatted in a multi-parameter block
    /// should be reformatted in the single-parameter style.
    func testHeaderCommentParameterSingleAlternate() {
        let input = """
/// - Parameters:
///   - paramA: This is parameter A's description. It will have to wrap even when it is indented all the way to the left.
"""
        let expected = """
/// - Parameter paramA: This is parameter A's description. It will have to wrap even when it is
///   indented all the way to the left.
///
"""
        verifyFormat(input: input, expected: expected, targetRanges: [])
    }

    /// A header comment with a long returns description should wrap to multiple lines.
    func testHeaderCommentReturnsLong() {
        let input = """
/// - Returns: This is the description of the return value. It will have to wrap even when it is indented all the way to the left.
"""
        let expected = """
/// - Returns: This is the description of the return value. It will have to wrap even when it is
///   indented all the way to the left.
///
"""
        verifyFormat(input: input, expected: expected, targetRanges: [])
    }

    /// A header comment with a short returns description should not wrap.
    func testHeaderCommentReturnsShort() {
        let input = """
/// - Returns: This is the description of the return value.
"""
        let expected = """
/// - Returns: This is the description of the return value.
///
"""
        verifyFormat(input: input, expected: expected, targetRanges: [])
    }

    /// When an in-line comment line touches the top of a header comment line, we should assume the
    /// in-line slashes were actually a typo and should be merged with the header comment.
    func testHeaderCommentWithInlineAbove() throws {
        let input = """
// This is general comment text with a typo. It was supposed to have three leading slashes. Because it touches a comment block with three leading slashes, they will be merged.
/// This is the additional comment text which will be merged with the touching text.
"""
        let expected = """
/// This is general comment text with a typo. It was supposed to have three leading slashes. Because
/// it touches a comment block with three leading slashes, they will be merged. This is the
/// additional comment text which will be merged with the touching text.
"""
        verifyFormat(input: input, expected: expected, targetRanges: [])
    }

    /// When an in-line comment line touches the bottom of a header comment line, we should assume
    /// the in-line slashes were actually a typo and should be merged with the header comment.
    func testHeaderCommentWithInlineBelow() throws {
        let input = """
/// This is the additional comment text which will be merged with the touching text.
// This is general comment text with a typo. It was supposed to have three leading slashes. Because it touches a comment block with three leading slashes, they will be merged.
"""
        let expected = """
/// This is the additional comment text which will be merged with the touching text. This is general
/// comment text with a typo. It was supposed to have three leading slashes. Because it touches a
/// comment block with three leading slashes, they will be merged.
"""
        verifyFormat(input: input, expected: expected, targetRanges: [])
    }

    /// When a line of source code touches the bottom of a header comment, the header comment should
    /// adopt the indentation of the source code line.
    func testIndentationCodeMatched() {
        let input = """
     /// The indentation follows
/// the code line after
            /// the comment block.
                                            func someCode() {
"""
        let expected = """
                                            /// The indentation follows the code line after the
                                            /// comment block.
                                            func someCode() {
"""
        verifyFormat(input: input, expected: expected, targetRanges: [])
    }

    /// Comments that are indented past the 100 character limit should respect their original
    /// indentation and each wrapped line should include at least one token.
    func testIndentationBeyondLimit() {
        let input = """
                                                                                                     /// The indentation follows
                                                                                                /// the first line of
                                                                                                            /// the comment block
                                                                                                  /// when there is no
                                                                                                       /// following code line.
                                                                                                    /// - Parameter paramA: The description for parameter A.
"""
        let expected = """
                                                                                                     /// The
                                                                                                     /// indentation
                                                                                                     /// follows
                                                                                                     /// the
                                                                                                     /// first
                                                                                                     /// line
                                                                                                     /// of
                                                                                                     /// the
                                                                                                     /// comment
                                                                                                     /// block
                                                                                                     /// when
                                                                                                     /// there
                                                                                                     /// is
                                                                                                     /// no
                                                                                                     /// following
                                                                                                     /// code
                                                                                                     /// line.
                                                                                                     ///
                                                                                                     /// - Parameter paramA: The
                                                                                                     ///   description
                                                                                                     ///   for
                                                                                                     ///   parameter
                                                                                                     ///   A.
                                                                                                     ///
"""
        verifyFormat(input: input, expected: expected, targetRanges: [])
    }

    /// When a comment block has mismatched indentation and no following code line, the indentation
    /// of the first comment line should be used to indent the following lines.
    func testIndentationSelfDetermined() {
        let input = """
     /// The indentation follows
/// the first line of
            /// the comment block
  /// when there is no
       /// following code line.
"""
        let expected = """
     /// The indentation follows the first line of the comment block when there is no following code
     /// line.
"""
        verifyFormat(input: input, expected: expected, targetRanges: [])
    }

    /// A long in-line comment should wrap to multiple lines.
    func testInlineCommentLong() throws {
        let input = """
// This is a simple in-line comment. It will have to wrap even when it is indented all the way to the left.
"""
        let expected = """
// This is a simple in-line comment. It will have to wrap even when it is indented all the way to
// the left.
"""
        verifyFormat(input: input, expected: expected, targetRanges: [])
    }

    /// A short in-line comment should not wrap.
    func testInlineCommentShort() throws {
        let input = """
// This is a simple in-line comment.
"""
        let expected = """
// This is a simple in-line comment.
"""
        verifyFormat(input: input, expected: expected, targetRanges: [])
    }

    /// An empty in-line comment should be removed.
    func testInlineCommentEmpty() throws {
        let input = """
//
"""
        let expected = """
"""
        verifyFormat(input: input, expected: expected, targetRanges: [])
    }

    /// The formatter should be able to handle multiple comment blocks in various states of 
    /// disarray.
    func testMixedCommentComplex() {
        let input = """
/// This is general comment text that will have to wrap to multiple lines even when it is indented all the way to the left.
/// This is more of the general comment text.
//
/// This is a discussion block that will be formatted separately from the general comment text because there is a blank line between them.
/// - Returns: This will appear at the beginning of the return description.
//
/// Some more discussion.
//
/// - Parameters:
///   - paramA: This is parameter A's description.
///       It will have to wrap even when it is indented all the way to the left.
//
///   - paramB: This is parameter B's description.
///
///  - paramC: This is parameter C's description.
/// - Parameters:
/// - Returns: This is the description of the return value.
///     It will have to wrap even when it is indented all the way to the left.
///  - paramD: This is parameter D's description.
// This also belongs to D.
///
/// More discussion.
///
/// Even more discussion.
//  This is still part of the discussion.
/// - Returns: This will be added to the the original return description.

// General
/// text
/// - Returns: Some
/// - Returns: description
// text
/// - Returns: which combines
/// - Parameters:
///
/// - paramA: This is parameter A's description.
///
/// Discussion text followed by a non-comment line.
not a comment

/// General text followed by a non-comment line.
still not a comment

///  - paramA: This is parameter A's description.
no comment

// Inline becomes header description.
//
///

// Inline mode ignores
// parameter header.
/// - Parameters:

// Inline becomes header description.
/// - paramA: This is parameter A's description.

// Inline becomes header description.
/// - Returns: Some value.
"""
        let expected = """
/// This is general comment text that will have to wrap to multiple lines even when it is indented
/// all the way to the left. This is more of the general comment text.
///
/// - Parameters:
///   - paramA: This is parameter A's description. It will have to wrap even when it is indented all
///     the way to the left.
///   - paramB: This is parameter B's description.
///   - paramC: This is parameter C's description.
///   - paramD: This is parameter D's description. This also belongs to D.
/// - Returns: This will appear at the beginning of the return description. This is the description
///   of the return value. It will have to wrap even when it is indented all the way to the left.
///   This will be added to the the original return description.
///
/// This is a discussion block that will be formatted separately from the general comment text
/// because there is a blank line between them. Some more discussion. More discussion. Even more
/// discussion. This is still part of the discussion.

/// General text
///
/// - Parameter paramA: This is parameter A's description.
/// - Returns: Some description text which combines
///
/// Discussion text followed by a non-comment line.
not a comment

/// General text followed by a non-comment line.
still not a comment

/// - Parameter paramA: This is parameter A's description.
///
no comment

/// Inline becomes header description.

// Inline mode ignores parameter header.

/// Inline becomes header description.
///
/// - Parameter paramA: This is parameter A's description.
///

/// Inline becomes header description.
///
/// - Returns: Some value.
///
"""
        verifyFormat(input: input, expected: expected, targetRanges: [])
    }

    /// Only comment blocks which intersect with the given target ranges should be formatted. If any
    /// line of a comment block is in a target range, the entire comment block will be formatted.
    func testMixedCommentSelectiveTargeting() {
        let input = """
/// This is general comment text that will have to wrap to multiple lines even when it is indented all the way to the left.
/// This is more of the general comment text.
///
/// Discussion
/// - Parameters:
///   - paramA: This is parameter A's description.
///       It will have to wrap even when it is indented all the way to the left.
//
///   - paramB: This is parameter B's description.
///
/// - Returns: This is the description of the return value.
///     It will have to wrap even when it is indented all the way to the left.

///  - paramA: This is parameter A's description.
no comment

// Inline becomes header description.
//
///

// Inline mode ignores
// parameter header.
/// - Parameters:

// Inline becomes header description.
/// - Returns: Some value.
"""
        let expected = """
/// This is general comment text that will have to wrap to multiple lines even when it is indented
/// all the way to the left. This is more of the general comment text.
///
/// - Parameters:
///   - paramA: This is parameter A's description. It will have to wrap even when it is indented all
///     the way to the left.
///   - paramB: This is parameter B's description.
/// - Returns: This is the description of the return value. It will have to wrap even when it is
///   indented all the way to the left.
///
/// Discussion

///  - paramA: This is parameter A's description.
no comment

/// Inline becomes header description.

// Inline mode ignores
// parameter header.
/// - Parameters:

// Inline becomes header description.
/// - Returns: Some value.
"""
        verifyFormat(input: input, expected: expected, targetRanges: [0...2, 15...16])
    }

    // MARK: Helper Functions

    /// Parses and formats the input then compares it against the expected result.
    /// - Parameters:
    ///   - input: The input text.
    ///   - expected: The expected formatted result.
    ///   - targetRanges: The selected line ranges within the input text.
    ///   - file: The file where this function was called.
    ///   - line: The line where this function was called.
    func verifyFormat(
        input: String,
        expected: String,
        targetRanges: [ClosedRange<Int>],
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let parser = Parser(targetRanges: targetRanges)
        var lineNumber = 0
        input.enumerateLines { line, stop in
            parser.parseLine(line, lineNumber: lineNumber)
            lineNumber += 1
        }
        let result = parser.generateOutput().joined(separator: "\n")

        XCTAssertEqual("\n" + result + "\n", "\n" + expected + "\n", file: file, line: line)
    }
}
