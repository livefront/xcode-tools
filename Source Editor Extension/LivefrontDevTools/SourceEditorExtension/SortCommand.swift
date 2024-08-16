import Foundation
import Sorter
import XcodeKit

class SortCommand: NSObject, XCSourceEditorCommand {
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void) {
        // Get the lines and the selection (selection can include where the pointer is, not
        // just a highlighted region of code).
        if let selection = invocation.buffer.selections.firstObject as? XCSourceTextRange,
           let selectedLines: [String] = invocation.buffer.lines as? [String],
           !selectedLines.isEmpty {
            // Retrieve the contents of the current source editor.
            let startLine = selection.start.line
            let endLine = min(selection.end.line, selectedLines.count - 1)

            // If no data is actually "selected," then sort the entire file.
            if startLine == endLine, selection.start.column == selection.end.column {
                // Sort the entire file.
                let sortedFile = Sorter.sortFile(selectedLines)

                // Update the source with the newly sorted code.
                invocation.buffer.lines.removeAllObjects()
                invocation.buffer.lines.addObjects(from: sortedFile)
            } else {
                // Sort just the highlighted region
                let selectedText = Array(selectedLines[startLine...endLine])
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
