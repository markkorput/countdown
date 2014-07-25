class @App extends Backbone.Model
	initialize: ->
		@init()

	init: ->
		@controls = new Controls()
		@controls.on 'toggle-loop', ((value) -> @timer.set(loop: value).start()), this
		@controls.on 'timeline', ((value) -> @timer.setProgress(value)), this
		@controls.on 'toggle-playing', ((playing)-> @set(paused: !playing)), this

		@on 'change:paused', ((app, paused, obj) -> @timer.setPaused(paused)), this

		@timer = new Timer(duration: 3000)		
		@timer.start()
		@timer.on 'change:progress', ((timer, progress, obj) -> @controls.data.timeline = progress * 100), this
		@on 'update', @timer.update, @timer

		@_initVfx()
		@_createScene()
		@update()

	_initVfx: ->
		# @camera = new THREE.OrthographicCamera(-1200, 1000, -1100, 1200, 10, 10000)
		@camera = new THREE.PerspectiveCamera(45, window.innerWidth / window.innerHeight, 1, 1000)

		# @renderer = new THREE.CanvasRenderer()
		@renderer = new THREE.WebGLRenderer() #({preserveDrawingBuffer: true}) # preserveDrawingBuffer: true allows for image exports, but has some performance implications

		# perform window-size based configuration
		@_resize()
		# add event hook, to perform re-configuration when the window resizes
		$(window).resize @_resize

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

		@dripper = new Dripper(scene: @scene, camera: @camera, drip_delay: 30)
		@on 'update', (-> @dripper.update()), this

		@camera_operator = new CameraOperator(camera: @camera, scene: @scene, speed: 3, rotation_speed: 0.01)
		@on 'update', (-> @camera_operator.update()), this

		@post_processor = new PostProcessor(renderer: @renderer, camera: @camera, scene: @scene)
		@on 'update', (-> @post_processor.update()), this

		# create astroid; a timer-managed animation object
		@astroid = new Astroid(scene: @scene, camera: @camera)
		# controlled by timeline; an animation that shows between 0.3 and 0.8
		@timer.on 'change:progress', (timer, progress, obj) =>
			if progress < 0.3 || progress > 0.8
				@astroid.hide()
				return

			@astroid.update((progress - 0.3) / (0.8-0.3))


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


