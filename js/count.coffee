class @Count extends Backbone.Model
  initialize: ->
    @destroy()
    @scene = @get('scene')
    @camera = @get('camera')

    # @geometry = new THREE.CubeGeometry 50, 50, 50
    @geometry = new THREE.TextGeometry(''+(@get('text') || 0), {
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
    THREE.GeometryUtils.center( @geometry )

    # @material = new THREE.MeshLambertMaterial({color: 0xFF0000 })
    @material = new THREE.MeshBasicMaterial({color: 0xFF0000 })
    @mesh = @_generateMesh()
    return

  destroy: ->
    @trigger 'destroy'

    if @mesh
      @scene.remove @mesh
      @mesh = undefined

    @scene = @camera = @geometry = @material = undefined
    super()

  _generateMesh: ->
    mesh = new THREE.Mesh( @geometry, @material )

    mesh.position.x = 0
    mesh.position.y = 0
    mesh.position.z = @camera.position.z - 120
    mesh

  hide: -> @scene.remove @mesh if @mesh
  show: -> @scene.add @mesh if @mesh

  # progress should be a number between 0.0 and 1.0 (but this is not really necessary)
  update: (progress) ->
    @show()
    if @mesh
      p = Math.sin(progress * Math.PI/2)
      @mesh.rotation.y = Math.PI/2 - Math.sin(progress * Math.PI) * Math.PI*0.5
      @mesh.rotation.z = Math.PI/2 - Math.sin(progress * Math.PI) * Math.PI*0.5
      s = 5 - Math.sin(p * Math.PI) * 4
      # s = 2.5 + Math.abs((progress - 0.5)) * 2.5
      @mesh.scale = new THREE.Vector3(s,s,s)







