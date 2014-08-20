CurrentFolderFinderView = require './current-folder-finder-view'

module.exports =
  CurrentFolderFinderView: null

  activate: (state) ->
    atom.workspaceView.command 'current-folder-finder:toggle', =>
      @createCurrentFolderFinderView().toggle()


  deactivate: ->
    @currentFolderFinder.destroy()

  serialize: ->
    currentFolderFinderViewState: @currentFolderFinder.serialize()

  createCurrentFolderFinderView: ->
    unless @currentFolderFinder?
      @currentFolderFinder = new CurrentFolderFinderView()
      
    @currentFolderFinder
