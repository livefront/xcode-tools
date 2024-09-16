// MARK: - Section

/// An object used to group blocks of code within a `MARK` section.
///
struct Section {
    /// A list of blocks of code contained within the section.
    var blocks: [Block] = []
    
    /// A footer, such as an ending new line.
    var footer: [String] = []
    
    /// A header, such as a `MARK` comment and any associated spaces.
    var header: [String] = []
}
