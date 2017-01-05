class @Count extends Backbone.Model
  initialize: ->
    @destroy()
    @scene = @get('scene')
    @camera = @get('camera')

    # extra; randomize color when hiding, so next time it's shown, it has a different color
    @randomizeColor()

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
    @hide() if @get('shown') == undefined

  destroy: ->
    @trigger 'destroy'
    @hide()
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

  _defaultColor: -> new THREE.Color(255, 255, 255)

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


class @CountOps extends Backbone.Model
  initialize: ->
    # we EXPECT a target
    @target = @get('target')
    @target.on 'destroy', @destroy, this

    # (re-)initialize the transformation params everytime when being shown
    @target.on 'show', @_initializeSpinscale, this
    @target.on 'show', @_initializeFall, this
 
  destroy: ->
    @trigger 'destroy', this
    @target = undefined

  hide: ->
    @target.hide()

  _initializeSpinscale: (target) ->
    @spinscale_data = {}
    @spinscale_data.rotY = @spinscale_data.rotZ = Math.PI*0.5
    @spinscale_data.deltaRotY = @spinscale_data.deltaRotZ = Math.PI*-0.5

    randY = Math.random() > 0.5
    if (target.get('text') + '') == '1' || (target.get('text') + '') == '7'
      # for the number '1' and number '7' meshes, it otherwise won't look good
      randZ = randY
    else
      randZ = Math.random() > 0.5

    if randY > 0.5
      @spinscale_data.rotY = @spinscale_data.rotY * -1
      @spinscale_data.deltaRotY = @spinscale_data.deltaRotY * -1
    if randZ > 0.5
      @spinscale_data.rotZ = @spinscale_data.rotZ * -1
      @spinscale_data.deltaRotZ = @spinscale_data.deltaRotZ * -1

    @spinscale_data.scale = 5
    @spinscale_data.deltaScale = 1 - @spinscale_data.scale

  # progress should be a number between 0.0 and 1.0 (though this is not 100% necessary)
  spinscale: (progress) ->
    @target.show()
    @_initializeSpinscale(@target) if !@spinscale_data    

    if progress < 0.1 || progress > 0.9
      ry = @spinscale_data.rotY
      rz = @spinscale_data.rotZ
      s = @spinscale_data.scale
    else
      p = (progress - 0.1) / 0.8
      ry = @spinscale_data.rotY + Math.sin(p * Math.PI) * @spinscale_data.deltaRotY
      rz = @spinscale_data.rotZ + Math.sin(p * Math.PI) * @spinscale_data.deltaRotZ
      s = @spinscale_data.scale + Math.sin(p * Math.PI) * @spinscale_data.deltaScale

    mesh = @target.get('mesh')
    mesh.rotation.y = ry
    mesh.rotation.z = rz
    mesh.scale = new THREE.Vector3(s,s,s)

  _initializeFall: (target) ->
    @fall_data = {}
    @fall_data.rotY = @fall_data.rotZ = Math.PI*0.5
    @fall_data.endRotY = @fall_data.endRotZ = 0

    randY = Math.random() > 0.5
    if (target.get('text') + '') == '1' || (target.get('text') + '') == '7'
      # for the number '1' and number '7' meshes, it otherwise won't look good
      randZ = randY
    else
      randZ = Math.random() > 0.5

    @fall_data.endRotY = @fall_data.endRotY * -1 if randY > 0.5
    @fall_data.endRotZ = @fall_data.endRotZ * -1 if randZ > 0.5
    @fall_data.startScale = 5
    @fall_data.endScale = 0.001

  fall: (progress) ->
    @target.show()
    @_initializeFall(@target) if !@fall_data

    p = progress
    s = @fall_data.startScale + (@fall_data.endScale - @fall_data.startScale) * p
    ry = @fall_data.rotY + (@fall_data.endRotY - @fall_data.rotY) * p
    rz = @fall_data.rotZ + (@fall_data.endRotZ - @fall_data.rotZ) * p

    mesh = @target.get('mesh')
    mesh.rotation.y = ry
    mesh.rotation.z = rz
    mesh.scale = new THREE.Vector3(s,s,s)
