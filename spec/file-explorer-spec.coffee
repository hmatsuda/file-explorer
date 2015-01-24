path = require 'path'
fs = require 'fs'
temp = require 'temp'
wrench = require 'wrench'

{$, $$} = require 'atom-space-pen-views'
FileExplorer = require '../lib/file-explorer'

describe "FileExplorer", ->
  activationPromise = null
  [fileExplorerView, editorElement] = []

  beforeEach ->
    # set Project Path to temporaly directory.
    tempPath = fs.realpathSync(temp.mkdirSync('atom'))
    fixturesPath = atom.project.getPaths()[0]
    wrench.copyDirSyncRecursive(fixturesPath, tempPath, forceDelete: true)
    atom.project.setPaths([tempPath])
    
    atom.packages.activatePackage('file-explorer')

  describe "toggle-current-directory", ->
    beforeEach ->
      waitsForPromise ->
        atom.workspace.open(path.join(atom.project.getPaths()[0], 'dir1', "text1.txt"))
  
    it "shows current files and directories and selects the first", ->
      editorElement = atom.views.getView(atom.workspace.getActiveTextEditor())
      
      atom.commands.dispatch editorElement, 'file-explorer:toggle-current-directory'
      atom.commands.dispatch editorElement, 'file-explorer:go-parent'
      
  describe "toggle-home-directory", ->
    beforeEach ->
      waitsForPromise ->
        atom.workspace.open(path.join(atom.project.getPaths()[0], 'dir1', "text1.txt"))
  
    it "shows home files and directories and selects the first", ->
      editorElement = atom.views.getView(atom.workspace.getActiveTextEditor())
      
      atom.commands.dispatch editorElement, 'file-explorer:toggle-home-directory'
  
