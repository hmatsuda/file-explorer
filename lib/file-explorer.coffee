FileExplorerView = require './file-explorer-view'

module.exports =
  FileExplorerView: null

  activate: (state) ->
    atom.workspaceView.command 'file-explorer:explore', =>
      @createFileExplorerView().toggle(true)

    atom.workspaceView.command 'file-explorer:explore_current_folder', =>
      @createFileExplorerView().toggle(false)


  deactivate: ->
    @fileExplorer.destroy()

  serialize: ->
    fileExplorerViewState: @fileExplorer.serialize()

  createFileExplorerView: ->
    unless @fileExplorer?
      @fileExplorer = new FileExplorerView()
      
    @fileExplorer
