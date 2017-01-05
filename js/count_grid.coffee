class @CountGrid extends Backbone.Model
  initialize: ->
    @destroy()

    #
    # create event hooks
    #

    # propagate change:shown (true|false) events into 'show' and 'hide' events
    @on 'change:shown', (model, value, obj) ->
      model.trigger({true: 'show', false: 'hide'}[value], model)

    # make sure we have meshes when being shown
    @on 'show', (model) ->
      # if meshes DON'T already exist; generate meshes first
      if !model.get('meshes')
        model.set(meshes: model._generateMeshes())

      # add existing or newly created meshes to the scene
      if model.get('scene')
        _.each model.get('meshes') || [], (mesh) ->
          model.get('scene').add mesh

    # when we get a new meshes; make sure the any previous meshes get removed from the scene
    @on 'change:meshes', (model, value, obj) ->
      if s = model.get('scene')
        _.each model.previous('meshes') || [], (mesh) ->
          s.remove mesh

    # remove meshes from scene when hiding
    @on 'hide', (model) ->
      if s = model.get('scene')
        _.each model.get('meshes') || [], (mesh) ->
          s.remove(mesh)

    @on 'change:color', (model, value, obj) ->
      # when the color attribute changes, see if we have a mesh loaded, if so, change it's material's color directly
      _.each model.get('meshes') || [], (mesh) ->
        mesh.material.color = value if mesh.material

    @on 'change:meshes', ((model, value, obj) => @reposition(value)), this

    @get('count').on 'show', @show, this
    @get('count').on 'hide', @hide, this

    # start hidden by default
    @hide() if @get('shown') == undefined

  destroy: ->
    @trigger 'destroy'
    @hide()
    super()

  _generateMeshes: ->
    meshes = _.map _.range(@get('rows') || 3), (row, cidx, clist) =>
      _.map _.range(@get('cols') || 3), (col, cidx, clist) =>
        mesh = @get('count').get('mesh').clone()
        mesh.rotation.set(0,0,0)
        mesh.scale.set(1,1,1)
        return mesh

    return _.flatten(meshes)

  hide: -> @set(shown: false)
  show: -> @set(shown: true)

  reposition: (meshes) ->
    _.each meshes, (mesh, idx, list) =>
      mesh.position.set(list.length/-2+idx * 100, 0, @get('camera').position.z - 500)