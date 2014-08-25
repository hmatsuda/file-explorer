CurrentFolderFinderView = require './current-folder-finder-view'

module.exports =
  CurrentFolderFinderView: null

  activate: (state) ->
    atom.workspaceView.command 'current-folder-finder:explore', =>
      @createCurrentFolderFinderView().toggle(true)

    atom.workspaceView.command 'current-folder-finder:explore_current_folder', =>
      @createCurrentFolderFinderView().toggle(false)


  deactivate: ->
    @currentFolderFinder.destroy()

  serialize: ->
    currentFolderFinderViewState: @currentFolderFinder.serialize()

  createCurrentFolderFinderView: ->
    unless @currentFolderFinder?
      @currentFolderFinder = new CurrentFolderFinderView()
      
    @currentFolderFinder
