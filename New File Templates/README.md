# New File Templates

Xcode file templates add new options to the `New > File…` dialog. They can create a single new file
or a several related files. When a custom template option is selected, the user will be asked to
supply a file name or multiple values depending on the structure of the template. The resulting 
files and their content will be dynamically generated based on the user input.

## How to Install
To install a new file template, copy the `xctemplate` file to your file templates directory:
```
/Users/<your username>/Library/Developer/Xcode/Templates/File\ Templates/
```
If you want to group related templates together under a custom name, add another subdirectory:
 ```
/Users/<your username>/Library/Developer/Xcode/Templates/File\ Templates/Livefront
```
This will create a "Livefront" section at the bottom of the `New > File…` dialog.
