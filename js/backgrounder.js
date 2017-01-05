// Generated by CoffeeScript 1.6.3
(function() {
  var BackgroundShaders, _ref,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  this.Backgrounder = (function(_super) {
    __extends(Backgrounder, _super);

    function Backgrounder() {
      _ref = Backgrounder.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    Backgrounder.prototype.initialize = function() {
      this.destroy();
      this.scene = this.get('scene');
      this.camera = this.get('camera');
      this.on('change:shown', function(model, value, obj) {
        return model.trigger({
          "true": 'show',
          "false": 'hide'
        }[value], model);
      });
      this.on('show', function(model) {
        var mesh;
        if (!(mesh = model.get('mesh'))) {
          mesh = model.allMeshes()[0];
          return model.set({
            mesh: mesh
          });
        }
      });
      this.on('change:mesh', function(model, value, obj) {
        if (model.scene) {
          if (model.previous('mesh')) {
            model.scene.remove(model.previous('mesh'));
          }
          return model.scene.add(value);
        }
      });
      this.on('hide', function(model) {
        var m;
        if (model.scene && (m = model.get('mesh'))) {
          return model.scene.remove(m);
        }
      });
      if (this.get('shown') === void 0) {
        return this.show();
      }
    };

    Backgrounder.prototype.destroy = function() {
      this.trigger('destroy');
      this.trigger('hide');
      this.scene = this.camera = void 0;
      return Backgrounder.__super__.destroy.call(this);
    };

    Backgrounder.prototype._generateGeometry = function() {
      var geometry;
      geometry = new THREE.PlaneGeometry(300, 120);
      THREE.GeometryUtils.center(geometry);
      return geometry;
    };

    Backgrounder.prototype._generateMaterials = function() {
      var obj;
      obj = new BackgroundShaders();
      return _.map(obj.fragmentShaders, function(fragmentShader) {
        var shader;
        shader = {
          uniforms: obj.uniforms,
          vertexShader: obj.vertexShader,
          fragmentShader: fragmentShader
        };
        return new THREE.ShaderMaterial(shader);
      });
    };

    Backgrounder.prototype._generateMeshes = function() {
      var _this = this;
      return _.map(this._generateMaterials(), function(material) {
        var mesh;
        mesh = new THREE.Mesh(_this.geometry || _this._generateGeometry(), material);
        mesh.position.x = 0;
        mesh.position.y = 0;
        mesh.position.z = _this.camera.position.z - 150;
        return mesh;
      });
    };

    Backgrounder.prototype.allMeshes = function() {
      return this._all_meshes || (this._all_meshes = this._generateMeshes());
    };

    Backgrounder.prototype.randomize = function() {
      return this.set({
        mesh: _.sample(this.allMeshes())
      });
    };

    Backgrounder.prototype.hide = function() {
      return this.set({
        shown: false
      });
    };

    Backgrounder.prototype.show = function() {
      return this.set({
        shown: true
      });
    };

    Backgrounder.prototype.update = function(opts) {
      var mesh;
      this.show();
      if (opts.time && (mesh = this.get('mesh'))) {
        return mesh.material.uniforms.time.value = opts.time * 100;
      }
    };

    return Backgrounder;

  })(Backbone.Model);

  BackgroundShaders = function() {
    this.uniforms = {
      'time': {
        type: 'f',
        value: 0.0
      }
    };
    this.vertexShader = THREE.DefaultVertexShader;
    this.fragmentShaders = [];
    this.fragmentShaders.push("#ifdef GL_ES\nprecision mediump float;\n#endif\n\nuniform float time;\n\nvoid main( void ) {\n  gl_FragColor = vec4(1.0 - sin((gl_FragCoord.y + gl_FragCoord.x)/2.0+(time*10.0)));\n}");
    this.fragmentShaders.push("#ifdef GL_ES\nprecision mediump float;\n#endif\n\nuniform float time;\n\nvoid main( void ) {\n  gl_FragColor = vec4(sin(gl_FragCoord.x/2.0+(time*10.0))) + vec4(sin(gl_FragCoord.y/2.0+(time*10.0)));\n}");
    this.fragmentShaders.push("#ifdef GL_ES\nprecision mediump float;\n#endif\n\nuniform float time;\n\nvoid main( void ) {\n  gl_FragColor = vec4(sin(length(gl_FragCoord.xy / 200.0) * 96.0 + time * 10.0));\n}");
    return this.fragmentShaders.push("#ifdef GL_ES\nprecision mediump float;\n#endif\n\nuniform float time;\n\nvec2 pixelate(vec2 pos, vec2 size) {\n  size = 1000.0/size;\n  return floor(pos * size) / size;\n}\n\nfloat plasma1(vec2 pos) {\n  return sin((10.0*pos.x) + time);\n}\n\nfloat plasma2(vec2 pos) {\n  return sin(10.0*(pos.x*sin(time/2.0) + pos.y*cos(time/3.0)) + time);\n}\n\nfloat plasma3(vec2 pos) {\n  float centerX = pos.x + 0.5*sin(time/5.0);\n  float centerY = pos.y + 0.5*cos(time/3.0);\n  return sin(sqrt(100.0*(centerX*centerX + centerY*centerY) + 1.0) + time);\n}\n\nvoid main( void ) {\n  float wrinkle = cos(gl_FragCoord.y * 0.1 + time * 0.01);\n  float clr = sin(gl_FragCoord.x * 0.7 + wrinkle * 100.0 * sin(time * 0.01));\n  gl_FragColor = vec4(clr);\n}");
  };

}).call(this);
