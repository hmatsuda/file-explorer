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
    atom.workspaceView.command 'file-explorer:toggle-home-directory', =>
      @createFileExplorerView().toggleHomeDirectory()

    atom.workspaceView.command 'file-explorer:toggle-current-directory', =>
      @createFileExplorerView().toggleCurrentDirectory()

  deactivate: ->
    @fileExplorer.destroy()

  serialize: ->
    fileExplorerViewState: @fileExplorer.serialize()

  createFileExplorerView: ->
    unless @fileExplorer?
      @fileExplorer = new FileExplorerView()
      
    @fileExplorer
