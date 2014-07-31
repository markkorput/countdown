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
    # materials = _.map @get('shaders') || [THREE.BgPendingChaosShader], (shader) ->
    #   new THREE.ShaderMaterial( shader )

    obj = new BackgroundShaders()
    _.map obj.fragmentShaders, (fragmentShader) ->
      shader = {uniforms: obj.uniforms, vertexShader: obj.vertexShader, fragmentShader: fragmentShader}
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


BackgroundShaders = ->
  @uniforms = {
    'time': {type: 'f', value: 0.0}
  }

  @vertexShader =  THREE.DefaultVertexShader

  @fragmentShaders = []

  @fragmentShaders.push """
    #ifdef GL_ES
    precision mediump float;
    #endif

    uniform float time;

    void main( void ) {
      gl_FragColor = vec4(1.0 - sin((gl_FragCoord.y + gl_FragCoord.x)/2.0+(time*10.0)));
    }
  """

  @fragmentShaders.push """
    #ifdef GL_ES
    precision mediump float;
    #endif

    uniform float time;

    void main( void ) {
      gl_FragColor = vec4(sin(gl_FragCoord.x/2.0+(time*10.0))) + vec4(sin(gl_FragCoord.y/2.0+(time*10.0)));
    }
  """

  @fragmentShaders.push """
    #ifdef GL_ES
    precision mediump float;
    #endif

    uniform float time;

    void main( void ) {
      gl_FragColor = vec4(sin(length(gl_FragCoord.xy / 200.0) * 96.0 + time * 10.0));
    }
  """

  @fragmentShaders.push """
    #ifdef GL_ES
    precision mediump float;
    #endif

    uniform float time;

    vec2 pixelate(vec2 pos, vec2 size) {
      size = 1000.0/size;
      return floor(pos * size) / size;
    }

    float plasma1(vec2 pos) {
      return sin((10.0*pos.x) + time);
    }

    float plasma2(vec2 pos) {
      return sin(10.0*(pos.x*sin(time/2.0) + pos.y*cos(time/3.0)) + time);
    }

    float plasma3(vec2 pos) {
      float centerX = pos.x + 0.5*sin(time/5.0);
      float centerY = pos.y + 0.5*cos(time/3.0);
      return sin(sqrt(100.0*(centerX*centerX + centerY*centerY) + 1.0) + time);
    }

    void main( void ) {
      float wrinkle = cos(gl_FragCoord.y * 0.1 + time * 0.01);
      float clr = sin(gl_FragCoord.x * 0.7 + wrinkle * 100.0 * sin(time * 0.01));
      gl_FragColor = vec4(clr);
    }
  """
