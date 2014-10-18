# file-explorer package

It provides SelectList View for accessing the project file and directory like fuzzy-finder.
- `cmd-alt-n` to open the current directory
- `cmd-shift-h` to open the project root directory

This package uses both the `core.ignoredNames` and `file-explorer.ignoredNames` config settings to filter out files and folders that will not be shown. 
Both of those config settings are interpreted as arrays of minimatch glob patterns.

This package also will also not show Git ignored files when the core.excludeVcsIgnoredPaths is enabled.

![A screenshot of your spankin' package](http://cl.ly/image/0p1b3D3h2V0R/file-explorer.gif)
