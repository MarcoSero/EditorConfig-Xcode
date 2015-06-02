# EditorConfig Xcode Plugin

Plugin to add [EditorConfig](http://editorconfig.org) support to Xcode.

## What is EditorConfig?

> EditorConfig helps developers define and maintain consistent coding styles between different editors and IDEs. The EditorConfig project consists of a file format for defining coding styles and a collection of text editor plugins that enable editors to read the file format and adhere to defined styles. EditorConfig files are easily readable and they work nicely with version control systems.

For more info, head to [http://editorconfig.org](http://editorconfig.org)

## What this plugin does
When opening a file, the plugin looks for a file named `.editorconfig` in the directory of the opened file and in every parent directory.
Once and the file is found, the coding styles for the file extension will be read and the plugin will dynamically change the Xcode settings to match the style.

This is particularly useful in different scenarios:
- When you want to contribute to a project which has a different style guide from what you normally use.
- You prefer indenting Objective-C and Swift code differently.

## Install
Install via [Alcatraz](http://alcatraz.io). Just search for “EditorConfig”.

## Contact
[marcosero.com](http://www.marcosero.com)
[@marcosero](http://twitter.com/marcosero)

## License
MIT