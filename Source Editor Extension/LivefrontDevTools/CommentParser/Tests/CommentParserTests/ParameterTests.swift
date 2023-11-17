import XCTest
@testable import CommentParser

final class ParameterTests: XCTestCase {

    /// `asMultiParameterLines` should format the parameter as it would appear in a group of
    /// multiple parameters.
    func testAsMultiParameterLines() {
        let result = Parameter(
            name: "name",
            tokens: [
                "The",
                "description",
                "of",
                "the",
                "parameter.",
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
        ).asMultiParameterLines(prefix: "///")

        XCTAssertEqual(
            result,
            [
"///   - name: The description of the parameter. This description is long and should wrap to multiple",
"///     lines.",
            ]
        )
    }
    
    /// `asSingleParameterLines` should format the parameter as it would appear as the single
    /// parameter of a function.
    func testAsSingleParameterLines() {
        let result = Parameter(
            name: "name",
            tokens: [
                "The",
                "description",
                "of",
                "the",
                "parameter.",
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
        ).asSingleParameterLines(prefix: "///")

        XCTAssertEqual(
            result,
            [
"/// - Parameter name: The description of the parameter. This description is long and should wrap to",
"///   multiple lines.",
            ]
        )
    }

}
