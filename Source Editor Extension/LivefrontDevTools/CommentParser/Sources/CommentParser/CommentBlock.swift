/// Stores the in-progress data while parsing a comment block.
struct CommentBlock {

    // MARK: Private Properties

    /// The tokens for the discussion section of the comment block.
    private var discussionTokens = [String]()

    /// The tokens for the general description section of the comment block.
    private var generalTokens = [String]()

    /// `true` iff the comment block should be formatted.
    private var isTargeted = false

    /// A buffer of unmodified lines from the comment block. This is used to revert to the original
    /// unformatted lines in the event that the comment block is not targeted for formatting.
    private var originalLineBuffer = [String]()

    /// The parameters of the comment block.
    private var parameters = [Parameter]()

    /// The tokens for the returns description of the comment block.
    private var returnsTokens = [String]()

    /// The tokens for the throws description of the comment block.
    private var throwsTokens = [String]()

    // MARK: Instance Methods

    /// Adds the given tokens to the collection of discussion tokens.
    ///
    /// - Parameter tokens: The additional tokens of the discussion block.
    ///
    mutating func appendDiscussionTokens(_ tokens: [String]) {
        discussionTokens.append(contentsOf: tokens)
    }

    /// Adds the given tokens to the general description section of the comment block.
    ///
    /// - Parameter tokens: The tokens for the general description section of the comment block.
    ///
    mutating func appendGeneralTokens(_ tokens: [String]) {
        generalTokens.append(contentsOf: tokens)
    }

    /// Adds a parameter to the comment block.
    ///
    /// - Parameters:
    ///   - name: The name of the parameter.
    ///   - tokens: The token strings of the parameter description.
    ///
    mutating func appendParameter(name: String, tokens: [String]) {
        parameters.append(Parameter(name: name, tokens: tokens))
    }

    /// Adds tokens to the current parameter's description.
    ///
    /// - Parameter tokens: Additional tokens for a parameter's description.
    ///
    mutating func appendParameter(tokens: [String]) {
        guard !parameters.isEmpty else { return }
        let parameter = parameters.removeLast()
        parameters.append(Parameter(name: parameter.name, tokens: parameter.tokens + tokens))
    }

    /// Adds the given tokens to the returns description of the comment block.
    ///
    /// - Parameter tokens: The additional tokens of the returns description.
    ///
    mutating func appendReturnsTokens(_ tokens: [String]) {
        returnsTokens.append(contentsOf: tokens)
    }

    /// Adds the given tokens to the throws description of the comment block.
    ///
    /// - Parameter tokens: The additional tokens of the throws description.
    ///
    mutating func appendThrowsTokens(_ tokens: [String]) {
        throwsTokens.append(contentsOf: tokens)
    }

    /// Uses the comment block values to generate a formatted comment block as an array of strings.
    ///
    /// - Parameters:
    ///   - type: The comment type that should be used to format the comment block.
    ///   - indentationGuide: A string which indicates the amount of whitespace to insert at the
    ///     beginning of every line in the comment block. This is determined by the amount of
    ///     whitespace at the beginning of the indentation guide.
    /// - Returns: The formatted output of the comment block.
    ///
    mutating func generateOutput(
        type: CommentType,
        indentationGuide: String
    ) -> [String] {
        // Skip formatting this comment block if it was not targeted.
        guard isTargeted else {
            return originalLineBuffer
        }

        // Build the prefix based on the comment type and leading whitespace of the indentation
        // guide. The indentation guild is used to determine how much whitespace to add at the
        // beginning of each line of the comment block. If the guide begins with whitespace, that
        // same amount of whitespace will be added to each line. Usually the indentation guide for a
        // comment block is the non-comment source code line immediately following the comment
        // block. If no subsequent line exists, or if the following line is empty, we fallback to
        // the indentation from the first line of the comment block.
        let finalIndentationGuide = indentationGuide.allSatisfy { $0.isWhitespace } ?
            originalLineBuffer.first ?? "" : indentationGuide
        let indentation = finalIndentationGuide.prefix { $0.isWhitespace }
        let prefix: String = indentation + type.rawValue

        // Build groups of lines representing the sections of the comment.
        var sections = [[String]]()

        // Generate the general output.
        if !generalTokens.isEmpty {
            sections.append(generalTokens.asGeneralCommentLines(prefix: prefix))
        }

        // Function signature block (Parameters, Returns, Throws).
        var functionSignatureSection = [String]()
        if parameters.count == 1 {
            // Generate the parameter output.
            functionSignatureSection.append(
                contentsOf: parameters[0].asSingleParameterLines(prefix: prefix)
            )
        } else if parameters.count > 1 {
            // Generate the parameter output.
            functionSignatureSection.append(prefix + " - Parameters:")
            for parameter in parameters {
                functionSignatureSection.append(
                    contentsOf: parameter.asMultiParameterLines(prefix: prefix)
                )
            }
        }
        // Generate the returns output.
        if !returnsTokens.isEmpty {
            functionSignatureSection.append(
                contentsOf: returnsTokens.asReturnsLines(prefix: prefix)
            )
        }
        // Generate the throws output.
        if !throwsTokens.isEmpty {
            functionSignatureSection.append(
                contentsOf: throwsTokens.asThrowsLines(prefix: prefix)
            )
        }
        if !functionSignatureSection.isEmpty {
            sections.append(functionSignatureSection)
        }

        // Generate the discussion output.
        if !discussionTokens.isEmpty {
            sections.append(discussionTokens.asGeneralCommentLines(prefix: prefix))
        }

        // Add the sections to the output with a blank line between each section.
        var output = Array(sections.joined(separator: [prefix]))

        // Add an extra blank line if the comment block ended with a function signature section.
        if !functionSignatureSection.isEmpty && discussionTokens.isEmpty {
            output.append(prefix)
        }

        return output
    }

    /// Perform parsing common to all comment line types. The unaltered text is saved in a buffer in
    /// case the comment block is not targeted for formatting.
    ///
    /// - Parameters:
    ///   - targeted: `true` iff this line was contained in a selection range.
    ///   - text: The original unmodified line of text.
    ///
    mutating func saveOriginalLine(targeted: Bool, text: String) {
        originalLineBuffer.append(text)
        isTargeted = isTargeted || targeted
    }
}
