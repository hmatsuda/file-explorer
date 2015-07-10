path = require 'path'
fs = require 'fs'
{Minimatch} = require 'minimatch'
{$$, SelectListView} = require 'atom-space-pen-views'

module.exports =
class FileExplorerView extends SelectListView
  @selectedDirectoryPath: null
  
  initialize: ->
    super()
    @addClass('overlay from-top file-explorer-view')
        
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
  
  cancelled: ->
    @hide()
    
  confirmed: ({filePath, parent}) ->
    stat = fs.statSync(filePath)
    if stat.isFile()
      atom.workspace.open filePath
    else if stat.isDirectory()
      @openDirectory(filePath)
      
  goParent: ->
    if @selectedDirectoryPath is atom.project.getDirectories()[0].getRealPathSync() 
      atom.beep()
    else
      @openDirectory(path.dirname(@selectedDirectoryPath))

  toggleHomeDirectory: ->
    @toggle(atom.project.getDirectories()[0].getRealPathSync())
    
  toggleCurrentDirectory: ->
    activeEditor = atom.workspace.getActiveTextEditor()
    projectPath = atom.project.getDirectories()[0].getRealPathSync()

    if activeEditor?.getPath()? and activeEditor.getPath().indexOf(projectPath) isnt -1
      @toggle(path.dirname(activeEditor.getPath()))
    else
      atom.beep()
    
  toggle: (targetDirectory) ->
    if !targetDirectory?
      return atom.beep()

    if @panel?.isVisible()
      @cancel()
    else
      @populate(targetDirectory)
      @show()
      
  show: ->
    @panel ?= atom.workspace.addModalPanel(item: this)
    @panel.show()
    
    @storeFocusedElement()
    @focusFilterEditor()
    
  hide: ->
    @panel?.hide()
    
  populate: (targetDirectoryPath) ->
    @selectedDirectoryPath = targetDirectoryPath
    displayFiles = []
                           
    unless @isProjectRoot(targetDirectoryPath)
      displayFiles.push {filePath: path.dirname(targetDirectoryPath), fileName: '..', parent: true}
    
    for file in fs.readdirSync(targetDirectoryPath)
      fileFullPath = path.join(targetDirectoryPath, file)
      stat = fs.lstatSync(fileFullPath)
      continue if stat.isSymbolicLink() and !fs.existsSync(fileFullPath)
      continue if @matchIgnores(file)
      displayFiles.push {filePath: fileFullPath, fileName: file}
          
    @setItems displayFiles
      
  openDirectory: (targetDirectory) ->
    @cancel()
    @toggle(targetDirectory)

  isProjectRoot: (selectedDirectoryPath) ->
    if selectedDirectoryPath.split(path.sep).length > atom.project.getDirectories()[0].getRealPathSync().split(path.sep).length
      return false
    else
      return true
    
  matchIgnores: (fileName) ->
    activeEditor = atom.workspace.getActiveTextEditor()
    if activeEditor?.getPath()?
      currentFileName = path.basename(activeEditor.getPath())
      return true if fileName is currentFileName and atom.config.get("file-explorer.excludeActiveFile") is true
    
    ignoredNames = for ignores in atom.config.get("file-explorer.ignoredNames")
      new Minimatch(ignores, matchBase: true, dot: true) 
      
    for ignoredName in ignoredNames
      return true if ignoredName.match(fileName)
