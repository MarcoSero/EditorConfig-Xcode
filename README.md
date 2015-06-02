# EditorConfig Xcode Plugin

Plugin to add [EditorConfig](http://editorconfig.org) support to Xcode.

## What is EditorConfig

> EditorConfig helps developers define and maintain consistent coding styles between different editors and IDEs. The EditorConfig project consists of a file format for defining coding styles and a collection of text editor plugins that enable editors to read the file format and adhere to defined styles. EditorConfig files are easily readable and they work nicely with version control systems.

For more info, head to [http://editorconfig.org](http://editorconfig.org)

## What this plugin does
When opening a file, the plugin looks for a file named `.editorconfig` in the directory of the opened file and in every parent directory.
Once the file is found, the coding styles for the file extension will be read and the plugin will dynamically change the Xcode settings to match the style.

This is particularly useful in different scenarios:

- When contributing to a project which has a different style guide from what you normally use, you can just use a different `.editorconfig` to override the default settings.
- If you like having different indentation settings for different languages (e.g. Objective-C and Swift).
- You prefer your indentation settings to be editor-agnostic.

## Install
Install via [Alcatraz](http://alcatraz.io). Just search for “EditorConfig”.

## Settings currently supported
- `indent_style`
- `indent_size`
- `tab_width`

## How this is different from ClangFormat
ClangFormat is a much more powerful tool, but it can be overkill for simply changing indentation settings.

## Contact
[marcosero.com](http://www.marcosero.com)  
[@marcosero](http://twitter.com/marcosero)

## License
MIT