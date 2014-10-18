path = require 'path'
fs = require 'fs'
{Minimatch} = require 'minimatch'
{$$, SelectListView} = require 'atom'

module.exports =
class FileExplorerView extends SelectListView
  
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
      @openDirectory(filePath)

  toggleHomeDirectory: ->
    @toggle(atom.project.getRootDirectory().getRealPathSync())
    
  toggleCurrentDirectory: ->
    activeEditor = atom.workspace.getActiveEditor()
    projectPath = atom.project.getRootDirectory().getRealPathSync()

    if activeEditor?.getPath()? and activeEditor.getPath().indexOf(projectPath) isnt -1
      @toggle(path.dirname(activeEditor.getPath()))
    else
      atom.beep()
    
  toggle: (targetDirectory) ->
    if !targetDirectory?
      return atom.beep()

    if @hasParent()
      @setItems []
      @cancel()
    else
      @populate(targetDirectory)
      @attach()
      
  attach: ->
    @storeFocusedElement()
    atom.workspaceView.append(this)
    @focusFilterEditor()
    
  populate: (selectedDirectoryPath) ->
    displayFiles = []
                           
    unless @isProjectRoot(selectedDirectoryPath)
      displayFiles.push {filePath: path.dirname(selectedDirectoryPath), fileName: file, parent: true}
    
    for file in fs.readdirSync(selectedDirectoryPath)
      fileFullPath = path.join(selectedDirectoryPath, file)
      continue if @matchIgnores(file)
      displayFiles.push {filePath: fileFullPath, fileName: file}
          
    @setItems displayFiles
      
  openDirectory: (targetDirectory) ->
    @cancel()
    @toggle(targetDirectory)

  splitOpenPath: (fn) ->
    filePath = @getSelectedItem() ? {}
    return unless filePath

    if pane = atom.workspaceView.getActivePane()
      atom.project.open(filePath).done (editor) =>
        fn(pane, editor)
    else
      atom.workspaceView.open filePath

  isProjectRoot: (selectedDirectoryPath) ->
    if selectedDirectoryPath.split(path.sep).length > atom.project.getRootDirectory().getRealPathSync().split(path.sep).length
      return false
    else
      return true
    
  matchIgnores: (fileName) ->
    currentFileName = path.basename(atom.workspace.getActiveEditor().getPath())
    return true if fileName is currentFileName and atom.config.get("file-explorer.excludeActiveFile") is true
    
    ignoredNames = for ignores in atom.config.get("file-explorer.ignoredNames")
      new Minimatch(ignores, matchBase: true, dot: true) 
      
    for ignoredName in ignoredNames
      return true if ignoredName.match(fileName)
