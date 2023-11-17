import XCTest
@testable import CommentParser

final class ReturnTests: XCTestCase {

    /// `asReturnLines` should format the return description in a multiline block as it would appear
    /// in a header comment.
    func testAsReturnLines() {
        let result = Return(
            tokens: [
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
            ]
        ).asReturnLines(prefix: "///")

        XCTAssertEqual(
            result,
            [
"/// - Returns: The description of the return value. This description is long and should wrap to",
"///   multiple lines.",
            ]
        )
    }

}
