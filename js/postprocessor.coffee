class @PostProcessor extends Backbone.Model
  constructor: (_opts) ->
    @options = _opts || {}
    @init()

  init: ->
    @destroy()
    @renderer = @options.renderer
    @scene = @options.scene
    @camera = @options.camera

    @composer = new THREE.EffectComposer @renderer
    @composer.addPass new THREE.RenderPass( @scene, @camera )
    
    @effect1 = new THREE.ShaderPass( THREE.DotScreenShader )
    @effect1.uniforms[ 'scale' ].value = 4
    @composer.addPass( @effect1 )

    @effect2 = new THREE.ShaderPass( THREE.RGBShiftShader )
    @effect2.uniforms[ 'amount' ].value = 0.0015;
    @effect2.renderToScreen = true
    @composer.addPass @effect2

  destroy: ->
    @trigger 'destroy'

    if @composer
      @composer = undefined

    @scene = @camera = undefined

  update: ->
    @frame ||= 0
    @effect2.uniforms.amplitude.value = Math.sin(@frame) * 0.03

    tmp = 150 + Math.sin(@frame*0.1)*106
    @effect1.uniforms.tSize.value = new THREE.Vector2(tmp,tmp)

    @frame += 0.05
