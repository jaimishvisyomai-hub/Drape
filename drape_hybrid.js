/**
 * Hybrid Saree Drape Engine
 * Multi-Region Non-AI Draping Architecture
 * 
 * Implements 6 Independent Draping Regions:
 * 1. Chest and Shoulder Wrap: Thin Plate Spline (TPS) anatomical bust & torso deformation.
 * 2. Waist and Hip Wrap: Body-constrained silhouette mesh preventing wide bell-shaped distortion.
 * 3. Front Pleats: Fold-aware geometry with compact waist tuck, cascading expansion, and 3D accordion normal shading.
 * 4. Pallu Drape: Pinned cloth simulation (Verlet solver with torso collision & catenary drape) eliminating the oversized triangular fan.
 * 5. Attached Borders: Spline-based attached geometry maintaining constant physical width along drape contours.
 * 6. Occlusion & Layer Compositor: Anatomical multi-pass depth ordering and model arm/hand occlusion retention.
 */

(function (root, factory) {
  if (typeof define === 'function' && define.amd) {
    define([], factory);
  } else if (typeof module === 'object' && module.exports) {
    module.exports = factory();
  } else {
    root.HybridDrape = factory();
  }
}(typeof self !== 'undefined' ? self : this, function () {

  // =========================================================================
  // UTILITY & MATRIX MATH
  // =========================================================================

  const clamp = (v, min = 0, max = 1) => Math.max(min, Math.min(max, v));
  const lerp = (a, b, t) => a + (b - a) * t;

  /**
   * Gaussian elimination with partial pivoting for solving Ax = b
   */
  function solveLinearSystem(A, b) {
    const n = A.length;
    const M = A.map((row, i) => [...row, b[i]]);

    for (let i = 0; i < n; i++) {
      let maxRow = i;
      for (let k = i + 1; k < n; k++) {
        if (Math.abs(M[k][i]) > Math.abs(M[maxRow][i])) maxRow = k;
      }

      const temp = M[i];
      M[i] = M[maxRow];
      M[maxRow] = temp;

      if (Math.abs(M[i][i]) < 1e-12) continue;

      for (let k = i + 1; k < n; k++) {
        const c = -M[k][i] / M[i][i];
        for (let j = i; j <= n; j++) {
          if (i === j) M[k][j] = 0;
          else M[k][j] += c * M[i][j];
        }
      }
    }

    const x = new Array(n).fill(0);
    for (let i = n - 1; i >= 0; i--) {
      let sum = M[i][n];
      for (let j = i + 1; j < n; j++) sum -= M[i][j] * x[j];
      x[i] = Math.abs(M[i][i]) > 1e-12 ? sum / M[i][i] : 0;
    }
    return x;
  }

  /**
   * Radial basis kernel for 2D Thin Plate Spline: U(r) = r^2 * ln(r)
   */
  function tpsKernel(r) {
    if (r <= 1e-9) return 0;
    return r * r * Math.log(r);
  }

  // =========================================================================
  // CORE MATHEMATICAL TPS DEFORMER
  // =========================================================================

  class TPSDeformer {
    constructor(srcControlPts, dstControlPts, regularization = 0.001) {
      this.srcPts = srcControlPts;
      this.n = srcControlPts.length;
      const n = this.n;

      const L = Array.from({ length: n + 3 }, () => new Array(n + 3).fill(0));
      for (let i = 0; i < n; i++) {
        for (let j = 0; j < n; j++) {
          const dist = Math.hypot(srcControlPts[i][0] - srcControlPts[j][0], srcControlPts[i][1] - srcControlPts[j][1]);
          L[i][j] = tpsKernel(dist) + (i === j ? regularization : 0);
        }
        L[i][n] = 1;
        L[i][n + 1] = srcControlPts[i][0];
        L[i][n + 2] = srcControlPts[i][1];

        L[n][i] = 1;
        L[n + 1][i] = srcControlPts[i][0];
        L[n + 2][i] = srcControlPts[i][1];
      }

      const bx = [...dstControlPts.map(p => p[0]), 0, 0, 0];
      const by = [...dstControlPts.map(p => p[1]), 0, 0, 0];

      this.wx = solveLinearSystem(L, bx);
      this.wy = solveLinearSystem(L, by);
    }

    evaluate(x, y) {
      let rx = this.wx[this.n] + this.wx[this.n + 1] * x + this.wx[this.n + 2] * y;
      let ry = this.wy[this.n] + this.wy[this.n + 1] * x + this.wy[this.n + 2] * y;

      for (let i = 0; i < this.n; i++) {
        const dist = Math.hypot(x - this.srcPts[i][0], y - this.srcPts[i][1]);
        const u = tpsKernel(dist);
        rx += this.wx[i] * u;
        ry += this.wy[i] * u;
      }
      return [rx, ry];
    }

    transformPoints(points, blendWeight = 1.0) {
      if (blendWeight <= 0) return points;
      return points.map(([x, y]) => {
        const [tx, ty] = this.evaluate(x, y);
        return [
          clamp(x + (tx - x) * blendWeight, 0, 1),
          clamp(y + (ty - y) * blendWeight, 0, 1)
        ];
      });
    }

    static createChestAnatomicalDeformer(strength = 0.85) {
      const srcLandmarks = [
        [0.42, 0.20], // Left shoulder tuck
        [0.32, 0.19], // Neckline apex
        [0.26, 0.21], // Right clavicle
        [0.35, 0.28], // Sternum / cleavage
        [0.26, 0.27], // Right bust apex
        [0.29, 0.32], // Breast lower fullness
        [0.21, 0.33], // Right ribcage
        [0.27, 0.35], // Underbust fold
        [0.15, 0.39], // Lateral waist pinch
        [0.21, 0.39]  // Center waist tuck
      ];

      const dstLandmarks = [
        [0.422, 0.198], // Shoulder tuck
        [0.320, 0.193], // Neckline contour
        [0.252, 0.214], // Clavicle curve
        [0.345, 0.286], // Inward cleavage dip
        [0.255 + 0.028 * strength, 0.278 + 0.012 * strength], // Curvature outward over bust apex
        [0.295 + 0.016 * strength, 0.324 + 0.008 * strength], // Breast lower fullness curve
        [0.204, 0.336], // Lateral ribcage
        [0.265, 0.358], // Underbust contour
        [0.144, 0.392], // Waist pinch
        [0.208, 0.394]  // Center waist
      ];

      return new TPSDeformer(srcLandmarks, dstLandmarks, 0.002);
    }
  }

  // =========================================================================
  // CORE VERLET CLOTH PHYSICS ENGINE (aatishb/drape inspired)
  // =========================================================================

  class ClothParticle {
    constructor(x, y, z, pinned = false) {
      this.pos = [x, y, z];
      this.prev = [x, y, z];
      this.pinned = pinned;
      this.orig = [x, y, z];
    }
  }

  class ClothConstraint {
    constructor(p1, p2, stiffness = 1.0) {
      this.p1 = p1;
      this.p2 = p2;
      this.stiffness = stiffness;
      this.restDistance = Math.hypot(
        p2.pos[0] - p1.pos[0],
        p2.pos[1] - p1.pos[1],
        p2.pos[2] - p1.pos[2]
      );
    }

    satisfy() {
      const p1 = this.p1;
      const p2 = this.p2;

      const dx = p2.pos[0] - p1.pos[0];
      const dy = p2.pos[1] - p1.pos[1];
      const dz = p2.pos[2] - p1.pos[2];

      const currentDist = Math.hypot(dx, dy, dz) || 1e-6;
      const diff = (currentDist - this.restDistance) / currentDist * this.stiffness;

      const ox = dx * 0.5 * diff;
      const oy = dy * 0.5 * diff;
      const oz = dz * 0.5 * diff;

      if (!p1.pinned) {
        p1.pos[0] += ox;
        p1.pos[1] += oy;
        p1.pos[2] += oz;
      }
      if (!p2.pinned) {
        p2.pos[0] -= ox;
        p2.pos[1] -= oy;
        p2.pos[2] -= oz;
      }
    }
  }

  class ClothSimulator {
    constructor(dstPts, rows, cols, options = {}) {
      this.rows = rows;
      this.cols = cols;
      this.damping = options.damping !== undefined ? options.damping : 0.96;
      this.gravity = options.gravity !== undefined ? options.gravity : 0.00015;
      this.pinnedRows = options.pinnedRows || [0];
      this.particles = [];
      this.constraints = [];

      this.collisionEllipsoid = options.collisionEllipsoid || {
        cx: 0.38,
        cy: 0.35,
        cz: -0.05,
        rx: 0.16,
        ry: 0.28,
        rz: 0.12
      };

      for (let r = 0; r < rows; r++) {
        for (let c = 0; c < cols; c++) {
          const idx = r * cols + c;
          const pt = dstPts[idx];
          const isPinned = this.pinnedRows.includes(r);
          const zDepth = (r === 0) ? 0.05 : 0.02 * Math.sin((c / (cols - 1)) * Math.PI);
          this.particles.push(new ClothParticle(pt[0], pt[1], zDepth, isPinned));
        }
      }

      this.initConstraints();
    }

    initConstraints() {
      const rows = this.rows;
      const cols = this.cols;

      for (let r = 0; r < rows; r++) {
        for (let c = 0; c < cols; c++) {
          const i0 = r * cols + c;

          if (c < cols - 1) {
            const i1 = r * cols + (c + 1);
            this.constraints.push(new ClothConstraint(this.particles[i0], this.particles[i1], 0.95));
          }

          if (r < rows - 1) {
            const i2 = (r + 1) * cols + c;
            this.constraints.push(new ClothConstraint(this.particles[i0], this.particles[i2], 0.98));
          }

          if (r < rows - 1 && c < cols - 1) {
            const i3 = (r + 1) * cols + (c + 1);
            const i1 = r * cols + (c + 1);
            const i2 = (r + 1) * cols + c;
            this.constraints.push(new ClothConstraint(this.particles[i0], this.particles[i3], 0.65));
            this.constraints.push(new ClothConstraint(this.particles[i1], this.particles[i2], 0.65));
          }

          if (r < rows - 2) {
            const iBend = (r + 2) * cols + c;
            this.constraints.push(new ClothConstraint(this.particles[i0], this.particles[iBend], 0.35));
          }
        }
      }
    }

    step() {
      const ellip = this.collisionEllipsoid;

      for (let i = 0; i < this.particles.length; i++) {
        const p = this.particles[i];
        if (p.pinned) continue;

        const vx = (p.pos[0] - p.prev[0]) * this.damping;
        const vy = (p.pos[1] - p.prev[1]) * this.damping + this.gravity;
        const vz = (p.pos[2] - p.prev[2]) * this.damping;

        p.prev[0] = p.pos[0];
        p.prev[1] = p.pos[1];
        p.prev[2] = p.pos[2];

        p.pos[0] += vx;
        p.pos[1] += vy;
        p.pos[2] += vz;

        const dx = (p.pos[0] - ellip.cx) / ellip.rx;
        const dy = (p.pos[1] - ellip.cy) / ellip.ry;
        const dz = (p.pos[2] - ellip.cz) / ellip.rz;
        const distSq = dx * dx + dy * dy + dz * dz;

        if (distSq < 1.0 && distSq > 1e-6) {
          const factor = 1.0 / Math.sqrt(distSq);
          p.pos[0] = ellip.cx + dx * factor * ellip.rx;
          p.pos[1] = ellip.cy + dy * factor * ellip.ry;
          p.pos[2] = ellip.cz + dz * factor * ellip.rz;
        }
      }

      for (let iter = 0; iter < 12; iter++) {
        for (let j = 0; j < this.constraints.length; j++) {
          this.constraints[j].satisfy();
        }
      }
    }

    relax(iterations = 25) {
      for (let i = 0; i < iterations; i++) {
        this.step();
      }
    }

    getDestinationPoints(blendWeight = 1.0) {
      return this.particles.map(p => {
        const rx = p.orig[0] + (p.pos[0] - p.orig[0]) * blendWeight;
        const ry = p.orig[1] + (p.pos[1] - p.orig[1]) * blendWeight;
        return [clamp(rx, 0, 1), clamp(ry, 0, 1)];
      });
    }

    static relaxPalluDrape(p1Data, p2Data, sagStrength = 0.5) {
      const mapping = {
        'mask_PALLU_01.png': p1Data,
        'mask_PALLU_02.png': p2Data
      };
      PalluDrapeRegion.process(mapping, {
        enablePhysics: true,
        sagStrength,
        constrainWidth: true
      });
    }
  }

  // =========================================================================
  // REGION 1: CHEST AND SHOULDER WRAP (TPS / Anatomical Mesh Deformation)
  // =========================================================================

  class ChestShoulderRegion {
    /**
     * Applies non-rigid Thin Plate Spline anatomical bust contour deformation
     * Maps fabric diagonally from left shoulder across the chest, following breast apex,
     * neckline, sternum, and waist taper while preserving blouse boundaries.
     */
    static process(mapping, options = {}) {
      const strength = options.strength !== undefined ? options.strength : 0.85;
      if (strength <= 0) return;

      const deformer = TPSDeformer.createChestAnatomicalDeformer(strength);
      const chestLayers = ['mask_CHAST_01.png', 'mask_CHAST_02.png', 'mask_CHAST_03.png'];

      chestLayers.forEach(layerKey => {
        const layer = mapping[layerKey];
        if (layer && layer.dst_pts) {
          layer.dst_pts = deformer.transformPoints(layer.dst_pts, strength);
        }
      });
    }
  }

  // =========================================================================
  // REGION 2: WAIST AND HIP WRAP (Body-Constrained Mesh)
  // =========================================================================

  class WaistHipRegion {
    /**
     * Constrains the waist and hip silhouette to follow the model's natural body proportions.
     * Prevents the wide, stiff bell-shaped trapezoid by:
     * 1. Narrowing the waist tuck (Y=0.45..0.55) tightly against the torso.
     * 2. Smoothly interpolating pelvic and hip curvature (Y=0.55..0.75).
     * 3. Permitting controlled subtle flare only toward the lower ankles (Y > 0.85).
     */
    static process(mapping, options = {}) {
      const p7 = mapping['mask_PATLI_07.png']; // Foundation skirt underlay
      const p8 = mapping['mask_patli_08.png']; // Right waist tuck
      const flareControl = options.flareControl !== undefined ? options.flareControl : 0.65;

      if (p7 && p7.dst_pts) {
        const rows = p7.mesh_rows;
        const cols = p7.mesh_cols;
        const newDst = [];

        for (let r = 0; r < rows; r++) {
          const t = r / (rows - 1); // 0 at waist, 1 at hemline
          const vY = p7.dst_pts[r * cols][1];

          // Model body silhouette bounds:
          // Waist (t=0): narrow waist X in [0.09 .. 0.22]
          // Thigh/knee (t=0.5): X in [0.05 .. 0.23]
          // Hemline (t=1.0): controlled flare X in [0.025 .. 0.240]
          const naturalLeftX = lerp(0.095, 0.025, Math.pow(t, flareControl));
          const naturalRightX = lerp(0.215, 0.242, Math.pow(t, 0.90));

          for (let c = 0; c < cols; c++) {
            const u = c / (cols - 1);
            const origPt = p7.dst_pts[r * cols + c];
            const targetX = lerp(naturalLeftX, naturalRightX, u);
            const targetY = origPt[1]; // Preserve natural row heights

            // Blend with original to ensure smooth continuity
            newDst.push([
              clamp(lerp(origPt[0], targetX, 0.75), 0, 1),
              clamp(targetY, 0, 1)
            ]);
          }
        }
        p7.dst_pts = newDst;
      }

      // Constrain right waist tuck (mask_patli_08) to hug the right hip curve
      if (p8 && p8.dst_pts) {
        p8.dst_pts = p8.dst_pts.map(([x, y]) => {
          // Clamp right tuck neatly under the waistband
          const clampedX = clamp(x, 0.170, 0.238);
          return [clampedX, y];
        });
      }
    }
  }

  // =========================================================================
  // REGION 3: FRONT PLEATS (Fold-Aware Geometry & 3D Depth Normals)
  // =========================================================================

  class FrontPleatsRegion {
    /**
     * Fold-aware pleat geometry:
     * 1. Gathers all pleats into a compact shared waist tuck origin (Y ~ 0.50..0.54, width ~ 0.04).
     * 2. Cascades each vertical fold downward with progressive, parallel fanning toward hem (Y ~ 0.925).
     * 3. Calculates 3D depth normals with directional studio lighting (ridges highlight, creases shadow).
     * 4. Casts inter-pleat contact drop shadows between consecutive folds.
     * 5. Eliminates all white slits by guaranteeing continuous overlapping geometry across the entire skirt.
     */
    static process(mapping, options = {}) {
      const pleatKeys = [
        'mask_PATLI_01_NEW.png',
        'mask_PATLI_01.png',
        'mask_PATLI_02.png',
        'mask_PATLI_03.png',
        'mask_PATLI_04.png',
        'mask_PATLI_05.png',
        'mask_PATLI_06.png'
      ];

      const compactWaist = options.compactWaist !== undefined ? options.compactWaist : true;
      if (!compactWaist) return;

      // Precise continuous overlapping accordion fold bounds from left (fold 0) to right (fold 6):
      // Each fold completely covers its mask boundaries with safe 2-4px overshoot,
      // and adjacent folds overlap by 30-40% so zero white background can ever show through.
      const foldHemBounds = [
        { left: 0.016, right: 0.086 }, // Fold 0 (01_NEW): mask 0.018..0.082
        { left: 0.050, right: 0.115 }, // Fold 1 (01):     mask 0.053..0.108 (overlaps fold 0 by 36px)
        { left: 0.096, right: 0.138 }, // Fold 2 (02):     mask 0.103..0.122 (overlaps fold 1 by 19px)
        { left: 0.115, right: 0.170 }, // Fold 3 (03):     mask 0.118..0.165 (overlaps fold 2 by 23px)
        { left: 0.152, right: 0.198 }, // Fold 4 (04):     mask 0.165..0.192 (overlaps fold 3 by 18px)
        { left: 0.178, right: 0.228 }, // Fold 5 (05):     mask 0.193..0.228 (overlaps fold 4 by 20px)
        { left: 0.200, right: 0.245 }  // Fold 6 (06):     mask 0.225..0.242 (overlaps fold 5 by 28px)
      ];

      pleatKeys.forEach((key, i) => {
        const pleat = mapping[key];
        if (!pleat || !pleat.dst_pts) return;

        const rows = pleat.mesh_rows;
        const cols = pleat.mesh_cols;
        const bounds = foldHemBounds[i] || { left: 0.150, right: 0.200 };

        // Compact waist tuck anchor for this fold
        const waistFoldLeft = 0.150 + i * 0.007;
        const waistFoldRight = waistFoldLeft + 0.024;

        const newDst = [];
        for (let r = 0; r < rows; r++) {
          const t = r / (rows - 1); // 0 at waist, 1 at bottom hem
          const fanCurve = Math.pow(t, 0.85); // Smooth progressive downward flare

          // Interpolate fold edges from compact waist to continuous overlapping hem
          const curFoldLeft = lerp(waistFoldLeft, bounds.left, fanCurve);
          const curFoldRight = lerp(waistFoldRight, bounds.right, fanCurve);
          const origPtY = pleat.dst_pts[r * cols][1];

          for (let c = 0; c < cols; c++) {
            const u = cols > 1 ? c / (cols - 1) : 0;
            const interpolatedX = lerp(curFoldLeft, curFoldRight, u);
            newDst.push([
              clamp(interpolatedX, 0.012, 0.250),
              clamp(origPtY, 0.480, 0.940)
            ]);
          }
        }
        pleat.dst_pts = newDst;
      });
    }

    /**
     * Calculates 3D normal lighting for accordion pleat folds
     */
    static calculateFoldLighting(colIndex, totalCols, foldDepth = 1.0) {
      const u = totalCols > 1 ? colIndex / (totalCols - 1) : 0.5;
      const slope = Math.cos(u * Math.PI);
      const nx = slope * 0.55 * foldDepth;
      const ny = -0.10;
      const nz = 0.85;
      const len = Math.hypot(nx, ny, nz) || 1.0;

      const lx = 0.50;
      const ly = -0.50;
      const lz = 0.70;
      const lLen = Math.hypot(lx, ly, lz) || 1.0;

      const NdotL = (nx / len) * (lx / lLen) + (ny / len) * (ly / lLen) + (nz / len) * (lz / lLen);
      const ambient = 0.75;
      const diffuse = 0.45;
      const lightFactor = ambient + diffuse * Math.max(0, NdotL);

      return Math.max(0.70, Math.min(1.30, lightFactor));
    }

    /**
     * Renders inter-pleat directional contact drop shadow.
     * Draws mask offscreen to cast ONLY the drop shadow onto the composite canvas,
     * preventing solid white mask pixels from ever being drawn directly!
     */
    static renderPleatContactShadow(ctx, maskImg, w, h, shadowOffset = 4, shadowAlpha = 0.30) {
      if (!maskImg || shadowAlpha <= 0) return;
      ctx.save();
      ctx.shadowColor = `rgba(0, 0, 0, ${shadowAlpha})`;
      ctx.shadowBlur = 6;
      ctx.shadowOffsetX = 10000 + shadowOffset;
      ctx.shadowOffsetY = 2;
      ctx.drawImage(maskImg, -10000, 0, w, h);
      ctx.restore();
    }
  }

  // =========================================================================
  // REGION 4: PALLU DRAPE (Pinned Cloth Simulation & Natural Catenary Path)
  // =========================================================================

  class PalluDrapeRegion {
    /**
     * Drapes the pallu naturally hanging from the left shoulder over the back and side:
     * 1. Preserves the full anatomical silhouette of mask_PALLU_02.png (reaching to X = 0.948)
     *    with smooth catenary curvature and rounded corner matching SareeViz.
     * 2. Synchronizes the shared seam between PALLU_01 and PALLU_02 (d1_1 == d2_0) for seamless continuity.
     * 3. Uses Verlet cloth simulation with pinned shoulder and outer drape guides for realistic catenary sag.
     */
    static process(mapping, options = {}) {
      const p1 = mapping['mask_PALLU_01.png'];
      const p2 = mapping['mask_PALLU_02.png'];
      if (!p1 || !p1.dst_pts || !p2 || !p2.dst_pts) return;

      const sagStrength = options.sagStrength !== undefined ? options.sagStrength : 0.45;

      // 1. Precise Outer Boundary alignment to 100% cover mask_PALLU_02.png
      // Target silhouette points matching SareeViz reference and mask_PALLU_02:
      // Smooth catenary curve: gentle diagonal fall from shoulder to rounded corner apex (X=0.975 at Row 6)
      // and soft rounded bottom corner (X=0.945 at Row 7, X=0.875 at Row 8, X=0.785 at Row 9).
      const outerBoundaryX = [
        0.510, // Row 0 (shoulder tuck)
        0.585, // Row 1
        0.655, // Row 2
        0.730, // Row 3
        0.805, // Row 4
        0.885, // Row 5
        0.975, // Row 6 (covers mask_PALLU_02 apex at 0.972)
        0.945, // Row 7 (rounded apex corner)
        0.875, // Row 8 (rounded lower corner)
        0.785  // Row 9 (lower hem tuck)
      ];

      // Seam between PALLU_01 and PALLU_02 matching mask_PALLU_01 MaxX & mask_PALLU_02 MinX:
      const seamX = [
        0.455, // Row 0
        0.475, // Row 1
        0.496, // Row 2
        0.517, // Row 3
        0.538, // Row 4
        0.558, // Row 5
        0.580, // Row 6
        0.603, // Row 7
        0.655, // Row 8 (matches mask_PALLU_02 minX at 0.655)
        0.710  // Row 9 (lower hem tuck at 0.710)
      ];

      // Inner boundary of PALLU_01 hugging the torso/waist:
      const innerBoundaryX = [
        0.225, // Row 0
        0.228, // Row 1
        0.230, // Row 2
        0.232, // Row 3
        0.235, // Row 4
        0.238, // Row 5
        0.238, // Row 6
        0.238, // Row 7
        0.240, // Row 8
        0.240  // Row 9
      ];

      const rows = p2.mesh_rows; // 10

      // Align outer boundary and inner boundary so meshes completely cover their masks with safe overshoot
      for (let r = 0; r < rows; r++) {
        // PALLU_01: col 0 = innerBoundaryX, col 1 = seamX
        p1.dst_pts[r * 2][0] = Math.min(p1.dst_pts[r * 2][0], innerBoundaryX[r]);
        p1.dst_pts[r * 2 + 1][0] = seamX[r];

        // PALLU_02: col 0 = seamX, col 1 = outerBoundaryX
        p2.dst_pts[r * 2][0] = seamX[r];
        p2.dst_pts[r * 2 + 1][0] = Math.max(p2.dst_pts[r * 2 + 1][0], outerBoundaryX[r]);
      }

      // 2. Synchronize the interior seam between PALLU_01 and PALLU_02
      for (let r = 0; r < rows; r++) {
        const p1Col1Idx = r * 2 + 1;
        const p2Col0Idx = r * 2;
        const avgY = (p1.dst_pts[p1Col1Idx][1] + p2.dst_pts[p2Col0Idx][1]) * 0.5;
        p1.dst_pts[p1Col1Idx] = [seamX[r], avgY];
        p2.dst_pts[p2Col0Idx] = [seamX[r], avgY];
      }

      // 3. Apply Verlet Cloth Physics Simulation with pinned shoulder anchor
      if (options.enablePhysics !== false && sagStrength > 0) {
        const simP1 = new ClothSimulator(p1.dst_pts, p1.mesh_rows, p1.mesh_cols, {
          gravity: 0.00012 * sagStrength,
          damping: 0.94,
          pinnedRows: [0] // Pinned shoulder tuck
        });

        const simP2 = new ClothSimulator(p2.dst_pts, p2.mesh_rows, p2.mesh_cols, {
          gravity: 0.00016 * sagStrength,
          damping: 0.94,
          pinnedRows: [0] // Pinned shoulder tuck
        });

        simP1.relax(22);
        simP2.relax(22);

        const newP1 = simP1.getDestinationPoints(sagStrength);
        const newP2 = simP2.getDestinationPoints(sagStrength);

        // Re-enforce seam alignment and mask coverage after relaxation
        for (let r = 0; r < rows; r++) {
          const p1Col1Idx = r * 2 + 1;
          const p2Col0Idx = r * 2;
          const p2Col1Idx = r * 2 + 1;

          // Align seam
          const seamY = (newP1[p1Col1Idx][1] + newP2[p2Col0Idx][1]) * 0.5;
          newP1[p1Col1Idx] = [seamX[r], seamY];
          newP2[p2Col0Idx] = [seamX[r], seamY];

          // Guarantee outer edge covers mask silhouette
          newP2[p2Col1Idx][0] = Math.max(newP2[p2Col1Idx][0], outerBoundaryX[r]);
          newP1[r * 2][0] = Math.min(newP1[r * 2][0], innerBoundaryX[r]);
        }

        p1.dst_pts = newP1;
        p2.dst_pts = newP2;
      }
    }
  }

  // =========================================================================
  // REGION 5: DECORATIVE BORDERS (Spline-Based Attached Geometry)
  // =========================================================================

  class AttachedBorderRegion {
    /**
     * Treats decorative borders as fabric-attached geometry.
     * Guarantees consistent width in physical fabric space along the curved neckline,
     * bottom pleat hem, and pallu selvage without sudden twisting or stretching.
     */
    static process(mapping, options = {}) {
      const borderRatio = options.borderRatio || 0.16;
      const borderEdge = options.borderEdge || 'left';

      // 1. Ensure CHAST_01 leading edge border preserves uniform width along curved neckline
      const c1 = mapping['mask_CHAST_01.png'];
      if (c1 && c1.dst_pts && c1.src_pts) {
        const rows = c1.mesh_rows;
        const cols = c1.mesh_cols;
        const borderU = (borderEdge === 'right') ? clamp(1.0 - borderRatio * 0.5, 0.70, 0.98) : clamp(borderRatio * 0.5, 0.015, 0.14);
        for (let r = 0; r < rows; r++) {
          if (c1.src_pts[r * cols]) {
            c1.src_pts[r * cols][0] = borderU;
          }
        }
      }

      // 2. Ensure PALLU_02 outer diagonal edge displays the continuous gold border
      const p2 = mapping['mask_PALLU_02.png'];
      if (p2 && p2.dst_pts && p2.src_pts) {
        const rows = p2.mesh_rows;
        const cols = p2.mesh_cols;
        const borderU = (borderEdge === 'right') ? clamp(1.0 - borderRatio * 0.45, 0.75, 0.98) : clamp(borderRatio * 0.45, 0.015, 0.10);
        for (let r = 0; r < rows; r++) {
          const col1Idx = r * cols + (cols - 1);
          if (p2.src_pts[col1Idx]) {
            p2.src_pts[col1Idx][0] = borderU;
          }
        }
      }
    }
  }

  // =========================================================================
  // REGION 6: OCCLUSION & LAYER COMPOSITOR
  // =========================================================================

  class OcclusionCompositor {
    /**
     * Canonical anatomical depth ordering:
     * 1. Foundation underlay -> 2. Pleats back-to-front -> 3. Torso wraps -> 4. Pallu -> 5. Arm/Hand
     */
    static getCanonicalLayerOrder() {
      return [
        'mask_PATLI_07.png',     // Depth 10: Under-layer base pleat foundation
        'mask_PATLI_05.png',     // Depth 40: Pleat fold 5
        'mask_PATLI_04.png',     // Depth 50: Pleat fold 4
        'mask_PATLI_03.png',     // Depth 60: Pleat fold 3
        'mask_PATLI_02.png',     // Depth 70: Pleat fold 2
        'mask_PATLI_01.png',     // Depth 80: Pleat fold 1
        'mask_PATLI_01_NEW.png', // Depth 85: Outermost left pleat fold
        'mask_patli_08.png',     // Depth 86: Right waist tuck of vertical border
        'mask_PATLI_06.png',     // Depth 87: Front vertical border running down skirt
        'mask_CHAST_03.png',     // Depth 90: Lower waist wrap
        'mask_CHAST_02.png',     // Depth 100: Mid-torso wrap
        'mask_CHAST_01.png',     // Depth 110: Top diagonal chest wrap with gold neckline border
        'mask_PALLU_01.png',     // Depth 120: Inner pallu drape hanging from shoulder
        'mask_PALLU_02.png'      // Depth 130: Outer pallu drape with side borders
      ];
    }

    /**
     * Body/arm occlusion retention: protects model's forearm, hand, and jewelry
     */
    static applyArmOcclusion(compositeCtx, baseImg, w, h, strength = 0.90) {
      if (!baseImg || strength <= 0) return;

      const armX = Math.round(w * 0.08);
      const armY = Math.round(h * 0.40);
      const armW = Math.round(w * 0.22);
      const armH = Math.round(h * 0.20);

      const tempCanvas = document.createElement('canvas');
      tempCanvas.width = armW;
      tempCanvas.height = armH;
      const tCtx = tempCanvas.getContext('2d');

      tCtx.drawImage(baseImg, armX, armY, armW, armH, 0, 0, armW, armH);
      const imgData = tCtx.getImageData(0, 0, armW, armH);
      const data = imgData.data;

      let detectedSkinPixels = 0;
      for (let i = 0; i < data.length; i += 4) {
        const r = data[i];
        const g = data[i + 1];
        const b = data[i + 2];
        const isSkin = (r > 120 && g > 75 && b > 50 && r > g && g > b && (r - b) > 25);
        if (isSkin) {
          data[i + 3] = Math.round(255 * strength);
          detectedSkinPixels++;
        } else {
          data[i + 3] = 0;
        }
      }

      if (detectedSkinPixels > 50) {
        tCtx.putImageData(imgData, 0, 0);
        compositeCtx.save();
        compositeCtx.globalCompositeOperation = 'source-over';
        compositeCtx.drawImage(tempCanvas, armX, armY);
        compositeCtx.restore();
      }
    }
  }

  // =========================================================================
  // UNIFIED HYBRID DRAPING SYSTEM (Controller & Orchestrator)
  // =========================================================================

  class HybridDrapingSystem {
    constructor() {
      this.enabled = true;
      this.regions = {
        chest: { enabled: true, strength: 0.85 },
        waistHip: { enabled: true, flareControl: 0.65 },
        pleats: { enabled: true, compactWaist: true, foldDepth: 1.0 },
        pallu: { enabled: true, constrainWidth: true, enablePhysics: true, sagStrength: 0.45 },
        borders: { enabled: true, borderRatio: 0.16, borderEdge: 'left' },
        occlusion: { enabled: false, strength: 0.85 }
      };
    }

    get enableTPSChest() { return this.regions.chest.enabled; }
    set enableTPSChest(v) { this.regions.chest.enabled = !!v; }

    get tpsStrength() { return this.regions.chest.strength; }
    set tpsStrength(v) { this.regions.chest.strength = v; }

    get enableClothPallu() { return this.regions.pallu.enabled; }
    set enableClothPallu(v) { this.regions.pallu.enabled = !!v; }

    get palluSagStrength() { return this.regions.pallu.sagStrength; }
    set palluSagStrength(v) { this.regions.pallu.sagStrength = v; }

    get enablePleat3D() { return this.regions.pleats.enabled; }
    set enablePleat3D(v) { this.regions.pleats.enabled = !!v; }

    get pleatDepth() { return this.regions.pleats.foldDepth; }
    set pleatDepth(v) { this.regions.pleats.foldDepth = v; }

    get enableArmOcclusion() { return this.regions.occlusion.enabled; }
    set enableArmOcclusion(v) { this.regions.occlusion.enabled = !!v; }

    get occlusionStrength() { return this.regions.occlusion.strength; }
    set occlusionStrength(v) { this.regions.occlusion.strength = v; }

    /**
     * Executes the multi-region deformation pipeline in strict dependency order:
     * 1. Waist & Hip contouring
     * 2. Front Pleat fold-aware gathering
     * 3. Chest & Shoulder TPS deformation
     * 4. Pallu pinned cloth simulation & catenary drape
     * 5. Border spline attachment
     */
    processMapping(mapping, options = {}) {
      if (!this.enabled || !mapping) return mapping;
      const deformed = JSON.parse(JSON.stringify(mapping));

      // Merge runtime options
      if (options.borderRatio !== undefined) this.regions.borders.borderRatio = options.borderRatio;
      if (options.borderEdge !== undefined) this.regions.borders.borderEdge = options.borderEdge;
      if (options.tpsStrength !== undefined) this.regions.chest.strength = options.tpsStrength;
      if (options.palluSagStrength !== undefined) this.regions.pallu.sagStrength = options.palluSagStrength;
      if (options.pleatDepth !== undefined) this.regions.pleats.foldDepth = options.pleatDepth;

      // Region 2: Waist & Hip Wrap
      if (this.regions.waistHip.enabled) {
        WaistHipRegion.process(deformed, this.regions.waistHip);
      }

      // Region 3: Front Pleats
      if (this.regions.pleats.enabled) {
        FrontPleatsRegion.process(deformed, this.regions.pleats);
      }

      // Region 1: Chest & Shoulder Wrap
      if (this.regions.chest.enabled) {
        ChestShoulderRegion.process(deformed, this.regions.chest);
      }

      // Region 4: Pallu Drape
      if (this.regions.pallu.enabled) {
        PalluDrapeRegion.process(deformed, this.regions.pallu);
      }

      // Region 5: Attached Borders
      if (this.regions.borders.enabled) {
        AttachedBorderRegion.process(deformed, this.regions.borders);
      }

      return deformed;
    }
  }

  // Create singleton instance
  const system = new HybridDrapingSystem();

  return {
    TPSDeformer,
    ClothParticle,
    ClothConstraint,
    ClothSimulator,
    ChestShoulderRegion,
    WaistHipRegion,
    FrontPleatsRegion,
    PalluDrapeRegion,
    AttachedBorderRegion,
    OcclusionCompositor,
    HybridDrapingSystem,
    system,
    // Compatibility aliases for app.js
    controller: system,
    Pleat3DDeformer: FrontPleatsRegion,
    OcclusionDepthManager: OcclusionCompositor
  };
}));
