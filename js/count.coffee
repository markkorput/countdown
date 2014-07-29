class @Count extends Backbone.Model
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
      model.set(mesh: @_generateMesh()) 

    # (re-)initialize the transformation params everytime when being shown
    @on 'show', (model) ->
      model.sourceRotation = Math.PI*0.5
      model.deltaRotation = Math.PI*-0.5
      if Math.random() > 0.5
        model.sourceRotation = model.sourceRotation * -1
        model.deltaRotation = model.deltaRotation * -1
      model.sourceScale = 5
      model.deltaScale = -4

    # when we get a new mesh; add it to the scene
    @on 'change:mesh', (model, value, obj) ->
      if model.scene
        model.scene.remove model.previous('mesh') if model.previous('mesh')
        model.scene.add value 

    # remove mesh from scene when hiding
    @on 'hide', (model) ->
      model.randomizeColor()

      if model.scene && m = model.get('mesh')
        model.scene.remove m

    @on 'change:color', (model, value, obj) ->
      model.set(mesh: @_generateMesh())

    # start hidden by default
    @hide() if @get('shown') == undefined

  destroy: ->
    @trigger 'destroy'
    @hide
    @scene = @camera = undefined
    super()

  _generateGeometry: ->
    # geometry = new THREE.CubeGeometry 50, 50, 50
    geometry = new THREE.TextGeometry(''+(@get('text') || 0), {
      size: 40,
      height: 5,
      curveSegments: 30,
      font: "helvetiker",
      weight: "bold",
      style: "normal",
      # bevelThickness: 2,
      bevelSize: 1,
      bevelEnabled: true
    })

    THREE.GeometryUtils.center( geometry )
    return geometry

  _generateMaterial: ->

    # @material = new THREE.MeshLambertMaterial({color: @get('color') || @_defaultColor()})
    new THREE.MeshBasicMaterial({color: @getColor()})

  _generateMesh: ->
    mesh = new THREE.Mesh( @geometry || @_generateGeometry(), @material || @_generateMaterial() )
    mesh.position.x = 0
    mesh.position.y = 0
    mesh.position.z = @camera.position.z - 120
    mesh

  _defaultColor: -> new THREE.Color(255, 0, 0)

  randomizeColor: ->
    clr = @get('color').clone() if @get('color')
    clr ||= mesh.material.color.getHSL() if mesh = @get('mesh')
    clr ||= @_defaultColor()
    hsl = clr.getHSL()
    clr.setHSL Math.random(), hsl.s, hsl.l
    @set(color: clr)

  getColor: -> @get('color') || @_defaultColor()

  hide: -> @set(shown: false) 
  
  # progress should be a number between 0.0 and 1.0 (but this is not really necessary)
  show: (progress) ->
    # an attribute change callback will make sure the mesh is created when 'shown' changes to true
    @set(shown: true)

    return if !(mesh = @get('mesh'))
    if progress < 0.1 || progress > 0.9
      p = progress
      r = @sourceRotation
      s = @sourceScale
    else
      # p = Math.sin(progress * Math.PI/2)
      p = (progress - 0.1) / 0.8
      r = @sourceRotation + Math.sin(p * Math.PI) * @deltaRotation
      s = @sourceScale + Math.sin(p * Math.PI) * @deltaScale
      # s = 2.5 + Math.abs((p - 0.5)) * 2.5

    mesh.rotation.y = r
    mesh.rotation.z = r
    mesh.scale = new THREE.Vector3(s,s,s)








