/**
 * Generalized Irregular Saree Mapping Engine
 * 
 * Maps normalized source fabric zones onto destination garment meshes:
 * 
 * Fabric Architecture (Normalized UV Space [0..1, 0..1]):
 * - Left Zari Border:        u in [0.00 .. 0.16], v in [0.00 .. 0.58]
 * - Right Zari Border:       u in [0.86 .. 1.00], v in [0.00 .. 0.58]
 * - Body Floral Vines:       u in [0.14 .. 0.86], v in [0.00 .. 0.58]
 * - Pallu Transition Bands:  u in [0.00 .. 1.00], v in [0.58 .. 0.68]
 * - Pallu Peacock Medallion: u in [0.10 .. 0.90], v in [0.68 .. 0.88]
 * - Lower Zari Stripe Hem:   u in [0.00 .. 1.00], v in [0.88 .. 1.00]
 * 
 * Destination Garment Mapping:
 * 1. PLEATS (PATLI_07 base + PATLI_01..08 folds):
 *    - Lower skirt accordion pleats sampling body floral vines (v: 0.10..0.52)
 *    - Lower hem anchored at v=0.55..0.58 so bottom horizontal border/hem is aligned.
 *    - Overlapping accordion phase shift across fabric width.
 * 
 * 2. CHEST & TORSO WRAP (CHAST_01, 02, 03):
 *    - CHAST_01 (Top diagonal bust wrap): Left edge aligns along side gold border (u: 0.02..0.14),
 *      stretching diagonally down into the green floral vine body (u: 0.14..0.60).
 *    - CHAST_02 & 03: Mid/lower torso wraps continuing body vine weave seamlessly into the waist.
 * 
 * 3. PALLU (PALLU_01 & PALLU_02):
 *    - Unified continuous drape hanging from left shoulder to floor.
 *    - PALLU_01 (inner drape): X in [0.21 .. 0.73]
 *    - PALLU_02 (outer drape): X in [0.42 .. 0.96]
 *    - Samples the full ornate pallu section: peacock medallion and zari bands upright.
 */

// Exported Fabric Region Polygons for Debug Visualizer
const FABRIC_ZONES = {
  leftBorder: {
    name: "Left Zari Border",
    color: "#eab308",
    polygon: [[0.00, 0.00], [0.16, 0.00], [0.16, 0.58], [0.00, 0.58]]
  },
  rightBorder: {
    name: "Right Zari Border",
    color: "#ca8a04",
    polygon: [[0.86, 0.00], [1.00, 0.00], [1.00, 0.58], [0.86, 0.58]]
  },
  bodyFabric: {
    name: "Saree Body (Floral Vines)",
    color: "#10b981",
    polygon: [[0.16, 0.00], [0.86, 0.00], [0.86, 0.58], [0.16, 0.58]]
  },
  palluSection: {
    name: "Pallu Section (Peacocks & Zari)",
    color: "#ec4899",
    polygon: [[0.00, 0.58], [1.00, 0.58], [1.00, 1.00], [0.00, 1.00]]
  }
};

function generateGeneralizedMapping(options = {}) {
  const {
    palluPosition = "bottom",
    palluRatio = 0.42,
    borderRatio = 0.16,
    borderEdge = "left",
    borderOrientation = "vertical", // 'vertical' (along left/right edge) or 'horizontal' (along top/bottom edge)
    borderScale = 1.0,
    borderOffset = 0.0,
    palluScale = 1.0,
    palluOffset = 0.0,
    pleatPatternMode = "progressive", // 'progressive' (varying motifs across folds) or 'uniform' (aligned border/body)
    pleatOffset = 0.0,
    flipX = false,
    flipY = false,
    inset = 0.005
  } = options;

  const original = (typeof window !== 'undefined' && window.RAW_MAPPING) ? window.RAW_MAPPING : (options.originalMapping || {});
  const newMapping = {};

  const clamp = (v, min = 0, max = 1) =>
    Math.max(min, Math.min(max, v));

  const lerp = (a, b, t) => a + (b - a) * t;

  const pRatio = clamp(palluRatio, 0.20, 0.65);
  const bRatio = clamp(borderRatio * clamp(borderScale, 0.5, 2.0), 0.04, 0.35);
  const safeInset = clamp(inset, 0, 0.04);
  const bOffset = clamp(borderOffset, -0.15, 0.15);
  const pOffset = clamp(palluOffset, -0.20, 0.20);

  // Define Pallu and Body Y-ranges in normalized saree texture space
  const pallu = palluPosition === "bottom"
    ? { y0: clamp(1.0 - pRatio + pOffset, 0.35, 0.90), y1: 1.0 }
    : { y0: 0.0, y1: clamp(pRatio + pOffset, 0.20, 0.65) };

  const body = palluPosition === "bottom"
    ? { y0: 0.0, y1: pallu.y0 }
    : { y0: pallu.y1, y1: 1.0 };

  // Calculate border bounds
  let borderX0 = 0.0;
  let borderX1 = bRatio;
  if (borderEdge === "right") {
    borderX0 = clamp(1.0 - bRatio + bOffset, 0.65, 0.96);
    borderX1 = 1.0;
  } else {
    borderX0 = clamp(bOffset, 0.0, 0.15);
    borderX1 = clamp(bOffset + bRatio, 0.05, 0.40);
  }

  const bodyX0 = borderEdge === "right" ? 0.0 : borderX1;
  const bodyX1 = borderEdge === "right" ? borderX0 : 1.0;

  // Dynamically update exported FABRIC_ZONES with current user settings
  const dynamicZones = {
    decorativeBorder: {
      name: borderEdge === "right" ? "Right Decorative Border" : "Left Decorative Border",
      color: "#eab308",
      polygon: [
        [borderX0, body.y0],
        [borderX1, body.y0],
        [borderX1, body.y1],
        [borderX0, body.y1]
      ]
    },
    bodyFabric: {
      name: "Main Saree Body (Floral / Geometric Motifs)",
      color: "#10b981",
      polygon: [
        [bodyX0, body.y0],
        [bodyX1, body.y0],
        [bodyX1, body.y1],
        [bodyX0, body.y1]
      ]
    },
    palluSection: {
      name: "Pallu Section (Peacocks, Medallions & Zari Bands)",
      color: "#ec4899",
      polygon: [
        [0.00, pallu.y0],
        [1.00, pallu.y0],
        [1.00, pallu.y1],
        [0.00, pallu.y1]
      ]
    },
    pleatRegion: {
      name: "Skirt Pleats Zone (Lower Hem & Accordion Field)",
      color: "#3b82f6",
      polygon: [
        [bodyX0, lerp(body.y0, body.y1, 0.10)],
        [bodyX1, lerp(body.y0, body.y1, 0.10)],
        [bodyX1, clamp(body.y1 - 0.01, 0.15, 0.99)],
        [bodyX0, clamp(body.y1 - 0.01, 0.15, 0.99)]
      ]
    }
  };
  if (typeof window !== 'undefined') {
    window.FABRIC_ZONES = dynamicZones;
  }

  /**
   * Arbitrary Quad/Polygon Mesh Mapper
   * Maps an irregular or regular grid by interpolating between 4 corners:
   * top-left (pTL), top-right (pTR), bottom-left (pBL), bottom-right (pBR)
   */
  function mapQuadMesh(key, pTL, pTR, pBL, pBR) {
    const source = original[key];
    if (!source) return;

    const entry = JSON.parse(JSON.stringify(source));
    const rows = entry.mesh_rows;
    const cols = entry.mesh_cols;

    if (!Number.isInteger(rows) || rows < 2 || !Number.isInteger(cols) || cols < 2) {
      console.warn("Invalid mesh dimensions:", key);
      return;
    }

    const srcPts = [];

    for (let r = 0; r < rows; r++) {
      const v = r / (rows - 1);
      // Interpolate left and right boundaries at height v
      const leftPt = [lerp(pTL[0], pBL[0], v), lerp(pTL[1], pBL[1], v)];
      const rightPt = [lerp(pTR[0], pBR[0], v), lerp(pTR[1], pBR[1], v)];

      for (let c = 0; c < cols; c++) {
        const u = c / (cols - 1);
        let x = lerp(leftPt[0], rightPt[0], u);
        let y = lerp(leftPt[1], rightPt[1], u);

        if (flipX) x = 1.0 - x;
        if (flipY) y = 1.0 - y;

        srcPts.push([
          clamp(x, safeInset, 1.0 - safeInset),
          clamp(y, safeInset, 1.0 - safeInset)
        ]);
      }
    }

    entry.src_pts = srcPts;
    newMapping[key] = entry;
  }

  /**
   * Spatial UV Mapper
   * Projects texture coords smoothly across complex multi-part drapes (like PALLU_01 + PALLU_02)
   */
  function mapSpatialMesh(key, drapeBounds, uRange, vRange) {
    const source = original[key];
    if (!source || !source.dst_pts) return;

    const entry = JSON.parse(JSON.stringify(source));
    const srcPts = [];

    entry.dst_pts.forEach(([dstX, dstY]) => {
      const normX = clamp((dstX - drapeBounds.minX) / (drapeBounds.maxX - drapeBounds.minX), 0, 1);
      const normY = clamp((dstY - drapeBounds.minY) / (drapeBounds.maxY - drapeBounds.minY), 0, 1);

      let u = lerp(uRange[0], uRange[1], normX);
      let v = lerp(vRange[0], vRange[1], normY);

      if (flipX) u = 1.0 - u;
      if (flipY) v = 1.0 - v;

      srcPts.push([
        clamp(u, safeInset, 1.0 - safeInset),
        clamp(v, safeInset, 1.0 - safeInset)
      ]);
    });

    entry.src_pts = srcPts;
    newMapping[key] = entry;
  }

  // ==============================================================
  // 1. PALLU MAPPING (Triangular Fold Method from Raw Saree)
  // Maps the decorative pallu section (swans, zari stripes, floral motifs)
  // onto the destination triangular drape hanging from left shoulder to hem.
  // Outer diagonal edge displays the continuous gold zari border (matching SareeViz),
  // while the interior displays the ornate peacock medallion band.
  // ==============================================================
  const p1Entry = original["mask_PALLU_01.png"];
  const p2Entry = original["mask_PALLU_02.png"];

  if (p1Entry && p1Entry.dst_pts && p2Entry && p2Entry.dst_pts) {
    const p1 = JSON.parse(JSON.stringify(p1Entry));
    const p2 = JSON.parse(JSON.stringify(p2Entry));

    // Saree Pallu Source Boundaries (normalized UV space):
    // In SareeViz reference:
    // - Rows 0..2 (V in [0.36 .. 0.52]): shoulder tuck & upper drape (green floral vines)
    // - Rows 3..5 (V in [0.55 .. 0.68]): horizontal gold & red/green dotted stripes
    // - Rows 6..7 (V in [0.69 .. 0.87]): Twin Swans & Lotus Medallion (Zone 5, perfectly proportioned)
    // - Row 8 (V in [0.89 .. 0.96]): lower horizontal dotted stripes (Zone 6)
    // - Row 9 (V in [0.97 .. 1.00]): bottom gold fringe hem border (Zone 7)
    const uZariBorder = borderEdge === "right" ? 0.975 : 0.045;
    const uPalluInner = borderEdge === "right" ? 0.080 : 0.800;

    // Center the Red Lotus Medallion across the visible hanging drape (P2 + P1):
    // P2 spans [uMid=0.650 .. uOuter=0.045], placing the Red Lotus right at X ~ 0.62 in screen space!
    // P1 spans [uInner=0.800 .. uMid=0.650] for seamless continuity across the shared seam!
    const uMid = borderEdge === "right" ? 0.250 : 0.650;

    const vPalluCurve = [
      0.380, // Row 0: shoulder tuck (green floral vines)
      0.450, // Row 1: shoulder fall (green floral vines)
      0.520, // Row 2: upper chest drape transition
      0.575, // Row 3: transition to upper horizontal dotted stripes (Upper Stripes Panel)
      0.630, // Row 4: upper horizontal dotted stripes
      0.680, // Row 5: lower horizontal dotted stripes before medallion
      0.725, // Row 6: Twin Swans & Red Lotus Medallion upper petals (Medallion Panel)
      0.840, // Row 7: Twin Swans & Red Lotus Medallion lower petals (proportional 1:1 aspect!)
      0.910, // Row 8: lower horizontal dotted zari stripes (Lower Stripes Panel)
      0.985  // Row 9: bottom gold fringe hem border (Hem Fringe Panel)
    ];

    const rows = 10;
    const p1Src = [];
    const p2Src = [];

    for (let r = 0; r < rows; r++) {
      const v = vPalluCurve[r];

      // Outer diagonal boundary of P2 (Col 1) displays the continuous gold border:
      const uOuter = uZariBorder;
      // Inner boundary of P1 (Col 0) near waist/hip displays the inner body weave:
      const uInner = uPalluInner;

      let p1Col0U = uInner;
      let p1Col1U = uMid;
      let p2Col0U = uMid;
      let p2Col1U = uOuter;

      let finalV = v;

      if (flipX) {
        p1Col0U = 1.0 - p1Col0U;
        p1Col1U = 1.0 - p1Col1U;
        p2Col0U = 1.0 - p2Col0U;
        p2Col1U = 1.0 - p2Col1U;
      }
      if (flipY) finalV = 1.0 - finalV;

      // P1: Inner column (Col 0) to Middle seam (Col 1)
      p1Src.push([clamp(p1Col0U, safeInset, 1.0 - safeInset), clamp(finalV, safeInset, 1.0 - safeInset)]);
      p1Src.push([clamp(p1Col1U, safeInset, 1.0 - safeInset), clamp(finalV, safeInset, 1.0 - safeInset)]);

      // P2: Middle seam (Col 0) to Outer diagonal edge (Col 1)
      p2Src.push([clamp(p2Col0U, safeInset, 1.0 - safeInset), clamp(finalV, safeInset, 1.0 - safeInset)]);
      p2Src.push([clamp(p2Col1U, safeInset, 1.0 - safeInset), clamp(finalV, safeInset, 1.0 - safeInset)]);
    }

    p1.src_pts = p1Src;
    p2.src_pts = p2Src;

    newMapping["mask_PALLU_01.png"] = p1;
    newMapping["mask_PALLU_02.png"] = p2;
  }

  // ==============================================================
  // 2. CHEST & TORSO WRAP (CHAST_01, 02, 03)
  // Natural drape following the curved diagonal wrap from right shoulder to waist
  // ==============================================================
  const bodyY0 = body.y0;
  const bodyY1 = body.y1;

  /**
   * Geodesic Ribbon Mapper
   * Maps curved garment meshes (like the diagonal bust wrap) by tracking cumulative
   * arc length along the curved neckline/seam rather than linear affine interpolation.
   * This completely eliminates polygon shear and keeps the decorative border pinned
   * seamlessly along the curved neckline contour.
   */
  function mapGeodesicRibbon(key, borderU, bodyU, vStart, vEnd) {
    const source = original[key];
    if (!source || !source.dst_pts) return;

    const entry = JSON.parse(JSON.stringify(source));
    const rows = entry.mesh_rows;
    const cols = entry.mesh_cols;
    const dstPts = entry.dst_pts;

    // 1. Calculate cumulative arc length along col 0 (the neckline / leading edge)
    const arcLengths = [0];
    for (let r = 0; r < rows - 1; r++) {
      const pA = dstPts[r * cols];
      const pB = dstPts[(r + 1) * cols];
      arcLengths.push(arcLengths[arcLengths.length - 1] + Math.hypot(pB[0] - pA[0], pB[1] - pA[1]));
    }
    const totalArc = arcLengths[arcLengths.length - 1] || 1;

    const srcPts = [];
    for (let r = 0; r < rows; r++) {
      // Normalized distance along the drape curve
      const normArc = arcLengths[r] / totalArc;
      const v = lerp(vStart, vEnd, normArc);

      for (let c = 0; c < cols; c++) {
        const u = (c === 0) ? borderU : bodyU;

        let finalU = u;
        let finalV = v;

        if (flipX) finalU = 1.0 - finalU;
        if (flipY) finalV = 1.0 - finalV;

        srcPts.push([
          clamp(finalU, safeInset, 1.0 - safeInset),
          clamp(finalV, safeInset, 1.0 - safeInset)
        ]);
      }
    }

    entry.src_pts = srcPts;
    newMapping[key] = entry;
  }

  // CHAST_01: The upper diagonal wrap across the bust from neck to waist
  // Col 0: Gold neckline border [u ~ 0.045]
  // Col 1: Body floral vine & upright bird [u ~ 0.260], preserving 1:1 motif aspect ratio
  // without stretching the bird motif across the entire bust
  const borderNecklineU = borderEdge === "right" 
    ? clamp(borderX1 - 0.03, 0.70, 0.98) 
    : clamp(borderX0 + 0.045, 0.015, 0.12);
  const bodyFieldU = borderEdge === "right"
    ? lerp(bodyX0, bodyX1, 0.28)
    : 0.260; // Narrow body motif slice preserving upright bird proportions!

  mapGeodesicRibbon("mask_CHAST_01.png", borderNecklineU, bodyFieldU, bodyY0 + 0.08, bodyY0 + 0.30);

  // CHAST_02: Mid-torso tuck following the natural body curve below the bust
  // Smoothly continues the body pattern into the torso
  mapGeodesicRibbon("mask_CHAST_02.png", lerp(bodyX0, bodyX1, 0.15), lerp(bodyX0, bodyX1, 0.55), bodyY0 + 0.14, bodyY0 + 0.44);

  // CHAST_03: Lower torso wrap leading directly into the waist tuck above pleats
  mapGeodesicRibbon("mask_CHAST_03.png", lerp(bodyX0, bodyX1, 0.25), lerp(bodyX0, bodyX1, 0.65), bodyY0 + 0.20, bodyY0 + 0.50);

  // ==============================================================
  // 3. PLEATS / SKIRT (PATLI_07 base + PATLI_01..08 folds)
  // Maps the decorative bottom zari border horizontally across the pleated hem
  // with the swan/lotus motif positioned right above the hemline, exactly as in
  // ==============================================================
  // 3. PLEATS / SKIRT (PATLI_07 base + PATLI_01..08 folds)
  // Maps the decorative bottom zari border horizontally across the pleated hem
  // with the swan/lotus motif positioned right above the hemline, exactly as in
  // reference drape design (Image 2).
  // ==============================================================
  // In raw saree fabric:
  // - U in [0.015 .. 0.140]: Decorative gold zari border running lengthwise
  // - U in [0.150 .. 0.240]: Swan and red lotus flower motif
  // - U in [0.250 .. 0.650]: Floral vine saree body field
  // Mesh rows (r): r=0 is WAIST (top), r=rows-1 is HEM (bottom).
  // Mesh cols (c): c=0 is fold left, c=1 is fold right.
  //
  // For the pleat to display the border at the hem and vines at the waist:
  // pTL (top-left)    : [waistU, v0]
  // pTR (top-right)   : [waistU, v1]
  // pBL (bottom-left) : [hemBorderU, v0]
  // pBR (bottom-right): [hemBorderU, v1]
  const hemBorderU = borderEdge === "right" ? 0.985 : 0.045;
  const hemMotifU  = borderEdge === "right" ? 0.760 : 0.240;
  const waistBodyU = borderEdge === "right" ? 0.450 : 0.520;

  // FRONT VERTICAL BORDER:
  // In SareeViz reference, the prominent vertical border runs straight down the front skirt
  // at X in [0.18 .. 0.24], which anatomically corresponds to mask_PATLI_06.png (skirt to hem)
  // and mask_patli_08.png (waist tuck extension).
  // Col 0 (left edge, facing pleat folds) = outer silver selvage (U ~ 0.015)
  // Col 1 (right edge, facing pallu) = inner scalloped border (U ~ 0.135)
  // Natural repeat of silver circular medallions preserved with V in [0.05 .. 0.50]
  const borderCol0U = borderEdge === "right" ? 0.985 : 0.015;
  const borderCol1U = borderEdge === "right" ? 0.865 : 0.135;

  // mask_PATLI_06.png: Prominent vertical front skirt border (X in [0.18 .. 0.24], Y in [0.50 .. 0.93])
  mapQuadMesh(
    "mask_PATLI_06.png",
    [borderCol0U, bodyY0 + 0.10],
    [borderCol1U, bodyY0 + 0.10],
    [borderCol0U, bodyY0 + 0.50],
    [borderCol1U, bodyY0 + 0.50]
  );

  // mask_patli_08.png: Upper waist tuck extension of the front vertical border (Y in [0.45 .. 0.75])
  mapQuadMesh(
    "mask_patli_08.png",
    [borderCol0U, bodyY0 + 0.02],
    [borderCol1U, bodyY0 + 0.02],
    [borderCol0U, bodyY0 + 0.22],
    [borderCol1U, bodyY0 + 0.22]
  );

  // Individual cascading pleat folds (from outermost left fold PATLI_01_NEW to center fold PATLI_05)
  const foldKeys = [
    "mask_PATLI_01_NEW.png",
    "mask_PATLI_01.png",
    "mask_PATLI_02.png",
    "mask_PATLI_03.png",
    "mask_PATLI_04.png",
    "mask_PATLI_05.png"
  ];

  const vFoldSpan = 0.070;
  const vBodyAvailable = Math.max(0.18, (bodyY1 - bodyY0) - 0.10);
  const vStride = pleatPatternMode === "uniform"
    ? 0.005
    : Math.max(0.018, vBodyAvailable / (foldKeys.length + 1));

  // PATLI_07: Under-layer base pleat foundation spanning across front skirt
  // Spans across the entire pleat region to provide solid foundation beneath folds
  mapQuadMesh(
    "mask_PATLI_07.png",
    [waistBodyU, bodyY0 + 0.02],
    [waistBodyU, bodyY0 + 0.35],
    [hemBorderU, bodyY0 + 0.02],
    [hemBorderU, bodyY0 + 0.35]
  );

  const pOffsetV = clamp(pleatOffset, -0.20, 0.20);
  const uFoldStride = pleatPatternMode === "uniform" ? 0.005 : 0.020;

  foldKeys.forEach((key, i) => {
    const v0 = clamp(bodyY0 + 0.02 + pOffsetV + i * vStride, safeInset, 1.0 - vFoldSpan - safeInset);
    const v1 = v0 + vFoldSpan;
    const uTop0 = clamp(waistBodyU + i * uFoldStride, 0.20, 0.85);
    const uTop1 = clamp(uTop0 + 0.05, 0.25, 0.90);

    // pTL: top-left (waist vines)
    // pTR: top-right (waist vines)
    // pBL: bottom-left (hem zari border)
    // pBR: bottom-right (hem zari border)
    // Along height r, interpolates from waist vines (U ~ 0.52) down to the bottom hem border (U ~ 0.02)
    mapQuadMesh(
      key,
      [uTop0, v0],
      [uTop1, v1],
      [hemBorderU, v0],
      [hemBorderU, v1]
    );
  });

  return newMapping;
}

if (typeof window !== 'undefined') {
  window.FABRIC_ZONES = FABRIC_ZONES;
  window.generateGeneralizedMapping = generateGeneralizedMapping;
}
if (typeof module !== 'undefined' && module.exports) {
  module.exports = {
    FABRIC_ZONES,
    generateGeneralizedMapping
  };
}

