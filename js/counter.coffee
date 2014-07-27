class @Counter extends Backbone.Model
  initialize: ->
    @amount = 10

    @counts = _.map _.range(@amount), (number, idx, list) =>
      # create count animation
      new Count(scene: @get('scene'), camera: @get('camera'), text: number)

  update: (progress) ->
    @set(progress: progress)

    # get index of current visible number
    idx = @currentIndex()

    # hide all count numbers
    _.each @counts, (count, i) -> count.hide() if i != idx

    # get count object of current number
    count = @counts[idx]

    # length within progress range 0.0 - 1.0 for one count
    sublength = 1.0 / @amount

    # update current number
    count.show((progress - sublength * idx) / sublength)

  currentIndex: ->
    idx = parseInt(@get('progress')*@amount)

  nextIndex: ->
    idx = @currentIndex() + 1
    idx = 0 if idx >= @amount
    return idx

  nextColor: ->
    @counts[@nextIndex()].getColor()