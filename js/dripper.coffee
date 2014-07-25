class @Dripper extends Backbone.Model
  constructor: (_opts) ->
    @options = _opts || {}
    @init()

  init: ->
    @destroy()
    @scene = @options.scene
    @camera = @options.camera

      
    # @geometry = new THREE.CylinderGeometry( 1, 1, 1, 10 ) 
    # @geometry = new THREE.SphereGeometry 1 , 25, 25 
    @geometry = new THREE.CubeGeometry 1, 1, 1 


    # @material = new THREE.MeshBasicMaterial( { color: 0xffffff } )
    # @material = new THREE.MeshNormalMaterial( { color: 0xffffff } )
    @material = new THREE.MeshLambertMaterial({color: 0xFF0000 })
    # @material = new THREE.ShaderMaterial
    #   vertexShader:   $('#vert-shader').text()
    #   fragmentShader: $('#frag-shader').text()

    @drips = []

  destroy: ->
    @trigger 'destroy'

    if @cube
      @scene.remove @cube
      @cube = undefined

    @scene = @camera = undefined

  generateDrip: ->
    mesh = new THREE.Mesh( @geometry, @material )
    mesh.position.x = -50 + Math.random() * 100
    mesh.position.y = -50 + Math.random() * 100
    mesh.position.z = @camera.position.z - mesh.geometry.depth - 0.1
    # console.log mesh
    # mesh.name = "drip_"+@lastDrip
    mesh

  update: ->
    curDrip = new Date().getTime()
    return if @lastDrip && (curDrip - @lastDrip) < (@options.drip_delay || 100)
    @lastDrip = curDrip

    # create new particle
    drip = @generateDrip()
    @drips.push drip
    @scene.add drip
    # console.log "Dripping... new number of drips: " + @drips.length

    while @drips[0] && Math.abs(@camera.position.z - @drips[0].position.z) > (@options.max_depth || 5000)
      # remove from scene
      @scene.remove @drips[0]
      # remove from array
      @drips = @drips.slice(1)





