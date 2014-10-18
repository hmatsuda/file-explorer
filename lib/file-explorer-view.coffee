path = require 'path'
fs = require 'fs'
{$$, SelectListView} = require 'atom'

module.exports =
class FileExplorerView extends SelectListView
  selectedDirectoryPath: null
  
  initialize: ->
    super
    @addClass('overlay from-top')
        
    @subscribe this, 'pane:split-left', =>
      @splitOpenPath (pane, session) -> pane.splitLeft(session)
    @subscribe this, 'pane:split-right', =>
      @splitOpenPath (pane, session) -> pane.splitRight(session)
    @subscribe this, 'pane:split-down', =>
      @splitOpenPath (pane, session) -> pane.splitDown(session)
    @subscribe this, 'pane:split-up', =>
      @splitOpenPath (pane, session) -> pane.splitUp(session)
    
  destroy: ->
    @cancel()
    @remove()
    
  getFilterKey: ->
    'fileName'
    
  populate: ->
    displayFiles = []
    currentFileName = path.basename(atom.workspace.getActiveEditor().getPath())
                           
    # Add parent directory into list
    if @selectedDirectoryPath.split(path.sep).length > atom.project.getRootDirectory().getRealPathSync().split(path.sep).length
      displayFiles.push {filePath: path.dirname(@selectedDirectoryPath), fileName: file, parent: true}
    
    for file in fs.readdirSync(@selectedDirectoryPath)
      fileFullPath = path.join(@selectedDirectoryPath, file)
      if file isnt currentFileName
        displayFiles.push {filePath: fileFullPath, fileName: file}
          
    @setItems displayFiles

  viewForItem: ({filePath, parent}) ->
    stat = fs.statSync(filePath)
    $$ ->
      @li class: 'two-lines', =>
        if parent?
          @div "..", class: "primary-line file icon icon-file-directory"
        else if stat.isDirectory()
          @div path.basename(filePath), class: "primary-line file icon icon-file-directory"
          @div atom.project.relativize(filePath), class: 'secondary-line path no-icon'
        else 
          @div path.basename(filePath), class: "primary-line file icon icon-file-text"
          @div atom.project.relativize(filePath), class: 'secondary-line path no-icon'
  
  confirmed: ({filePath, parent}) ->
    stat = fs.statSync(filePath)
    if stat.isFile()
      atom.workspaceView.open filePath
      @selectedDirectoryPath = null
    else if stat.isDirectory()
      @openDirectory(filePath)
      @selectedDirectoryPath = filePath
      
  openDirectory: (targetDirectory) ->
    @cancel()
    @toggle(targetDirectory)
    
  toggleHomeDirectory: ->
    @toggle(atom.project.getRootDirectory().getRealPathSync())
    
  toggleCurrentDirectory: ->
    @toggle(path.dirname(atom.workspace.getActiveEditor().getPath()))
    
  toggle: (targetDirectory) ->
    if !targetDirectory?
      return atom.beep()

    if @hasParent()
      @selectedDirectoryPath = null
      @cancel()
    else
      @selectedDirectoryPath = targetDirectory
      @populate()
      @attach()
  
  cancel: ->
    @selectedDirectoryPath = null
    super
      
  attach: ->
    @storeFocusedElement()
    atom.workspaceView.append(this)
    @focusFilterEditor()

  splitOpenPath: (fn) ->
    filePath = @getSelectedItem() ? {}
    return unless filePath

    if pane = atom.workspaceView.getActivePane()
      atom.project.open(filePath).done (editor) =>
        fn(pane, editor)
    else
      atom.workspaceView.open filePath
