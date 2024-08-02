# Code Snippets

Code snippets add custom auto-complete options to the Xcode source code editor. These can be used as
shortcuts for commonly typed code such as functions, statements, or comments.

## How to Install
Copy `.codesnippet` files to `~/Library/Developer/Xcode/UserData/CodeSnippets/` and restart Xcode to install.

## Mark Snippets

The Livefront Swift Style Guide recommends using `// MARK:` separators to organize implementation 
files into the following sections:
1. Type Properties
2. Instance Properties
3. Private Properties
4. Initialization Methods
5. Type Methods
6. Instance Methods
7. Private Methods
8. Nested Types

For example, the line marking the beginning of the private properties section would look like this:
```
// MARK: Private Properties
```

To use a Mark snippet, place the cursor inside a type implementation in a Swift file. Type the 
completion trigger "m" followed by the number and abbreviation of the section name and press enter. 
For example, type `m1tp` and enter for `// MARK: Type Properties`. You may also simply type `m` and 
select from one of the options in the popup menu. 

## Mark Type Snippet

Additionally, you will find a "Mark Type" snippet. This separator should be used to mark the 
beginning of the definition for any additional top-level types defined in a Swift file. To use this
snippet, place the cursor outside of any type in a Swift source file. Use the completion trigger "m"
and press enter to generate this line:
```
// MARK: - <label>
```
Replace the label with the name of the top-level type you are defining.

## Test Assert Snippets

Typing the full names of XCTest assertions can become tedious. The test assert snippets shorten this
process by providing convenient shortcuts for the common `XCTAssert*` functions. The completion 
triggers and corresponding snippets are:
| Completion  | Snippet |
| ------------- | ------------- |
| `xeq`  | `XCTAssertEqual(<expression1>, <expression2>)` |
| `xeq` | `XCTAssertEqual(<expression1>, <expression2>)` |
| `xt` | `XCTAssertTrue(<expression: Bool>)` |
| `xf` | `XCTAssertFalse(<expression: Bool>)` |
| `xnil` | `XCTAssertNil(<value>)` |
| `xnn` | `XCTAssertNotNil(<value>)` |
