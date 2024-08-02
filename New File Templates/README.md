# New File Templates

Xcode file templates add new options to the `New > File…` dialog. They can create a single new file
or a several related files. When a custom template option is selected, the user will be asked to
supply a file name or multiple values depending on the structure of the template. The resulting 
files and their content will be dynamically generated based on the user input.

## How to Install
To install a new file template, copy the `xctemplate` file to your file templates directory:
```
~/Library/Developer/Xcode/Templates/File\ Templates/
```
If you want to group related templates together under a custom name, add another subdirectory:
 ```
~/Library/Developer/Xcode/Templates/File\ Templates/Livefront
```
This will create a "Livefront" section at the bottom of the `New > File…` dialog.

## Coordinator Template

Livefront projects use the Coordinator pattern to manage navigation within applications. A coordinator 
is responsible for receiving a `Route` enum value and executing the corresponding navigation to the
correct screen of the app. This template creates a new coordinator file which will handle 
navigation for a particular area or collection of screens within the app.

## SwiftUI Feature Template

This template generates a collection of related files for a new screen of an application. These
files form the core components of Livefront's in-house Pentimento architecture. Pentimento is a 
uni-directional data flow architecture where UI updates are driven by changes in a `State` object. 
The `State` is managed by a `Processor` which contains business logic. The `Processor` modifies the 
`State` in response to user `Action`s received from the `View`.
