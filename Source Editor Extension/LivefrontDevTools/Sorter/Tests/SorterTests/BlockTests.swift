import XCTest
@testable import Sorter

final class BlockTests: XCTestCase {
    /// Test that the block is marked as complete correctly.
    func testIsComplete() {
        var block = Block()
        XCTAssertFalse(block.isComplete)

        block.type = .function
        XCTAssertFalse(block.isComplete)
        
        block.key = "testFunction"
        XCTAssertFalse(block.isComplete)

        block.content = ["Test content"]
        block.netParens = 1
        XCTAssertFalse(block.isComplete)

        block.netParens = 0
        XCTAssertTrue(block.isComplete)
    }
}
