path = require 'path'
fs = require 'fs'
{$$, SelectListView} = require 'atom'

module.exports =
class CurrentFolderFinderView extends SelectListView
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
    
  populate: ->
    @displayFiles.length = 0
    unless @currentFolderPath?  
      @currentFolderPath = path.dirname(atom.workspace.getActiveEditor().getPath())
    currentFileName = path.basename(atom.workspace.getActiveEditor().getPath())
                           
    # parent folder
    if @currentFolderPath.split(path.sep).length > atom.project.getRootDirectory().getRealPathSync().split(path.sep).length
      @displayFiles.push {path: path.dirname(@currentFolderPath), parent: true}
    
    for file in fs.readdirSync(@currentFolderPath)
      fileFullPath = path.join(@currentFolderPath, file)
      if file isnt currentFileName
        @displayFiles.push {path: fileFullPath}
          
    @setItems @displayFiles

  viewForItem: (item) ->
    stat = fs.statSync(item.path)
    $$ ->
      @li class: 'two-lines', =>
        if item.parent?
          @div "..", class: "primary-line file icon icon-file-directory"
        else if stat.isDirectory()
          @div path.basename(item.path), class: "primary-line file icon icon-file-directory"
          @div atom.project.relativize(item.path), class: 'secondary-line path no-icon'
        else 
          @div path.basename(item.path), class: "primary-line file icon icon-file-text"
          @div atom.project.relativize(item.path), class: 'secondary-line path no-icon'
  
  confirmed: (item) ->
    stat = fs.statSync(item.path)
    if stat.isFile()
      atom.workspaceView.open item.path
    else if stat.isDirectory()
      @currentFolderPath = item.path
      @toggle(false)
      @toggle(false)
      
    
  toggle: (root) ->
    if root is false and !atom.workspace.getActiveEditor().getPath()?
      return atom.beep()

    @currentFolderPath = if root is true then atom.project.getRootDirectory().getRealPathSync() else @currentFolderPath
    
    if @hasParent()
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
