path = require 'path'
fs = require 'fs'
temp = require 'temp'
wrench = require 'wrench'

{$, WorkspaceView} = require 'atom'
FileExplorer = require '../lib/file-explorer'

describe "FileExplorer", ->
  activationPromise = null
  [workspaceView, editor] = []

  beforeEach ->
    # set Project Path to temporaly directory.
    tempPath = fs.realpathSync(temp.mkdirSync('atom'))
    fixturesPath = atom.project.getPath()
    wrench.copyDirSyncRecursive(fixturesPath, tempPath, forceDelete: true)
    atom.project.setPath(tempPath)
    atom.workspaceView = new WorkspaceView
    activationPromise = atom.packages.activatePackage('file-explorer')

  describe "toggle-current-directory", ->
    describe "when active editor opens no file", ->
      it "beeps", ->
        atom.workspaceView.trigger 'file-explorer:toggle-current-directory'
      
      # Waits until package is activated
      waitsForPromise ->
        activationPromise

    describe "when active editor opens file", ->
      beforeEach ->
        atom.workspaceView.openSync(path.join(atom.project.getPath(), 'dir1', "text1.txt"))
    
      it "shows current files and directories and selects the first", ->
        expect(atom.workspaceView.find('.file-explorer')).not.toExist()

        # This is an activation event, triggering it will cause the package to be
        # activated.
        atom.workspaceView.trigger 'file-explorer:toggle-current-directory'
  
        # Waits until package is activated
        waitsForPromise ->
          activationPromise
  
        runs ->
          expect(atom.workspaceView.find('.select-list')).toExist()

          currentDir = path.join(atom.project.getPath(), "dir1")
          expect(atom.workspaceView.find('.select-list li').length).toBe fs.readdirSync(currentDir).length
          for entry in fs.readdirSync(currentDir)
            continue if entry is "text1.txt"
            expect(atom.workspaceView.find(".select-list:contains(#{path.basename(entry)})")).toExist()
            expect(atom.workspaceView.find(".select-list .secondary-line:contains(#{atom.project.relativize(path.join(currentDir, entry))})")).toExist()
  
          expect(atom.workspaceView.find(".select-list li:first")).toHaveClass 'two-lines selected'
