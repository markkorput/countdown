class @App extends Backbone.Model
	initialize: ->
		@init()

	init: ->
		@controls = new Controls()
		@controls.on 'toggle-loop', ((value) -> @timer.set(loop: value).start()), this
		@controls.on 'timeline', ((value) -> @timer.setProgress(value)), this
		@controls.on 'toggle-playing', ((playing)-> @set(paused: !playing)), this
		@controls.on 'duration', ((value) -> @timer.set(duration: parseInt(value))), this

		@on 'change:paused', ((app, paused, obj) -> @timer.setPaused(paused)), this

		@timer = new Timer(duration: 20000)
		@timer.start()
		@timer.on 'change:progress', ((timer, progress, obj) -> @controls.data.timeline = progress * 100), this
		@on 'update', @timer.update, @timer

		@_initVfx()
		@_createScene()
		@update()

	_initVfx: ->
		@camera = new THREE.PerspectiveCamera(45, window.innerWidth / window.innerHeight, 1, 1000)

		# @renderer = new THREE.CanvasRenderer()
		@renderer = new THREE.WebGLRenderer() #({preserveDrawingBuffer: true}) # preserveDrawingBuffer: true allows for image exports, but has some performance implications

		# perform window-size based configuration
		@_resize()
		# add event hook, to perform re-configuration when the window resizes
		# $(window).resize @_resize

		window.addEventListener( 'resize', @_resize, false );

		# add our canvas element to the page
		document.body.appendChild(this.renderer.domElement)

	_resize: (event) ->
		if @camera
			@camera.aspect = window.innerWidth / window.innerHeight
			@camera.updateProjectionMatrix()

		if @renderer
			@renderer.setSize( window.innerWidth, window.innerHeight )

	_createScene: ->
		@scene = new THREE.Scene()

		@camera_operator = new CameraOperator(camera: @camera, scene: @scene, speed: 0, rotation_speed: 0.0)
		# @on 'update', (-> @camera_operator.update()), this

		@post_processor = new PostProcessor(renderer: @renderer, camera: @camera, scene: @scene)
		# @on 'update', (-> @post_processor.update()), this

		@counter = new Counter(scene: @scene, camera: @camera)
		@timer.on 'change:progress', ((timer, progress, obj) -> @counter.update(progress)), this


		@timer.on 'change:progress', (model, value, obj) =>
			t = (value * 10) - parseInt(value * 10)

			if t >= 0.9
				t -= 0.9
				t = t / 0.1
			else
				t = 0.0

			@post_processor.update(fade: {progress: t, color: @counter.nextColor()})


		return @scene

	update: ->
		requestAnimationFrame =>
			@update()
			@draw()

		return if @get('paused') == true
		@trigger 'update'

	draw: ->
		if @post_processor
			@post_processor.composer.render()
			return

		@renderer.render(@scene, @camera)


