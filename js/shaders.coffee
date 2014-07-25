###
  @author alteredq / http://alteredqualia.com/
  
  Full-screen textured quad shader
###

THREE.CopyShader =
  uniforms:
    "tDiffuse": { type: "t", value: null } # in Three.js tDiffuse is always passed from the previous Shader in the effect chain
    "opacity":  { type: "f", value: 1.0 }

  vertexShader: [

    "varying vec2 vUv;",

    "void main() {",

      "vUv = uv;",
      "gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );",

    "}"
  ].join("\n"),

  fragmentShader: """

    uniform float opacity;
    uniform sampler2D tDiffuse; # in Three.js tDiffuse is always passed from the previous Shader in the effect chain
    varying vec2 vUv;

    void main() {

      vec4 texel = texture2D( tDiffuse, vUv );
      gl_FragColor = opacity * texel;

    }
  """



###
  @author alteredq / http://alteredqualia.com/
  
  Dot screen shader
  based on glfx.js sepia shader
  https://github.com/evanw/glfx.js
###

THREE.DotScreenShader = {

  uniforms: {

    "tDiffuse": { type: "t", value: null },
    "tSize":    { type: "v2", value: new THREE.Vector2( 10, 10 ) },
    "center":   { type: "v2", value: new THREE.Vector2( 0.5, 0.5 ) },
    "angle":    { type: "f", value: 1.57 },
    "scale":    { type: "f", value: 1.0 }

  },

  vertexShader: [

    "varying vec2 vUv;",

    "void main() {",

      "vUv = uv;",
      "gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );",

    "}"

  ].join("\n"),

  fragmentShader: [

    "uniform vec2 center;",
    "uniform float angle;",
    "uniform float scale;",
    "uniform vec2 tSize;",
    "uniform sampler2D tDiffuse;", # in Three.js tDiffuse is always passed from the previous Shader in the effect chain
    "varying vec2 vUv;", # in Three.js vUv always contains the coordinates of the pixel webeing processed

    "float pattern() {",

      "float s = sin( angle ), c = cos( angle );",

      "vec2 tex = vUv * tSize - center;",
      "vec2 point = vec2( c * tex.x - s * tex.y, s * tex.x + c * tex.y ) * scale;",

      "return ( sin( point.x ) * sin( point.y ) ) * 4.0;",

    "}",

    "void main() {",

      "vec4 color = texture2D( tDiffuse, vUv );",

      "float average = ( color.r + color.g + color.b ) / 3.0;",

      "gl_FragColor = vec4( vec3( average * 10.0 - 5.0 + pattern() ), color.a );",

    "}"

  ].join("\n")

};



###
  @author felixturner / http://airtight.cc/
  
  RGB Shift Shader
  Shifts red and blue channels from center in opposite directions
  Ported from http://kriss.cx/tom/2009/05/rgb-shift/
  by Tom Butterworth / http://kriss.cx/tom/
  
  amount: shift distance (1 is width of input)
  angle: shift angle in radians
###

THREE.RGBShiftShader = {

  uniforms: {

    "tDiffuse": { type: "t", value: null },
    "amount":   { type: "f", value: 0.005 },
    "angle":    { type: "f", value: 0.0 },
    "amplitude": { type: "f", value: 0.0 }

  },

  vertexShader: [

    "varying vec2 vUv;",
    "uniform float amplitude;",

    "void main() {",
      "vUv = uv;",
      "vec3 newPosition = position + vec3(amplitude, 0.0, 0.0);",
      "gl_Position = projectionMatrix * modelViewMatrix * vec4( newPosition, 1.0 );",

    "}"

  ].join("\n"),

  fragmentShader: """
    uniform sampler2D tDiffuse;
    uniform float amount;
    uniform float angle;

    varying vec2 vUv;

    void main() {
      vec2 offset = amount * vec2( cos(angle), sin(angle));
      vec4 cr = texture2D(tDiffuse, vUv + offset);
      vec4 cga = texture2D(tDiffuse, vUv);
      vec4 cb = texture2D(tDiffuse, vUv - offset);
      gl_FragColor = vec4(cr.r, cga.g, cb.b, cga.a);
    }
  """
};