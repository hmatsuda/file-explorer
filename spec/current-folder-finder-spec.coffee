{WorkspaceView} = require 'atom'
CurrentFolderFinder = require '../lib/current-folder-finder'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "CurrentFolderFinder", ->
  activationPromise = null

  beforeEach ->
    atom.workspaceView = new WorkspaceView
    activationPromise = atom.packages.activatePackage('current-folder-finder')

  describe "when the current-folder-finder:toggle event is triggered", ->
    it "attaches and then detaches the view", ->
      expect(atom.workspaceView.find('.current-folder-finder')).not.toExist()

      # This is an activation event, triggering it will cause the package to be
      # activated.
      atom.workspaceView.trigger 'current-folder-finder:toggle'

      waitsForPromise ->
        activationPromise

      runs ->
        expect(atom.workspaceView.find('.current-folder-finder')).toExist()
        atom.workspaceView.trigger 'current-folder-finder:toggle'
        expect(atom.workspaceView.find('.current-folder-finder')).not.toExist()
