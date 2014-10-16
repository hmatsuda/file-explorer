path = require 'path'
fs = require 'fs'
{$$, SelectListView} = require 'atom'

module.exports =
class FileExplorerView extends SelectListView
  displayFiles: []
  currentFolderPath: null
  
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
    @displayFiles.length = 0
    unless @currentFolderPath?  
      @currentFolderPath = path.dirname(atom.workspace.getActiveEditor().getPath())
    currentFileName = path.basename(atom.workspace.getActiveEditor().getPath())
                           
    # parent folder
    if @currentFolderPath.split(path.sep).length > atom.project.getRootDirectory().getRealPathSync().split(path.sep).length
      @displayFiles.push {filePath: path.dirname(@currentFolderPath), fileName: file, parent: true}
    
    for file in fs.readdirSync(@currentFolderPath)
      fileFullPath = path.join(@currentFolderPath, file)
      if file isnt currentFileName
        @displayFiles.push {filePath: fileFullPath, fileName: file}
          
    @setItems @displayFiles

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
    else if stat.isDirectory()
      @currentFolderPath = filePath
      @openDirectory()
      
  openDirectory: ->
    _currentFolderPath = @currentFolderPath
    @toggle(false)
    @currentFolderPath = _currentFolderPath
    @toggle(false)
    
    
  toggle: (root) ->
    if root is false and !atom.workspace.getActiveEditor()?.getPath()?
      return atom.beep()

    @currentFolderPath = if root is true then atom.project.getRootDirectory().getRealPathSync() else @currentFolderPath
    
    if @hasParent()
      @currentFolderPath = null
      @cancel()
    else
      @populate()
      @attach() if @displayFiles?.length > 0
      
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
