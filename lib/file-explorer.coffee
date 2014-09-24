FileExplorerView = require './file-explorer-view'

module.exports =
  FileExplorerView: null

  activate: (state) ->
    atom.workspaceView.command 'file-explorer:open_project_root_folder', =>
      @createFileExplorerView().toggle(true)

    atom.workspaceView.command 'file-explorer:open_current_folder', =>
      @createFileExplorerView().toggle(false)


  deactivate: ->
    @fileExplorer.destroy()

  serialize: ->
    fileExplorerViewState: @fileExplorer.serialize()

  createFileExplorerView: ->
    unless @fileExplorer?
      @fileExplorer = new FileExplorerView()
      
    @fileExplorer
