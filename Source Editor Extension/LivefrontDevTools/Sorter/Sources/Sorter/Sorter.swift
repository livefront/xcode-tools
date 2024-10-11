import Foundation

// MARK: - Sorter

/// Sorts blocks of code within each MARK section, first by type and then alphabetically.
///
public enum Sorter {
    // MARK: Methods

    /// Sort the code within each `MARK` section, first by type and then alphabetically.
    ///
    /// - Parameters:
    ///   - lines: The lines of code to be sorted.
    ///   - isNestedType: Whether the lines are nested within a type.
    ///
    /// - Returns: The sorted code.
    ///
    public static func sort(_ lines: [String], isNestedType: Bool = false) -> [String] {
        guard !lines.isEmpty else { return [] }

        // Split the code into sections around each MARK divider.
        let sections = getMarkSections(from: lines)

        // Identify the blocks of code within each section.
        let sectionsWithBlocks = sections.map { identifyBlocks(in: $0) }

        // Sort the blocks of code within each section.
        let sectionsWithSortedBlocks = sectionsWithBlocks.map { sortBlocks(in: $0) }

        // If there are nested types, recursively sort the content within the nested types.
        let recursivelySortedSections = sectionsWithSortedBlocks.map { section in
            let recursivelySortedBlocks = section.blocks.map { block in
                (block.type == .nestedType) ? sortNestedType(block) : block
            }
            return Section(
                blocks: recursivelySortedBlocks,
                footer: section.footer,
                header: section.header
            )
        }

        // Return the sorted code.
        return getSortedCode(from: recursivelySortedSections, isNestedType: isNestedType)
    }

    // MARK: Private Methods

    /// Divide the lines of code by `MARK` sections at the same level, ignoring `MARK`s nested
    /// within
    /// classes or structs until those types are recursively sorted.
    ///
    /// - Parameter lines: The lines of code to parse.
    /// - Returns: The lines of code divided into sections by top-level `MARK`s.
    ///
    private static func getMarkSections(from lines: [String]) -> [[String]] {
        // Find the indices of all the MARK comments that aren't nested within other types.
        var markIndices = [Int]()
        var netParens = 0
        for (index, line) in lines.enumerated() {
            let openingParens = line.filter { $0 == "{" || $0 == "(" }.count
            let closingParens = line.filter { $0 == "}" || $0 == ")" }.count
            netParens += (openingParens - closingParens)

            if line.contains("MARK"), netParens == 0 {
                markIndices.append(index)
            }
        }

        // Ignore any MARKs at index 0 and add an index at the end of the array to ensure proper
        // division into sections.
        if markIndices.contains(0) { markIndices.remove(at: 0) }
        markIndices.append(lines.count)

        // Split the code into sections around each MARK divider, including the MARK at the top of
        // the section.
        var prevIndex = 0
        var sections = [[String]]()
        for index in markIndices {
            sections.append(Array(lines[prevIndex..<index]))
            prevIndex = index
        }

        // Return the list of MARK sections.
        return sections
    }

    /// Convert sorted sections back into raw lines of code.
    ///
    /// - Parameters:
    ///   - sections: The sorted sections to combine.
    ///   - isNestedType: Whether the sections are within a type.
    ///
    /// - Returns: The sorted lines of code.
    ///
    private static func getSortedCode(from sections: [Section], isNestedType: Bool) -> [String] {
        return sections.flatMap { section in
            var output = section.header
            // Separate each block except the last one by a new line.
            let lastIndex = section.blocks.count - 1
            section.blocks.enumerated().forEach { index, block in
                output.append(contentsOf: block.content)
                // Add a new line between blocks, expect for in between imports.
                if index != lastIndex,
                   block.type != .alias || section.blocks[index + 1].type != .alias,
                   block.type != .importType || section.blocks[index + 1].type != .importType {
                    output.append("")
                }
            }
            output.append(contentsOf: section.footer)
            if section.footer.isEmpty,
               output.last?.contains("\n") == false,
               !isNestedType {
                output.append("\n")
            }
            return output
        }
    }

    /// Identify the different blocks of code within a `MARK` section.
    ///
    /// - Parameter lines: The lines of code to parse into blocks.
    /// - Returns: A `Section` of code with any header and footer lines and a list of `Block`s.
    ///
    private static func identifyBlocks(in lines: [String]) -> Section {
        guard !lines.isEmpty else { return Section() }

        // Define the output of sections with associated lists of blocks that will be returned.
        var section = Section()

        // Go through each line of code to parse it into headers, footers, and blocks.
        let lastIndex = lines.count - 1
        var currentBlock = Block()
        for (index, line) in lines.enumerated() {
            // Look for the headers and footer of the section.
            if index == 0, line.contains("MARK") {
                section.header.append(line)
            } else if index == 1,
                      line.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                      !section.header.isEmpty {
                section.header.append(line)
            } else if index == lastIndex,
                      line.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                section.footer.append(line)
            } else {
                let trimmedLine = line.trimmingCharacters(in: .whitespaces)

                // A block is defined by tracking comments until a keyword is found, then continuing
                // to add following lines of code to the block until a new line or new keyword is
                // found that isn't nested inside the block.

                // If the current line is a comment or an annotation, add it to the block without
                // asking any questions.
                if trimmedLine.prefix(2) == "//" {
                    currentBlock.content.append(line)
                    continue
                }

                // Count the net parentheses and brackets on the line to determine if the line is
                // within the body of a function or declaration.
                let openingParens = line.filter { $0 == "{" || $0 == "(" }.count
                let closingParens = line.filter { $0 == "}" || $0 == ")" }.count
                let netParens = openingParens - closingParens
                currentBlock.netParens += netParens

                // If the current line contains any keywords that indicate the type of block it is,
                // identify both the block type and name.
                if currentBlock.type == nil, let type = line.blockType {
                    // Set the type and name of the block and add the line to the block.
                    currentBlock.type = type
                    currentBlock.key = line.name(ofType: type)
                    currentBlock.keyLine = line
                    currentBlock.content.append(line)
                } else if currentBlock.netParens > 0 || netParens < 0 {
                    // If the current line is within parentheses or brackets, or is a closing
                    // bracket,
                    // add the line to the block without asking any questions.
                    currentBlock.content.append(line)
                } else if trimmedLine.first == "@" {
                    // If the line is merely an annotation, add it to the block.
                    currentBlock.content.append(line)
                } else if trimmedLine.isEmpty || trimmedLine == "\n" {
                    // Skip over blank lines that aren't in the body of the block to avoid
                    // formatting errors.
                } else {
                    // Otherwise, if the line isn't part of the body, isn't a comment, and doesn't
                    // contain an keyword
                    // or macro that would indicate it's part of the next block, add it to the
                    // previous block (this
                    // might apply to multi-line logic or type definitions, for instance.
                    section.blocks[section.blocks.count - 1].content.append(line)
                }

                // If the block is complete, add it to the list of blocks in the section and
                // reset the current block to a new one.
                if currentBlock.isComplete {
                    section.blocks.append(currentBlock)
                    currentBlock = Block()
                }
            }
        }

        // Return the parsed section.
        return section
    }

    /// Sort the `Block`s within each `Section`, first by type and then alphabetically.
    ///
    /// - Parameter section: A section of code containing `Block`s to sort.
    /// - Returns: A section of code with the same header and footer but sorted `Block`s.
    ///
    private static func sortBlocks(in section: Section) -> Section {
        var sortedSection = section
        sortedSection.blocks.sort {
            if $0.type == $1.type {
                return $0.key < $1.key
            } else if let type1 = $0.type, let type2 = $1.type {
                return type1.rawValue < type2.rawValue
            }

            return $0.key < $1.key
        }
        return sortedSection
    }

    /// Recursively sort the content of a nested type within the body of a `Block`.
    ///
    /// - Parameter block: A `Block` of code that might contain a nested body that should be sorted.
    /// - Returns: A `Block` with a sorted body, if applicable.
    ///
    private static func sortNestedType(_ block: Block) -> Block {
        // If the type is an enum with an associated value of Int, don't sort it.
        guard let keyLine = block.keyLine,
              !(keyLine.contains("enum") && keyLine.contains(": Int"))
        else { return block }

        // Otherwise, identify the lines contained within the body.
        guard let openingIndex: Int = block.content.firstIndex(where: { $0.contains("{") }),
              let closingIndex: Int = block.content.lastIndex(where: { $0.contains("}") }),
              openingIndex < closingIndex - 1
        else { return block }
        let body = Array(block.content[(openingIndex + 1)..<closingIndex])

        // Recursively sort the body.
        let sortedBody = sort(body, isNestedType: true)

        // Return the block with the sorted body
        var newContent = Array(block.content[0...openingIndex])
        newContent.append(contentsOf: sortedBody)
        newContent.append(contentsOf: Array(block.content[closingIndex..<block.content.count]))
        return Block(
            content: newContent,
            key: block.key,
            keyLine: block.keyLine,
            netParens: block.netParens,
            type: block.type
        )
    }
}
