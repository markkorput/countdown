// Generated by CoffeeScript 1.6.3
(function() {
  var _ref,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  this.App = (function(_super) {
    __extends(App, _super);

    function App() {
      _ref = App.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    App.prototype.initialize = function() {
      return this.init();
    };

    App.prototype.init = function() {
      this.controls = new Controls();
      this.controls.on('toggle-loop', (function(value) {
        return this.timer.set({
          loop: value
        }).start();
      }), this);
      this.controls.on('timeline', (function(value) {
        return this.timer.setProgress(value);
      }), this);
      this.controls.on('toggle-playing', (function(playing) {
        return this.set({
          paused: !playing
        });
      }), this);
      this.on('change:paused', (function(app, paused, obj) {
        return this.timer.setPaused(paused);
      }), this);
      this.timer = new Timer({
        duration: 10000
      });
      this.timer.start();
      this.timer.on('change:progress', (function(timer, progress, obj) {
        return this.controls.data.timeline = progress * 100;
      }), this);
      this.on('update', this.timer.update, this.timer);
      this._initVfx();
      this._createScene();
      return this.update();
    };

    App.prototype._initVfx = function() {
      this.camera = new THREE.PerspectiveCamera(45, window.innerWidth / window.innerHeight, 1, 1000);
      this.renderer = new THREE.WebGLRenderer();
      this._resize();
      $(window).resize(this._resize);
      return document.body.appendChild(this.renderer.domElement);
    };

    App.prototype._resize = function(event) {
      if (this.camera) {
        this.camera.aspect = window.innerWidth / window.innerHeight;
        this.camera.updateProjectionMatrix();
      }
      if (this.renderer) {
        return this.renderer.setSize(window.innerWidth, window.innerHeight);
      }
    };

    App.prototype._createScene = function() {
      var _this = this;
      this.scene = new THREE.Scene();
      this.camera_operator = new CameraOperator({
        camera: this.camera,
        scene: this.scene,
        speed: 0,
        rotation_speed: 0.0
      });
      this.counts = _.map(_.range(10), function(number, idx, list) {
        return new Count({
          scene: _this.scene,
          camera: _this.camera,
          text: number
        });
      });
      this.timer.on('change:progress', function(timer, progress, obj) {
        var count, idx;
        _.each(_this.counts, function(count) {
          return count.hide();
        });
        idx = parseInt(progress * 10);
        count = _this.counts[idx];
        return count.update((progress - 0.1 * idx) / 0.1);
      });
      return this.scene;
    };

    App.prototype.update = function() {
      var _this = this;
      requestAnimationFrame(function() {
        _this.update();
        return _this.draw();
      });
      if (this.get('paused') === true) {
        return;
      }
      return this.trigger('update');
    };

    App.prototype.draw = function() {
      if (this.post_processor) {
        this.post_processor.composer.render();
        return;
      }
      return this.renderer.render(this.scene, this.camera);
    };

    return App;

  })(Backbone.Model);

}).call(this);
