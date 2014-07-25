class @Controls extends Backbone.Model
	constructor: (_opts) ->
		@options = _opts
		@init()

	init: ->
		@destroy()

		$(document).on 'mousedown', @mousedown
		$(document).on 'keydown', @keydown

		@gui = new dat.GUI()

		@data = new ->
			# @Stripes = => 
			@timeline = 0
			@loop = true
			@playing = true

		folder = @gui.addFolder 'Animation'
		folder.open()

		item = folder.add(@data, 'playing')
		item.listen()
		item.onChange (val) => @trigger('toggle-playing', val)

		item = folder.add(@data, 'timeline', 0, 100)
		item.listen()
		item.onChange (val) => @trigger('timeline', val/100) # communicate in 0.0 - 1.0 ranges with outside

		item = folder.add(@data, 'loop')
		item.listen()
		item.onChange (val) => @trigger('toggle-loop', val)

	destroy: ->
		@trigger 'destroy'
		$(document).off 'mousedown keydown'

		if @gui
			@gui.destroy()
			@gui = undefined

	mousedown: (e) =>
		# console.log e
		# e.preventDefault()
		# e.stopPropagation()

	keydown: (e) =>
		# console.log e
		# e.preventDefault()
		# e.stopPropagation()

		# if event.which >= 48 && event.which <= 57 # 0 - 9
		@trigger 'reset' if(event.which == 27) # escape

		if event.which == 32 # SPACE
			@data.playing = (@data.playing != true)
			@trigger('toggle-playing', @data.playing)

		@trigger 'screenshot' if event.which == 13 # ENTER


