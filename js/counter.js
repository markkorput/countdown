// Generated by CoffeeScript 1.6.3
(function() {
  var _ref,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  this.Counter = (function(_super) {
    __extends(Counter, _super);

    function Counter() {
      _ref = Counter.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    Counter.prototype.initialize = function() {
      var _this = this;
      this.amount = 10;
      return this.counts = _.map(_.range(this.amount), function(number, idx, list) {
        return new Count({
          scene: _this.get('scene'),
          camera: _this.get('camera'),
          text: number
        });
      });
    };

    Counter.prototype.update = function(progress) {
      var count, idx, sublength;
      idx = parseInt(progress * this.amount);
      _.each(this.counts, function(count, i) {
        if (i !== idx) {
          return count.hide();
        }
      });
      count = this.counts[idx];
      sublength = 1.0 / this.amount;
      return count.show((progress - sublength * idx) / sublength);
    };

    return Counter;

  })(Backbone.Model);

}).call(this);
