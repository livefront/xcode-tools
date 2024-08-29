import XCTest
@testable import Sorter

final class SorterTests: XCTestCase {
    /// Sort a sample file to ensure it works as expected.
    func testSorting() throws {
        // Load the sample data to test
        guard let pathSorted = Bundle.module.path(forResource: "sorted1", ofType: "txt"),
              let contentsSorted = try? String(contentsOfFile: pathSorted),
              let pathUnsorted = Bundle.module.path(forResource: "unsorted1", ofType: "txt"),
              let contentsUnsorted = try? String(contentsOfFile: pathUnsorted)
        else {
            fatalError("Test files not found")
        }

        // Sort the contents of the file.
        let testSort = Sorter.sort(contentsUnsorted.components(separatedBy: "\n"))
        XCTAssertEqual(testSort.joined(separator: "\n"), contentsSorted)
    }
}
