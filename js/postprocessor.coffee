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
    
    # @dotScreenEffect = new THREE.ShaderPass( THREE.DotScreenShader )
    # @dotScreenEffect.uniforms[ 'scale' ].value = 4
    # @composer.addPass( @dotScreenEffect )
    # @on 'update', (model) ->
    #     tmp = 150 + Math.sin((model.frame || 0.0)*0.1)*106
    #     model.dotScreenEffect.uniforms.tSize.value = new THREE.Vector2(tmp,tmp)

    # @rgbShiftEffect = new THREE.ShaderPass( THREE.RGBShiftShader )
    # @rgbShiftEffect.uniforms[ 'amount' ].value = 0.0015;
    # @rgbShiftEffect.renderToScreen = true
    # @composer.addPass @rgbShiftEffect
    # @on 'update', (model) ->
    #     model.rgbShiftEffect.uniforms.amplitude.value = Math.sin(model.frame || 0.0) * 0.03

    @blindsEffect = new THREE.ShaderPass( THREE.BlindsShader )
    @blindsEffect.renderToScreen = true
    @composer.addPass @blindsEffect
    @on 'update', (model, opts) ->
        opts = opts.blinds || {}
        model.blindsEffect.uniforms.progress.value = opts.progress || 0.0
        model.blindsEffect.uniforms.color.value = opts.color || new THREE.Color(1.0, 0.0, 0.0)

  destroy: ->
    @trigger 'destroy'

    if @composer
      @composer = undefined

    @dotScreenEffect = @rgbShiftEffect = @scene = @camera = undefined

  update: (opts) ->
    @frame ||= 0
    @trigger 'update', this, opts
    @frame += 0.05
