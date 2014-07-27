class @Count extends Backbone.Model
  initialize: ->
    @destroy()
    @scene = @get('scene')
    @camera = @get('camera')

    @sourceRotation = Math.PI*0.5
    @deltaRotation = Math.PI*-0.5
    if Math.random() > 0.5
      @sourceRotation = @sourceRotation * -1
      @deltaRotation = @deltaRotation * -1
    @sourceScale = 5
    @deltaScale = -4

    @on 'change:shown', ((model, value, obj)->
      # when the 'shown' attribute changes to true; initialize a new mesh and add it to the scene
      if value == true
        if @mesh
          @_randomizeColor()
        else
          @mesh = @_generateMesh() 
        @scene.add @mesh
        return

      # when the 'shown' attribute changes to false; remove the mesh (if one was found) from the scene
      @scene.remove @mesh if @mesh  # && value == false
    ), this

    # start with 'shown' set to false by default
    @hide() if @get('shown') == undefined

  destroy: ->
    @trigger 'destroy'

    if @mesh
      @scene.remove @mesh
      @mesh = undefined

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
    # @material = new THREE.MeshLambertMaterial({color: 0xFF0000 })
    new THREE.MeshBasicMaterial({color: 0xFF0000 })

  _generateMesh: ->
    mesh = new THREE.Mesh( @geometry || @_generateGeometry(), @material || @_generateMaterial() )
    mesh.position.x = 0
    mesh.position.y = 0
    mesh.position.z = @camera.position.z - 120
    @_randomizeColor(mesh)
    mesh

  _randomizeColor: (mesh) ->
    mesh ||= @mesh
    clr = mesh.material.color.getHSL()
    mesh.material.color.setHSL Math.random(), clr.s, clr.l

  hide: -> @set(shown: false) 
  
  # progress should be a number between 0.0 and 1.0 (but this is not really necessary)
  show: (progress) ->
    # an attirbute change callback will make sure the mesh is created when 'shown' changes to true
    @set(shown: true)

    return if !@mesh
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

    @mesh.rotation.y = r
    @mesh.rotation.z = r
    @mesh.scale = new THREE.Vector3(s,s,s)








