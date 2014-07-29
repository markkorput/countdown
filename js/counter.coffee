class CountCollection extends Backbone.Collection
  model: Count

class @Counter extends Backbone.Model
  initialize: ->
    @amount = 10

    count_ops_array = _.map _.range(@amount), (number, idx, list) =>
      # create count animation
      count = new Count(scene: @get('scene'), camera: @get('camera'), text: number)
      count_op = new CountOps(target: count)

    @count_ops = new CountCollection(count_ops_array)

    # @grids = _.map @count_ops, (op, idx, list) =>
    #   grid = new CountGrid(scene: @get('scene'), camera: @get('camera'), count: op.target)

    @on 'change:progress', (model, value, obj) ->
      model.set(idx: @calcIndex())

      # update current number
      model.currentOp().spinscale((value - model.countLength() * model.get('idx')) / model.countLength())

    @on 'change:idx', (model, value, obj) ->
      # hide all other count numbers
      model.count_ops.each (op, i) ->
        op.hide() if i != value

  update: (progress) ->
    @set(progress: progress)

  countLength: ->
    1.0 / @amount

  currentOp: ->
    @count_ops.at(@get('idx')) || @count_ops.at(@get('idx')-1)

  calcIndex: ->
    idx = parseInt(@get('progress')*@amount)

  nextIndex: ->
    idx = @get('idx') || @calcIndex() + 1
    idx = 0 if idx >= @amount
    return idx

  nextColor: ->
    @count_ops.at(@nextIndex()).get('target').getColor()