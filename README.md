# file-explorer package

It provides SelectList View for accessing the project file and directory like File Explorer on Windows.
- `cmd-alt-n` to open the current directory
- `cmd-shift-h` to open the project root directory

When SelectListView is displayed,
- To confirm file to open confirming file at new tab
- To confirm directory to open confirming directory by SelectListView
- To confirm '..' or `cmd-[` to open parent directory by SelectListView 



This package uses `file-explorer.ignoredNames` config settings to filter out files and directories that will not be shown. 
This config settings is interpreted as arrays of minimatch glob patterns.

![A screenshot of your spankin' package](http://cl.ly/image/0p1b3D3h2V0R/file-explorer.gif)
