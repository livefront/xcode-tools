import XCTest
@testable import Sorter

final class StringExtensionTests: XCTestCase {
    /// Test that the block type is correctly identified from a line of code.
    func testBlockTypeIdentified() {
        XCTAssertEqual(BlockType.importType, "import SomeLibrary".blockType)

        XCTAssertEqual(BlockType.alias, "typealias CoolType".blockType)

        XCTAssertEqual(BlockType.nestedType, "struct FunnyName {".blockType)
        XCTAssertEqual(BlockType.nestedType, "class Clown {".blockType)
        XCTAssertEqual(BlockType.nestedType, "actor TheRock {".blockType)
        XCTAssertEqual(BlockType.nestedType, "enum CurrentMood {".blockType)
        XCTAssertEqual(BlockType.nestedType, "extension ExtraFun {".blockType)
        XCTAssertEqual(BlockType.nestedType, "protocol DoTheseThings {".blockType)

        XCTAssertEqual(BlockType.property, "var namesAreHard".blockType)
        XCTAssertEqual(BlockType.property, "let testsAreFun".blockType)
        XCTAssertEqual(BlockType.property, "case theCoolOne".blockType)

        XCTAssertEqual(BlockType.function, "func keepBusy() {".blockType)

        XCTAssertEqual(BlockType.initType, "init() {".blockType)

        XCTAssertNil("utter gibberish".blockType)
    }

    /// Test removing the special characters and lowercasing a string.
    func testLowercasedNonSpecialString() {
        XCTAssertEqual("helloworld3", "Hello world! :3".lowercasedNonSpecial)
    }

    /// Test verifying if a string contains any of the substrings in a search query.
    func testContainsAny() {
        XCTAssertTrue("Apples, bananas, pineapples".contains(any: ["pineapples", "mangos"]))
        XCTAssertFalse("Apples, bananas, pineapples".contains(any: ["guavas", "mangos"]))
    }

    /// Test that the name of a block is correctly identified next to the keyword.
    func testBlockNameIdentified() {
        XCTAssertEqual(
            "fullyfunctional",
            "@MacroSomething func fullyFunctional() {".name(ofType: .function)
        )
    }
}
