FileExplorerView = require './file-explorer-view'

module.exports =
  config:
    ignoredNames:
      type: 'array'
      default: [".git", ".hg", ".svn", ".DS_Store", "Thumbs.db"]
      items:
        type: 'string'
    excludeActiveFile:
      type: 'boolean'
      default: true
  
  FileExplorerView: null

  activate: (state) ->
    fileExplorerView = @createFileExplorerView()
      
    atom.commands.add 'atom-text-editor', 'file-explorer:toggle-home-directory', =>
      @createFileExplorerView().toggleHomeDirectory()

    atom.commands.add 'atom-text-editor', 'file-explorer:toggle-current-directory', =>
      @createFileExplorerView().toggleCurrentDirectory()
    
    atom.commands.add 'atom-text-editor', 'file-explorer:go-parent', =>
      @createFileExplorerView().goParent()
    

  deactivate: ->
    @fileExplorer.destroy()

  serialize: ->
    fileExplorerViewState: @fileExplorer.serialize()

  createFileExplorerView: ->
    unless @fileExplorer?
      @fileExplorer = new FileExplorerView()
      
    @fileExplorer
