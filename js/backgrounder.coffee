class @Backgrounder extends Backbone.Model
  initialize: ->
    @destroy()
    @scene = @get('scene')
    @camera = @get('camera')

    #
    # create event hooks
    #

    # propagate change:shown (true|false) events into 'show' and 'hide' events
    @on 'change:shown', (model, value, obj) ->
      model.trigger({true: 'show', false: 'hide'}[value], model)

    # make sure we have a mesh when being shown
    @on 'show', (model) ->
      # if mesh DOESN'T already exist; generate mesh first
      if !(mesh = model.get('mesh')) 
        mesh = model.allMeshes()[0]
        model.set(mesh: mesh)

    # when we get a new mesh; make sure the any previous mesh gets removed from the scene
    @on 'change:mesh', (model, value, obj) ->
      if model.scene
        model.scene.remove model.previous('mesh') if model.previous('mesh')
        # add existing or newly created mesh to the scene
        model.scene.add value
      
      
      
    # remove mesh from scene when hiding
    @on 'hide', (model) ->
      if model.scene && m = model.get('mesh')
        model.scene.remove m

    # start hidden by default
    @show() if @get('shown') == undefined

  destroy: ->
    @trigger 'destroy'
    @trigger 'hide'
    @scene = @camera = undefined
    super()

  _generateGeometry: ->
    geometry = new THREE.PlaneGeometry(300, 120)
    THREE.GeometryUtils.center( geometry )
    return geometry

  _generateMaterials: ->
    materials = _.map @get('shaders') || [THREE.BgPendingChaosShader], (shader) ->
      new THREE.ShaderMaterial( shader )

  _generateMeshes: ->
    _.map @_generateMaterials(), (material) =>
      mesh = new THREE.Mesh( @geometry || @_generateGeometry(), material )
      mesh.position.x = 0
      mesh.position.y = 0
      mesh.position.z = @camera.position.z - 150
      mesh

  allMeshes: ->
    @_all_meshes ||= @_generateMeshes()

  randomize: ->
    @set(mesh: _.sample(@allMeshes()))

  hide: -> @set(shown: false)
  show: -> @set(shown: true)

  update: (opts) ->
    @show()

    if opts.time && mesh = @get('mesh')
      mesh.material.uniforms.time.value = opts.time * 100
