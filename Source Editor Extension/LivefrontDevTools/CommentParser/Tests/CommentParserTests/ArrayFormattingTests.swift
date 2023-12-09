import XCTest
@testable import CommentParser

final class ArrayFormattingTests: XCTestCase {
    
    /// `asGeneralCommentLines` should apply line-wrapping formatting with the given prefix and no
    /// additional starting text to any line.
    func testAsGeneralCommentLines() {
        let result = tokens(count: 20).asGeneralCommentLines(prefix: "///")

        XCTAssertEqual(
            result,
            [
"/// token1 token2 token3 token4 token5 token6 token7 token8 token9 token10 token11 token12 token13",
"/// token14 token15 token16 token17 token18 token19 token20",
            ]
        )
    }

    /// `formattedLines` should apply line-wrapping formatting with the given prefix on each line,
    /// the given start text for the first line, and the given additional line start text on each
    /// additional line. Lines should be limited to the line length limit, if possible.
    func testFormattedLines() {
        let result = tokens(count: 100).formattedLines(
            prefix: "[prefix]",
            firstLineStart: "[first]",
            additionalLineStart: "[additional]"
        )

        XCTAssertEqual(
            result,
            [
"[prefix][first]token1 token2 token3 token4 token5 token6 token7 token8 token9 token10 token11",
"[prefix][additional]token12 token13 token14 token15 token16 token17 token18 token19 token20 token21",
"[prefix][additional]token22 token23 token24 token25 token26 token27 token28 token29 token30 token31",
"[prefix][additional]token32 token33 token34 token35 token36 token37 token38 token39 token40 token41",
"[prefix][additional]token42 token43 token44 token45 token46 token47 token48 token49 token50 token51",
"[prefix][additional]token52 token53 token54 token55 token56 token57 token58 token59 token60 token61",
"[prefix][additional]token62 token63 token64 token65 token66 token67 token68 token69 token70 token71",
"[prefix][additional]token72 token73 token74 token75 token76 token77 token78 token79 token80 token81",
"[prefix][additional]token82 token83 token84 token85 token86 token87 token88 token89 token90 token91",
"[prefix][additional]token92 token93 token94 token95 token96 token97 token98 token99 token100",
            ]
        )
    }

    /// `asReturnLines` should format the return description in a multiline block as it would appear
    /// in a header comment.
    func testAsReturnLines() {
        let result = [
            "The",
            "description",
            "of",
            "the",
            "return",
            "value.",
            "This",
            "description",
            "is",
            "long",
            "and",
            "should",
            "wrap",
            "to",
            "multiple",
            "lines.",
        ].asReturnLines(prefix: "///")

        XCTAssertEqual(
            result,
            [
"/// - Returns: The description of the return value. This description is long and should wrap to",
"///   multiple lines.",
            ]
        )
    }

    /// `formattedLines` should include at least one token on each line even when lines exceed the
    /// line length limit.
    func testFormattedLinesPastLimit() {
        let result = tokens(count: 5).formattedLines(
            prefix: 
"                                                                                                     [prefix]",
            firstLineStart: "[first]",
            additionalLineStart: "[additional]"
        )

        XCTAssertEqual(
            result,
            [
"                                                                                                     [prefix][first]token1",
"                                                                                                     [prefix][additional]token2",
"                                                                                                     [prefix][additional]token3",
"                                                                                                     [prefix][additional]token4",
"                                                                                                     [prefix][additional]token5",
            ]
        )
    }

    // MARK: Helper Functions
    
    /// Generates the given number of token strings.
    ///
    /// - Parameter count: The number of tokens to generate.
    /// - Returns: The array of tokens.
    ///
    func tokens(count: Int) -> [String] {
        var tokens = [String]()
        for i in 1...count {
            tokens.append("token\(i)")
        }
        return tokens
    }
}
