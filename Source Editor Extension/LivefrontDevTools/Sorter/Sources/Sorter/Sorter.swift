import Foundation

public struct Sorter {
    /// Sort an entire file by ignoring the header info and leaving the outer classes and structs in place
    /// but sorting the contents of each outer struct or class.
    public static func sortFile(_ lines: [String]) -> [String] {
        guard !lines.isEmpty else { return [] }

        // The output to return.
        var output = [String]()

        // Get the indices of all the top-level closing brackets (Note: assumes the file
        // is formatted correctly).
        let closingBracketIndices = lines.enumerated().filter { $0.element.first == "}" }.map { $0.offset }

        // Walk through the file to identify top-level structs and classes.
        var index = 0
        while index < lines.count {
            let line = lines[index]

            // Anything before the first opening bracket is part of the header
            // and should not be sorted.
            if !line.contains("{") || (line.contains("{") && line.contains("}")) {
                output.append(line)
                index += 1
            } else {
                output.append(line)

                // Search for the next top level closing bracket.
                if let indexOfNextClosingBracket = closingBracketIndices.first(where: { $0 > index }) {
                    // Sort the contents of the top-level object.
                    let object = Array(lines[(index + 1)..<indexOfNextClosingBracket])
                    let sortedObject = sort(object)

                    // Use the sorted object in the output.
                    output.append(contentsOf: sortedObject)
                    index = indexOfNextClosingBracket
                } else {
                    index += 1
                }
            }
        }

        return output
    }

    /// Sort code by blocks so that bodies are not sorted and comments stay with their corresponding functions or variables.
    public static func sort(_ lines: [String]) -> [String] {
        guard !lines.isEmpty else { return [] }

        // Determine where the MARKs are (ignore any MARKs at index 0 and add an index
        // at the end of the array to ensure proper division into correct sections).
        var markIndices = lines.enumerated().filter { $0.element.contains("MARK") }.map { $0.offset }
        if markIndices.contains(0) { markIndices.remove(at: 0) }
        markIndices.append(lines.count)

        // Split the code into sections around each MARK divider.
        var prevIndex = 0
        var sections = [[String]]()
        for index in markIndices {
            sections.append(Array(lines[prevIndex..<index]))
            prevIndex = index
        }

        // Sort the blocks of code within each MARK section.
        for (index, section) in sections.enumerated() {
            sections[index] = sortBlocksWithinSection(section)
        }

        // Return the sections in their original order but with the content sorted.
        return sections.flatMap { $0 }
    }

    /// Sort all the code within a section.
    private static func sortBlocksWithinSection(_ lines: [String]) -> [String] {
        guard !lines.isEmpty else { return [] }

        // The output to return.
        var output = [String]()

        // If the first item of this section is a MARK, add it to the output
        // string without sorting it or associating it with a block.
        if let firstLine = lines.first, firstLine.contains("MARK") {
            output.append("\(firstLine)\n")
        }

        // The blocks that will be sorted and returned within this section.
        var blocks = [Block]()

        // If the line is within the body of a function or variable, do NOT sort it!
        var inBody = false

        // Parse the code into blocks.
        for line in lines {
            // Keep track of the parentheses in the line to decide where the blocks are.
            let openingParens = line.filter { $0 == "{" }.count
            let closingParens = line.filter { $0 == "}" }.count
            let netParens = openingParens - closingParens

            // If this line of code is within the body of a function, add it to that block of
            // code without sorting it.
            guard !inBody else {
                blocks.last?.content.append(line)

                // Update the parenthesis count of the block to determine when the block has ended.
                blocks.last?.parensCount = (blocks.last?.parensCount ?? 0) + netParens
                if blocks.last?.parensCount == 0 {
                    blocks.last?.isComplete = true
                    inBody = false
                }
                continue
            }

            // Discard the MARK that was already added to the output, and discard new lines
            // until after sorting is complete to avoid messing up the formatting.
            guard !line.contains("MARK"), line.trimmingCharacters(in: .whitespaces) != "\n" else { continue }

            // Add comments to blocks.
            if line.contains("//") {
                // If the previous line was a comment, this line is just continuing that same block.
                if blocks.last?.isComplete == false {
                    blocks.last?.content.append(line)
                } else {
                    // Otherwise, this is the start of a new incomplete block.
                    let newBlock = Block(content: [line], isComplete: false, key: "")
                    blocks.append(newBlock)
                }
                continue
            }

            if let type = line.blockType() {
                // Determine the name to use for sorting by looking at the word right after the type keyword.
                let name = line.name(ofType: type)

                // If there were comments preceding this keyword, update the block that includes the comments.
                if blocks.last?.isComplete == false {
                    blocks.last?.content.append(line)
                    blocks.last?.isComplete = (netParens == 0)
                    blocks.last?.key = name
                    blocks.last?.parensCount = (blocks.last?.parensCount ?? 0) + netParens
                    blocks.last?.type = type
                } else {
                    // Otherwise, create a new block with this variable.
                    let newBlock = Block(
                        content: [line],
                        key: name,
                        parensCount: netParens,
                        type: type
                    )
                    blocks.append(newBlock)
                }

                // If there are more opening parentheses than closing ones, the following lines should
                // be the body of the variable.
                if netParens > 0 { inBody = true }
            }
        }

        // Sort the blocks first by type then alphabetically.
        blocks.sort(by: {
            if $0.type == $1.type {
                return $0.key < $1.key
            } else if let type1 = $0.type, let type2 = $1.type {
                return type1.rawValue < type2.rawValue
            }

            return $0.key < $1.key
        })

        // Separate each block by a new line.
        blocks.forEach { $0.content.append("\n") }

        // Return the sorted code.
        output.append(contentsOf: blocks.flatMap { $0.content })
        return output
    }
}
