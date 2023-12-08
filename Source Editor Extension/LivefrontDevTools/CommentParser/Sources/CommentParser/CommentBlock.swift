/// Stores the in-progress data while parsing a comment block.
struct CommentBlock {

    // MARK: Instance Properties

    /// A buffer of unmodified lines from the comment block. This is used to revert to the original
    /// unformatted lines in the event that the comment block is not targeted for formatting.
    var buffer = [String]()

    /// The tokens for the discussion section of the comment block.
    var discussionTokens = [String]()

    /// The tokens for the general description section of the comment block.
    var generalTokens = [String]()

    /// `true` iff the comment block should be formatted.
    var isTargeted = false

    /// The parameters of the comment block.
    var parameters = [Parameter]()

    /// The return value of the comment block.
    var returnValue: Return?

    // MARK: Instance Methods

    /// Perform parsing common to all comment line types.
    ///
    /// - Parameters:
    ///   - targeted: `true` iff this line was contained in a selection range.
    ///   - text: The original unmodified line of text.
    ///
    mutating func addCommentLine(targeted: Bool, text: String) {
        buffer.append(text)
        isTargeted = isTargeted || targeted
    }

    /// Uses the comment block values to generate a formatted comment block as an array of strings.
    /// The temporary values are then erased in preparation for the next comment block.
    ///
    /// - Parameters:
    ///   - mode: The current parsing mode.
    ///   - indentationGuide: A string which indicates the amount of whitespace to insert at the
    ///     beginning of every line in the comment block. This is determined by the amount of
    ///     whitespace at the beginning of the indentation guide.
    /// - Returns: The formatted output of the comment block.
    ///
    mutating func finalizeAndGenerateOutput(
        mode: ParsingMode,
        indentationGuide: String
    ) -> [String] {
        var output = [String]()

        // Skip formatting this comment block if it was not targeted.
        guard isTargeted else {
            output.append(contentsOf: buffer)
            return output
        }

        // Finalize in-progress data.
        switch mode {
        case let .inlineComment(currentTokens):
            generalTokens = currentTokens
        case let .headerCommentDiscussion(currentTokens):
            discussionTokens += currentTokens
        case let .headerCommentGeneral(currentTokens):
            generalTokens = currentTokens
        case let .headerCommentParameter(currentName, currentTokens):
            parameters.append(Parameter(name: currentName, tokens: currentTokens))
        case let .headerCommentReturn(currentTokens):
            returnValue = Return(tokens: currentTokens)
        case .nonComment:
            break
        }

        // Build the prefix based on the mode and leading whitespace of the indentation guide. The
        // indentation guild is used to determine how much whitespace to add at the beginning of
        // each line of the comment block. If the guide begins with whitespace, that same amount of
        // whitespace will be added to each line. Usually the indentation guide for a comment block
        // is determined by the non-comment source code line immediately following the comment
        // block. If no subsequent line exists, or if the following line is empty, we fallback to
        // the indentation from the first line of the comment block.
        let finalIndentationGuide = indentationGuide.allSatisfy { $0.isWhitespace } ?
            buffer.first ?? "" : indentationGuide
        let indentation = finalIndentationGuide.prefix { $0.isWhitespace }
        let prefix: String
        switch mode {
        case .headerCommentDiscussion,
                .headerCommentGeneral,
                .headerCommentParameter,
                .headerCommentReturn:
            prefix = indentation + "///"
        case .inlineComment:
            prefix = indentation + "//"
        case .nonComment:
            prefix = ""
        }

        // Build groups of lines representing the sections of the comment.
        var sections = [[String]]()

        // Generate the general output.
        if !generalTokens.isEmpty {
            sections.append(generalTokens.asGeneralCommentLines(prefix: prefix))
        }

        // Parameters / Returns block.
        if parameters.count == 1 {
            var section = [String]()
            // Generate the parameter output.
            section.append(contentsOf: parameters[0].asSingleParameterLines(prefix: prefix))
            // Generate the return output.
            if let returnValue {
                section.append(contentsOf: returnValue.asReturnLines(prefix: prefix))
            }
            sections.append(section)
        } else if parameters.count > 1 {
            var section = [String]()
            // Generate the parameter output.
            section.append(prefix + " - Parameters:")
            for parameter in parameters {
                section.append(contentsOf: parameter.asMultiParameterLines(prefix: prefix))
            }
            // Generate the return output.
            if let returnValue {
                section.append(contentsOf: returnValue.asReturnLines(prefix: prefix))
            }
            sections.append(section)
        } else {
            // Generate the return output.
            if let returnValue {
                var section = [String]()
                section.append(contentsOf: returnValue.asReturnLines(prefix: prefix))
                sections.append(section)
            }
        }

        // Generate the discussion output.
        if !discussionTokens.isEmpty {
            sections.append(discussionTokens.asGeneralCommentLines(prefix: prefix))
        }

        // Add the sections to the output with a blank line between each section.
        output.append(contentsOf: sections.joined(separator: [prefix]))

        // Add an extra blank line if the comment block ended with parameters or returns.
        if (!parameters.isEmpty || returnValue != nil) && discussionTokens.isEmpty {
            output.append(prefix)
        }

        return output
    }
}
