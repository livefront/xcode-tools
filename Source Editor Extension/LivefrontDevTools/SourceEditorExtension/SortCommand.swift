import Foundation
import Sorter
import XcodeKit

class SortCommand: NSObject, XCSourceEditorCommand {
    func perform(
        with invocation: XCSourceEditorCommandInvocation,
        completionHandler: @escaping (Error?) -> Void
    ) {
        // Get the lines and the selection (the selection can include where the cursor is, not
        // just a highlighted region of code).
        if let selection = invocation.buffer.selections.firstObject as? XCSourceTextRange,
           let lines: [String] = invocation.buffer.lines as? [String],
           !lines.isEmpty {
            // Determine the exact start and end of the highlighted section.
            let startLine = selection.start.line
            let endLine = min(selection.end.line, lines.count - 1)

            // If no data is actually selected, then sort the entire file.
            if startLine > endLine ||
                (startLine == endLine && selection.start.column == selection.end.column) {
                // Sort the entire file.
                let sortedFile = Sorter.sort(lines)

                // Update the source with the newly sorted code.

                // Attempt to apply the smallest number of changes necessary to the contents of the
                // lines buffer. We do this to get Xcode to only highlight changed lines while
                // undoing the changes.
                let difference = invocation.buffer.lines.difference(from: sortedFile) { lhs, rhs in
                    if let leftString = lhs as? String,
                       let rightString = rhs as? String {
                        // If two strings have equal content, treat them as unchanged.
                        return leftString == rightString
                    } else {
                        return false
                    }
                }.inverse()
                invocation.buffer.lines.apply(difference)
            } else {
                // Sort just the highlighted region
                let selectedText = Array(lines[startLine...endLine])
                let sortedLines = Sorter.sort(selectedText)

                // Update the source with the newly sorted code.
                let range = NSRange(location: startLine, length: (endLine - startLine) + 1)
                invocation.buffer.lines.replaceObjects(in: range, withObjectsFrom: sortedLines)
            }
        }

        // Signal to Xcode that the command has completed.
        completionHandler(nil)
    }
}
