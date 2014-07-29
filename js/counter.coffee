class @Counter extends Backbone.Model
  initialize: ->
    @amount = 10

    @count_ops = _.map _.range(@amount), (number, idx, list) =>
      # create count animation
      count = new Count(scene: @get('scene'), camera: @get('camera'), text: number)
      count_op = new CountOps(target: count)

  update: (progress) ->
    @set(progress: progress)

    # get index of current visible number
    idx = @currentIndex()

    # hide all count numbers
    _.each @count_ops, (op, i) -> op.hide() if i != idx

    # get count object of current number
    op = @count_ops[idx]

    # length within progress range 0.0 - 1.0 for one count
    sublength = 1.0 / @amount

    # update current number
    op.spinscale((progress - sublength * idx) / sublength)

  currentIndex: ->
    idx = parseInt(@get('progress')*@amount)

  nextIndex: ->
    idx = @currentIndex() + 1
    idx = 0 if idx >= @amount
    return idx

  nextColor: ->
    @count_ops[@nextIndex()].get('target').getColor()