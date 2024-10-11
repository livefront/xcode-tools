# Source Editor Extension

Source editor extensions add custom commands to the editor menu in Xcode. They can modify the source
code of the current file or operate on the currently selected text.

Livefront maintains a single source editor extension application called "Livefront Developer Tools".
It's commands are grouped in the "Livefront" submenu of the Xcode editor menu.

## Get the container app
### Option 1: Compile from source
1. Open the `LivefrontDevTools` project in Xcode.
2. Create a build archive with `Product > Archive`.
3. Locate the generated archive package file.
4. View the package contents and find the `Livefront Developer Tools.app` file.
### Option 2: Just download it
1. Download the latest pre-compiled release binary from the `Releases` list of this repository.

## Installation
1. Move `Livefront Developer Tools.app` to your `Applications` folder.
2. Run the app once to register the extension with macOS.
3. Close the app.
4. Go to `System Settings > Privacy & Security > Extensions > Xcode Source Editor`.
5. Check the box for `Livefront`.
6. Open Xcode.
7. Go to `Editor > Livefront` to use the new source editor commands.

## Commands
- **Alphabetize (BETA)**: Alphabetically sorts the declarations in a whole file or selected lines.
- **Format Comments**: Formats the comments of a whole file or selection of lines to match Livefront's Swift comment style guidelines. 
