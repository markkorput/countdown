class @Astroid extends Backbone.Model
  initialize: ->
    @destroy()
    @scene = @get('scene')
    @camera = @get('camera') 

    @geometry = new THREE.CubeGeometry 50, 50, 50
    @material = new THREE.MeshLambertMaterial({color: 0xFF0000 })
    @mesh = @_generateMesh()

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
    mesh.position.z = @camera.position.z - 100
    mesh

  hide: -> @scene.remove @mesh if @mesh
  show: -> @scene.add @mesh if @mesh

  # progress should be a number between 0.0 and 1.0 (but this is not really necessary)
  update: (progress) ->
    @show()
    if @mesh
      @mesh.position.z = @camera.position.z - 100 - 40 * progress
      @mesh.rotation.x += progress * -0.02
      @mesh.rotation.y += progress * 0.01
      s = Math.sin(progress * Math.PI)
      @mesh.scale = new THREE.Vector3(s,s,s)







