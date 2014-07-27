class @App extends Backbone.Model
	initialize: ->
		@init()

	init: ->
		@controls = new Controls()
		@controls.on 'toggle-loop', ((value) -> @timer.set(loop: value).start()), this
		@controls.on 'timeline', ((value) -> @timer.setProgress(value)), this
		@controls.on 'toggle-playing', ((playing)-> @set(paused: !playing)), this

		@on 'change:paused', ((app, paused, obj) -> @timer.setPaused(paused)), this

		@timer = new Timer(duration: 10000)
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

		@camera_operator = new CameraOperator(camera: @camera, scene: @scene, speed: 0, rotation_speed: 0.0)
		# @on 'update', (-> @camera_operator.update()), this

		# @post_processor = new PostProcessor(renderer: @renderer, camera: @camera, scene: @scene)
		# @on 'update', (-> @post_processor.update()), this

		@counts =	_.map _.range(10), (number, idx, list) =>
			# create count animation
			new Count(scene: @scene, camera: @camera, text: number)

		@timer.on 'change:progress', (timer, progress, obj) =>
			# get index of current visible number
			idx = parseInt(progress*10)

			# hide all count numbers
			_.each @counts, (count, i) -> count.hide() if i != idx

			# get count object of current number
			count = @counts[idx]

			# update current number
			count.show((progress - 0.1 * idx) / 0.1)

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


