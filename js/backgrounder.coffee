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
        mesh = model._generateMesh()
        model.set(mesh: mesh)

      # add existing or newly created mesh to the scene
      model.scene.add mesh if model.scene && mesh

    # when we get a new mesh; make sure the any previous mesh gets removed from the scene
    @on 'change:mesh', (model, value, obj) ->
      if model.scene
        model.scene.remove model.previous('mesh') if model.previous('mesh')

    # remove mesh from scene when hiding
    @on 'hide', (model) ->
      if model.scene && m = model.get('mesh')
        model.scene.remove m

    @on 'change:color', (model, value, obj) ->
      # when the color attribute changes, see if we have a mesh loaded, if so, change it's material's color directly
      if m = model.get('mesh') && model.get('mesh').material
        model.get('mesh').material.color = value

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

  _generateMaterial: ->
    new THREE.MeshBasicMaterial({color: @getColor()})
    new THREE.ShaderMaterial( THREE.BgPendingChaosShader )

  _generateMesh: ->
    mesh = new THREE.Mesh( @geometry || @_generateGeometry(), @material || @_generateMaterial() )
    mesh.position.x = 0
    mesh.position.y = 0
    mesh.position.z = @camera.position.z - 150
    mesh

  _defaultColor: -> 0xffff00

  randomizeColor: ->
    clr = @get('color').clone() if @get('color')
    clr ||= mesh.material.color if mesh = @get('mesh')
    clr ||= @_defaultColor()
    hsl = clr.getHSL()
    clr.setHSL Math.random(), hsl.s, hsl.l
    @set(color: clr)

  getColor: -> @get('color') || @_defaultColor()

  hide: -> @set(shown: false)
  show: -> @set(shown: true)

  update: (opts) ->
    if opts.time && mesh = @get('mesh')
      mesh.material.uniforms.time.value = opts.time * 100
