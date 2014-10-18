# file-explorer package

It provides SelectList View for accessing the project file and directory like fuzzy-finder.
- `cmd-alt-n` to open the current directory
- `cmd-shift-h` to open the project root directory

This package uses `file-explorer.ignoredNames` config settings to filter out files and directories that will not be shown. 
This config settings is interpreted as arrays of minimatch glob patterns.

![A screenshot of your spankin' package](http://cl.ly/image/0p1b3D3h2V0R/file-explorer.gif)
