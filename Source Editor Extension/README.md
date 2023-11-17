# Source Editor Extension

Source editor extensions add custom commands to the editor menu in Xcode. They can modify the source
code of the current file or operate on the currently selected text.

Livefront maintains a single source editor extension application called "Livefront Developer Tools".
It's commands are grouped in the "Livefront" submenu of the Xcode editor menu.

## Installation
1. Move `Livefront Developer Tools.app` to your `Applications` folder.
2. Go to `System Settings > Privacy & Security > Extensions > Xcode Source Editor`.
3. Check the box for `Livefront`.
4. Open Xcode.
5. Go to `Editor > Livefront` to use the new source editor commands.

## Commands
- **Format Comments**: Formats the comments of a whole file or selection of lines to match Livefront's Swift comment style guidelines. 
