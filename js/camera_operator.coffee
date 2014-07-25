class @CameraOperator extends Backbone.Model
  constructor: (_opts) ->
    @options = _opts || {}
    @init()

  init: ->
    @destroy()
    @scene = @options.scene
    @camera = @options.camera

    @camera.position.z = 0

    @light = new THREE.PointLight(0xFF0000);
    @light.position.x = 10;
    @light.position.y = 50;
    @light.position.copy @camera.position
    @light.position.x += 3
    @light.position.y += 3

    @scene.add( @light )

  destroy: ->
    @trigger 'destroy'

    if @light
      @scene.remove @light
      @light = undefined
    
    @scene = @camera = undefined

  update: ->
    @camera.position.z += @speed()
    @camera.rotation.z += (@options.rotation_speed || 0.001)
    @light.position.z = @camera.position.z

  speed: ->
    @options.speed || 0.01
