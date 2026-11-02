class SareeRenderer {
  constructor(canvas) {
    this.canvas = canvas;
    this.gl = canvas.getContext('webgl', {
      premultipliedAlpha: false,
      alpha: true,
      preserveDrawingBuffer: true
    });

    if (!this.gl) {
      throw new Error('WebGL not supported in this browser.');
    }

    this.initGL();
  }

  initGL() {
    const gl = this.gl;

    const vsSource = `
      attribute vec2 a_position; // Model pixel space [0..W, 0..H]
      attribute vec2 a_texCoord; // Saree texture normalized [0..1]
      attribute float a_lighting; // 3D fold normal lighting factor
      
      uniform vec2 u_resolution; // Model canvas size
      
      varying vec2 v_texCoord;
      varying float v_lighting;

      void main() {
        vec2 zeroToOne = a_position / u_resolution;
        vec2 zeroToTwo = zeroToOne * 2.0;
        vec2 clipSpace = zeroToTwo - 1.0;
        
        gl_Position = vec4(clipSpace.x, -clipSpace.y, 0.0, 1.0);
        v_texCoord = a_texCoord;
        v_lighting = a_lighting;
      }
    `;

    const fsSource = `
      precision mediump float;
      
      uniform sampler2D u_sareeTexture;
      uniform float u_opacity;
      uniform float u_brightness;
      uniform float u_contrast;
      
      varying vec2 v_texCoord;
      varying float v_lighting;

      void main() {
        // Clamp UV coordinates [0..1]
        vec2 uv = clamp(v_texCoord, 0.0, 1.0);
        vec4 texColor = texture2D(u_sareeTexture, uv);
        
        vec3 color = texColor.rgb * v_lighting;
        color = (color - 0.5) * u_contrast + 0.5 + (u_brightness - 1.0);
        
        gl_FragColor = vec4(color, texColor.a * u_opacity);
      }
    `;

    this.program = this.createProgram(gl, vsSource, fsSource);
    this.positionLocation = gl.getAttribLocation(this.program, 'a_position');
    this.texCoordLocation = gl.getAttribLocation(this.program, 'a_texCoord');
    this.lightingLocation = gl.getAttribLocation(this.program, 'a_lighting');

    this.resolutionLocation = gl.getUniformLocation(this.program, 'u_resolution');
    this.sareeTexLocation = gl.getUniformLocation(this.program, 'u_sareeTexture');
    this.opacityLocation = gl.getUniformLocation(this.program, 'u_opacity');
    this.brightnessLocation = gl.getUniformLocation(this.program, 'u_brightness');
    this.contrastLocation = gl.getUniformLocation(this.program, 'u_contrast');

    this.positionBuffer = gl.createBuffer();
    this.texCoordBuffer = gl.createBuffer();
    this.lightingBuffer = gl.createBuffer();
  }

  createShader(gl, type, source) {
    const shader = gl.createShader(type);
    gl.shaderSource(shader, source);
    gl.compileShader(shader);
    if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
      const err = gl.getShaderInfoLog(shader);
      gl.deleteShader(shader);
      throw new Error('Shader compile error: ' + err);
    }
    return shader;
  }

  createProgram(gl, vsSource, fsSource) {
    const vs = this.createShader(gl, gl.VERTEX_SHADER, vsSource);
    const fs = this.createShader(gl, gl.FRAGMENT_SHADER, fsSource);
    const prog = gl.createProgram();
    gl.attachShader(prog, vs);
    gl.attachShader(prog, fs);
    gl.linkProgram(prog);
    if (!gl.getProgramParameter(prog, gl.LINK_STATUS)) {
      const err = gl.getProgramInfoLog(prog);
      gl.deleteProgram(prog);
      throw new Error('Program link error: ' + err);
    }
    return prog;
  }

  createTexture(image) {
    const gl = this.gl;
    const tex = gl.createTexture();
    gl.bindTexture(gl.TEXTURE_2D, tex);
    gl.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, false);

    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);

    gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, image);
    return tex;
  }

  generateMeshTriangles(srcPts, dstPts, rows, cols, modelW, modelH, overshoot = 0.015, vertexLighting = null) {
    const positions = [];
    const texCoords = [];
    const lightings = [];
    let degenerateCount = 0;
    let validTriCount = 0;

    // Optional slight overshoot expansion to prevent boundary undershoot gaps
    let activeDst = dstPts;
    if (overshoot > 0 && dstPts && dstPts.length > 0) {
      // Find bounding center
      let cX = 0, cY = 0;
      for (let i = 0; i < dstPts.length; i++) {
        cX += dstPts[i][0];
        cY += dstPts[i][1];
      }
      cX /= dstPts.length;
      cY /= dstPts.length;

      activeDst = dstPts.map(pt => {
        const dx = pt[0] - cX;
        const dy = pt[1] - cY;
        return [pt[0] + dx * overshoot, pt[1] + dy * overshoot];
      });
    }

    for (let r = 0; r < rows - 1; r++) {
      for (let c = 0; c < cols - 1; c++) {
        const i0 = r * cols + c;
        const i1 = r * cols + (c + 1);
        const i2 = (r + 1) * cols + c;
        const i3 = (r + 1) * cols + (c + 1);

        const tri1 = [i0, i1, i2];
        const tri2 = [i1, i3, i2];

        [tri1, tri2].forEach(tri => {
          // Calculate destination triangle 2D cross-product area
          const pA = activeDst[tri[0]];
          const pB = activeDst[tri[1]];
          const pC = activeDst[tri[2]];

          // 2x signed area
          const crossArea = (pB[0] - pA[0]) * (pC[1] - pA[1]) - (pB[1] - pA[1]) * (pC[0] - pA[0]);

          // Reject degenerate or zero-area collapsed triangles
          if (Math.abs(crossArea) < 1e-7) {
            degenerateCount++;
            return;
          }

          validTriCount++;
          tri.forEach(idx => {
            positions.push(activeDst[idx][0] * modelW, activeDst[idx][1] * modelH);
            texCoords.push(srcPts[idx][0], srcPts[idx][1]);
            const light = (vertexLighting && vertexLighting[idx] !== undefined) ? vertexLighting[idx] : 1.0;
            lightings.push(light);
          });
        });
      }
    }

    return {
      positions: new Float32Array(positions),
      texCoords: new Float32Array(texCoords),
      lightings: new Float32Array(lightings),
      vertexCount: positions.length / 2,
      degenerateCount,
      validTriCount
    };
  }

  renderMesh(sareeTex, meshData, modelW, modelH, options = {}) {
    const gl = this.gl;

    gl.viewport(0, 0, modelW, modelH);
    gl.useProgram(this.program);

    gl.uniform2f(this.resolutionLocation, modelW, modelH);
    gl.uniform1f(this.opacityLocation, options.opacity !== undefined ? options.opacity : 1.0);
    gl.uniform1f(this.brightnessLocation, options.brightness !== undefined ? options.brightness : 1.0);
    gl.uniform1f(this.contrastLocation, options.contrast !== undefined ? options.contrast : 1.0);

    gl.activeTexture(gl.TEXTURE0);
    gl.bindTexture(gl.TEXTURE_2D, sareeTex);
    gl.uniform1i(this.sareeTexLocation, 0);

    gl.bindBuffer(gl.ARRAY_BUFFER, this.positionBuffer);
    gl.bufferData(gl.ARRAY_BUFFER, meshData.positions, gl.STATIC_DRAW);
    gl.enableVertexAttribArray(this.positionLocation);
    gl.vertexAttribPointer(this.positionLocation, 2, gl.FLOAT, false, 0, 0);

    gl.bindBuffer(gl.ARRAY_BUFFER, this.texCoordBuffer);
    gl.bufferData(gl.ARRAY_BUFFER, meshData.texCoords, gl.STATIC_DRAW);
    gl.enableVertexAttribArray(this.texCoordLocation);
    gl.vertexAttribPointer(this.texCoordLocation, 2, gl.FLOAT, false, 0, 0);

    gl.bindBuffer(gl.ARRAY_BUFFER, this.lightingBuffer);
    gl.bufferData(gl.ARRAY_BUFFER, meshData.lightings || new Float32Array(meshData.vertexCount).fill(1.0), gl.STATIC_DRAW);
    gl.enableVertexAttribArray(this.lightingLocation);
    gl.vertexAttribPointer(this.lightingLocation, 1, gl.FLOAT, false, 0, 0);

    gl.drawArrays(gl.TRIANGLES, 0, meshData.vertexCount);
  }

  clear() {
    const gl = this.gl;
    gl.clearColor(0, 0, 0, 0);
    gl.clear(gl.COLOR_BUFFER_BIT);
  }
}

window.SareeRenderer = SareeRenderer;
