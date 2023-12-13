import CommentParser
import Foundation
import XcodeKit

class FormatCommentsCommand: NSObject, XCSourceEditorCommand {
    func perform(
        with invocation: XCSourceEditorCommandInvocation,
        completionHandler: @escaping (Error?) -> Void
    ) -> Void {
        // Build an array of closed line index ranges from the XCSourceTextRange selections.
        let selections: [ClosedRange<Int>] = invocation.buffer.selections
            .compactMap { $0 as? XCSourceTextRange }
            .filter { $0.start != $0.end }
            .map { $0.start.line...$0.end.line }

        // Initialize the parser with the selected target ranges.
        let parser = Parser(targetRanges: selections)

        // Pass each line, along with its line number, to the parser.
        let lines = invocation.buffer.lines
        var lineNumber = 0
        for case let line as String in lines {
            parser.parseLine(line, lineNumber: lineNumber)
            lineNumber += 1
        }

        // Get the final output from the parser. The original lines ended with newline characters.
        // Add them back here to produce a minimal difference from the original text.
        let output = parser.generateOutput().map { !$0.hasSuffix("\n") ? "\($0)\n" : $0 }

        // Attempt to apply the smallest number of changes necessary to the contents of the lines
        // buffer. We do this to get Xcode to only highlight changed lines while undoing the
        // changes.
        let difference = lines.difference(from: output) { lhs, rhs in
            if let leftString = lhs as? String,
               let rightString = rhs as? String {
                // If two strings have equal content, treat them as unchanged.
                return leftString == rightString
            } else {
                return false
            }
        }.inverse()
        lines.apply(difference)

        completionHandler(nil)
    }

}

extension XCSourceTextPosition: Equatable {
    public static func == (lhs: XCSourceTextPosition, rhs: XCSourceTextPosition) -> Bool {
        lhs.line == rhs.line && lhs.column == rhs.column
    }
}
