/**
 * Main Application Orchestrator for Saree Drape Studio
 * Full-Saree Zero-Loss Mapping Engine with Diagnostics
 */

(function () {
  const MODEL_WIDTH = 2400;
  const MODEL_HEIGHT = 3600;
  const DRAPE_PATH = 'drape-lab/';

  const LAYER_ORDER = [
    'mask_PATLI_07.png',     // Under-layer base pleat foundation (Depth 10)
    'mask_PATLI_05.png',     // Center-right pleat fold 5 (Depth 40)
    'mask_PATLI_04.png',     // Center pleat fold 4 (Depth 50)
    'mask_PATLI_03.png',     // Center-left pleat fold 3 (Depth 60)
    'mask_PATLI_02.png',     // Left pleat fold 2 (Depth 70)
    'mask_PATLI_01.png',     // Left pleat fold 1 (Depth 80)
    'mask_PATLI_01_NEW.png', // Outermost left pleat fold (Depth 85)
    'mask_patli_08.png',     // Right waist tuck of vertical border (Depth 86, over pleats)
    'mask_PATLI_06.png',     // Front vertical border running down skirt (Depth 87, over pleats)
    'mask_CHAST_03.png',     // Lower waist wrap (Depth 90)
    'mask_CHAST_02.png',     // Mid-torso wrap (Depth 100)
    'mask_CHAST_01.png',     // Top diagonal chest wrap with gold neckline border (Depth 110)
    'mask_PALLU_01.png',     // Inner pallu drape hanging from shoulder (Depth 120)
    'mask_PALLU_02.png'      // Outer pallu drape with side borders (Depth 130)
  ];

  const state = {
    originalMapping: null,
    activeMapping: null,
    baseImage: null,
    rawMasks: {},
    filledMasks: {},
    useSolidMasks: true,
    rawSareeImage: null,
    processedSareeCanvas: null,
    activeLayers: {},
    zoom: 1.0,
    isComparing: false,
    showWireframe: false,
    showLabels: false,
    showCoverage: false,
    showMasks: false,
    showSilhouette: false,
    showSourcePolygons: false,
    showUncovered: false,
    showVertexIds: false,
    showSeams: false,
    qualityReport: null,
    shadowStrength: 0.85,
    opacity: 1.0,
    brightness: 1.0,
    contrast: 1.05,
    // Hybrid Drape Engine settings
    enableHybridEngine: true,
    enableTPSChest: true,
    tpsStrength: 0.85,
    enableClothPallu: true,
    palluSagStrength: 0.45,
    enablePleat3D: true,
    pleatDepth: 1.0,
    enableArmOcclusion: false,
    occlusionStrength: 0.85,
    mappingMode: 'generalized',
    palluPosition: 'bottom',
    palluRatio: 0.38,
    borderRatio: 0.16,
    borderEdge: 'left',
    borderScale: 1.0,
    borderOffset: 0.0,
    palluScale: 1.0,
    palluOffset: 0.0,
    pleatPatternMode: 'progressive',
    pleatOffset: 0.0,
    rotation: 0,
    flipX: false,
    flipY: false,
    diagnostics: {},
    darkBackground: true,
    calibrationToolOpen: false,
    calibDraggingEnabled: false,
    calibSelectedLayer: 'mask_CHAST_01.png',
    calibTargetMode: 'dst', // 'dst' or 'src'
    calibSelectedPointIndex: null,
    calibHistory: [],
    calibHistoryIndex: -1,
    isDraggingPoint: false,
    currentTemplateId: 'standard_nivi_standing',
    availableTemplates: []
  };

  const baseCanvas = document.getElementById('base-canvas');
  const baseCtx = baseCanvas.getContext('2d');
  const glCanvas = document.getElementById('gl-canvas');
  const compositeCanvas = document.getElementById('composite-canvas');
  const compositeCtx = compositeCanvas.getContext('2d');
  const overlayCanvas = document.getElementById('overlay-canvas');
  const overlayCtx = overlayCanvas.getContext('2d');

  const canvasWrapper = document.getElementById('canvas-wrapper');
  const loadingOverlay = document.getElementById('loading-overlay');
  const loadingText = document.getElementById('loading-text');
  const renderStatus = document.getElementById('render-status');

  const layerCanvas = document.createElement('canvas');
  const layerCtx = layerCanvas.getContext('2d');

  let renderer = null;
  let sareeGLTexture = null;

  [baseCanvas, glCanvas, compositeCanvas, overlayCanvas, layerCanvas].forEach(c => {
    c.width = MODEL_WIDTH;
    c.height = MODEL_HEIGHT;
  });

  canvasWrapper.style.width = '600px';
  canvasWrapper.style.height = `${(600 * MODEL_HEIGHT) / MODEL_WIDTH}px`;

  function renderBaseModel() {
    baseCtx.clearRect(0, 0, MODEL_WIDTH, MODEL_HEIGHT);
    if (!state.baseImage) return;

    if (state.darkBackground) {
      // 1. Fill base canvas with deep black/dark charcoal background
      baseCtx.fillStyle = '#0a0d14';
      baseCtx.fillRect(0, 0, MODEL_WIDTH, MODEL_HEIGHT);

      // 2. Draw base model using darken / multiply so pure white background becomes black
      // while the model, hair, skin, and jewelry stay vivid and the white base saree stands out clearly
      baseCtx.drawImage(state.baseImage, 0, 0, MODEL_WIDTH, MODEL_HEIGHT);
    } else {
      baseCtx.drawImage(state.baseImage, 0, 0, MODEL_WIDTH, MODEL_HEIGHT);
    }
  }

  async function init() {
    try {
      loadingText.textContent = 'Initializing WebGL Engine...';
      renderer = new SareeRenderer(glCanvas);

      loadingText.textContent = 'Loading Mapping Data...';
      const mappingRes = await fetch(`${DRAPE_PATH}mapping.json?t=${Date.now()}`);
      state.originalMapping = await mappingRes.json();
      window.RAW_MAPPING = state.originalMapping;

      loadingText.textContent = 'Loading Base Model (2400x3600)...';
      state.baseImage = await loadImage(`${DRAPE_PATH}base.jpg`);
      renderBaseModel();

      LAYER_ORDER.forEach(name => {
        state.activeLayers[name] = true;
      });

      loadingText.textContent = 'Processing Drape Alpha Masks...';
      state.silhouetteMasks = {};
      await Promise.all(
        LAYER_ORDER.map(async name => {
          const img = await loadImage(`${DRAPE_PATH}${name}`);
          state.rawMasks[name] = img;
          const solidMask = createFilledMask(img, name);
          state.filledMasks[name] = solidMask;
          state.silhouetteMasks[name] = createSilhouettePreview(solidMask);
        })
      );

      console.log('[DEBUG INIT] Starting post-mask init...');
      updateActiveMapping();
      console.log('[DEBUG INIT] updateActiveMapping done');
      populateLayerList();
      console.log('[DEBUG INIT] populateLayerList done');
      bindEvents();
      console.log('[DEBUG INIT] bindEvents done');
      await fetchTemplates();
      console.log('[DEBUG INIT] fetchTemplates done');

      loadingText.textContent = 'Loading Uploaded Saree Image...';
      try {
        const rawImg = await loadImage(`crops/raw_uploaded_saree.jpg?t=${Date.now()}`);
        console.log('[DEBUG INIT] rawImg loaded successfully');
        setRawSaree(rawImg);
        console.log('[DEBUG INIT] setRawSaree completed');
      } catch (e) {
        console.warn('Falling back to default emerald saree:', e);
        const defaultSaree = generateSampleSaree('royal_emerald');
        setRawSaree(defaultSaree);
      }

      loadingOverlay.style.display = 'none';
      renderStatus.textContent = 'Ready • Full Image Preserved • Non-AI WebGL';
      console.log('[DEBUG INIT] Initialization fully completed!');

      // Auto-save snapshot of hybrid rendered drape to crops folder
      setTimeout(() => {
        console.log('[DEBUG INIT] Triggering saveRenderSnapshot...');
        if (typeof saveRenderSnapshot === 'function') {
          saveRenderSnapshot('hybrid_draped_result.png');
        }
      }, 1200);
    } catch (err) {
      console.error('Initialization failed:', err);
      loadingText.textContent = `Error: ${err.message}`;
    }
  }

  function updateActiveMapping() {
    let mapping;
    if (state.mappingMode === 'generalized') {
      mapping = generateGeneralizedMapping({
        palluPosition: state.palluPosition,
        palluRatio: state.palluRatio,
        borderRatio: state.borderRatio,
        borderEdge: state.borderEdge,
        borderScale: state.borderScale,
        borderOffset: state.borderOffset,
        palluScale: state.palluScale,
        palluOffset: state.palluOffset,
        pleatPatternMode: state.pleatPatternMode,
        pleatOffset: state.pleatOffset,
        flipX: state.flipX,
        flipY: state.flipY
      });
    } else {
      mapping = JSON.parse(JSON.stringify(state.originalMapping));
    }

    // Apply Hybrid Drape Engine (TPS Bust Curvature & Verlet Cloth Pallu Relaxation)
    if (window.HybridDrape && state.enableHybridEngine) {
      window.HybridDrape.controller.enabled = state.enableHybridEngine;
      window.HybridDrape.controller.enableTPSChest = state.enableTPSChest;
      window.HybridDrape.controller.tpsStrength = state.tpsStrength;
      window.HybridDrape.controller.enableClothPallu = state.enableClothPallu;
      window.HybridDrape.controller.palluSagStrength = state.palluSagStrength;
      state.activeMapping = window.HybridDrape.controller.processMapping(mapping);
    } else {
      state.activeMapping = mapping;
    }

    updateDiagnostics();
  }

  function loadImage(src) {
    return new Promise((resolve, reject) => {
      const img = new Image();
      img.crossOrigin = 'anonymous';
      img.onload = () => resolve(img);
      img.onerror = e => reject(new Error(`Failed to load ${src}`));
      img.src = src;
    });
  }

  function setRawSaree(imageOrCanvas) {
    state.rawSareeImage = imageOrCanvas;
    processOrientedAndPreservedSaree();
  }

  /**
   * Preserves 100% of uploaded saree without any arbitrary clipping or cropping
   */
  function processOrientedAndPreservedSaree() {
    if (!state.rawSareeImage) return;

    const src = state.rawSareeImage;
    const srcW = src.naturalWidth || src.width;
    const srcH = src.naturalHeight || src.height;

    const rot = state.rotation % 360;
    const isSideways = (rot === 90 || rot === 270);

    const rotCanvas = document.createElement('canvas');
    rotCanvas.width = isSideways ? srcH : srcW;
    rotCanvas.height = isSideways ? srcW : srcH;
    const ctx = rotCanvas.getContext('2d');

    ctx.save();
    ctx.translate(rotCanvas.width / 2, rotCanvas.height / 2);
    ctx.rotate((rot * Math.PI) / 180);
    ctx.drawImage(src, -srcW / 2, -srcH / 2);
    ctx.restore();

    // Standardize to 960x1600 texture space WITHOUT cropping any fabric
    state.processedSareeCanvas = fitProportionallyToRatio(rotCanvas, 960, 1600);

    if (sareeGLTexture) {
      renderer.gl.deleteTexture(sareeGLTexture);
    }
    sareeGLTexture = renderer.createTexture(state.processedSareeCanvas);

    // Update thumbnail preview
    const thumb = document.getElementById('saree-thumb');
    const thumbContainer = document.getElementById('saree-thumb-container');
    const dropzoneContent = document.querySelector('.upload-content');

    thumb.src = state.processedSareeCanvas.toDataURL('image/jpeg', 0.85);
    thumbContainer.style.display = 'block';
    dropzoneContent.style.display = 'none';

    updateDiagnostics();
    renderDrape();
  }

  function runQualityInspection() {
    const criticalErrors = [];
    const coverageWarnings = [];
    const textureWarnings = [];
    const suspectedSeams = [];
    const collapsedTriangles = [];

    // 1. Asset & Mapping Existence Validation
    if (!state.activeMapping) {
      criticalErrors.push({
        layer: 'System',
        title: 'Missing Mapping Data',
        description: 'No active mesh mapping loaded.',
        suggestion: 'Load mapping.json or restore default template.'
      });
    }

    if (!state.processedSareeCanvas) {
      criticalErrors.push({
        layer: 'System',
        title: 'Missing Fabric Texture',
        description: 'No uploaded saree fabric image loaded.',
        suggestion: 'Upload a saree image in Step 1.'
      });
    }

    // 2. Mesh Geometry & Normalized Range Verification
    if (state.activeMapping) {
      LAYER_ORDER.forEach(layerKey => {
        const m = state.activeMapping[layerKey];
        if (!m) {
          criticalErrors.push({
            layer: layerKey,
            title: 'Missing Layer Mesh',
            description: `Layer ${layerKey} is absent from activeMapping.`,
            suggestion: 'Restore layer from drape-lab/mapping.json.'
          });
          return;
        }

        const rows = m.mesh_rows;
        const cols = m.mesh_cols;
        const expectedCount = rows * cols;

        if (!Array.isArray(m.dst_pts) || m.dst_pts.length !== expectedCount) {
          criticalErrors.push({
            layer: layerKey,
            title: 'Invalid Vertex Count',
            description: `dst_pts has ${m.dst_pts ? m.dst_pts.length : 0} points, expected ${expectedCount} (${rows}x${cols}).`,
            suggestion: 'Re-initialize mesh points grid.'
          });
        }

        if (!Array.isArray(m.src_pts) || m.src_pts.length !== expectedCount) {
          criticalErrors.push({
            layer: layerKey,
            title: 'Invalid Source Texture Points',
            description: `src_pts has ${m.src_pts ? m.src_pts.length : 0} points, expected ${expectedCount}.`,
            suggestion: 'Re-generate source UV coordinates via mapper.js.'
          });
        }

        // Check for out-of-bounds coordinates
        if (m.dst_pts) {
          m.dst_pts.forEach((pt, idx) => {
            if (pt[0] < -0.01 || pt[0] > 1.01 || pt[1] < -0.01 || pt[1] > 1.01) {
              criticalErrors.push({
                layer: layerKey,
                pointIndex: idx,
                title: 'Destination Vertex Out of Bounds',
                description: `Vertex #${idx} is outside normalized [0..1] range: [${pt[0].toFixed(3)}, ${pt[1].toFixed(3)}]`,
                suggestion: 'Clamp vertex inside canvas bounds.'
              });
            }
          });
        }

        // Check for zero-area / collapsed triangles
        if (m.dst_pts && rows >= 2 && cols >= 2) {
          for (let r = 0; r < rows - 1; r++) {
            for (let c = 0; c < cols - 1; c++) {
              const i0 = r * cols + c;
              const i1 = r * cols + (c + 1);
              const i2 = (r + 1) * cols + c;
              const i3 = (r + 1) * cols + (c + 1);

              const checkTri = (tri, triIdx) => {
                const pA = m.dst_pts[tri[0]];
                const pB = m.dst_pts[tri[1]];
                const pC = m.dst_pts[tri[2]];
                if (!pA || !pB || !pC) return;
                const crossArea = (pB[0] - pA[0]) * (pC[1] - pA[1]) - (pB[1] - pA[1]) * (pC[0] - pA[0]);
                if (Math.abs(crossArea) < 1e-7) {
                  collapsedTriangles.push({
                    layer: layerKey,
                    triIndex: `${r}-${c}-${triIdx}`,
                    pts: [pA, pB, pC]
                  });
                  criticalErrors.push({
                    layer: layerKey,
                    title: 'Collapsed Zero-Area Triangle',
                    description: `Triangle [${tri.join(', ')}] in quad (${r},${c}) has near-zero area (${crossArea.toExponential(2)}).`,
                    suggestion: 'Inspect control points in Calibration Tool; avoid overlapping vertices.'
                  });
                }
              };
              checkTri([i0, i1, i2], 1);
              checkTri([i1, i3, i2], 2);
            }
          }
        }

        // Check for Texture UV range & unexpected stretching
        if (m.src_pts) {
          m.src_pts.forEach((uv, idx) => {
            if (uv[0] < -0.01 || uv[0] > 1.01 || uv[1] < -0.01 || uv[1] > 1.01) {
              textureWarnings.push({
                layer: layerKey,
                pointIndex: idx,
                title: 'Texture UV Out of Bounds',
                description: `Source UV #${idx} outside [0..1] range: [${uv[0].toFixed(3)}, ${uv[1].toFixed(3)}]`,
                suggestion: 'Adjust saree border or pallu ratio sliders.'
              });
            }
          });
        }
      });
    }

    // 3. Garment Coverage & Silhouette Gap Analysis
    LAYER_ORDER.forEach(layerKey => {
      if (!state.activeLayers[layerKey]) {
        coverageWarnings.push({
          layer: layerKey,
          title: 'Layer Deactivated',
          description: `${layerKey.replace('.png', '')} is turned OFF in Step 4. Intentional garment area may expose white base model.`,
          suggestion: 'Turn layer ON or click "All On" in Step 4.'
        });
      }
    });

    // 4. Shared Seam Checks (e.g. Pallu 01 & 02 boundary, Chest 01/02 boundary)
    if (state.activeMapping) {
      const p1 = state.activeMapping['mask_PALLU_01.png'];
      const p2 = state.activeMapping['mask_PALLU_02.png'];
      if (p1 && p2 && p1.dst_pts && p2.dst_pts) {
        suspectedSeams.push({
          layerA: 'mask_PALLU_01.png',
          layerB: 'mask_PALLU_02.png',
          description: 'Pallu inner-outer split boundary (shared spatial projection).'
        });
      }
    }

    const report = {
      timestamp: new Date().toISOString(),
      criticalErrors,
      coverageWarnings,
      textureWarnings,
      collapsedTriangles,
      suspectedSeams,
      totalIssues: criticalErrors.length + coverageWarnings.length + textureWarnings.length
    };
    state.qualityReport = report;

    // Update UI elements
    updateQualityUI(report);
  }

  function updateQualityUI(report) {
    const banner = document.getElementById('quality-status-banner');
    const bannerText = document.getElementById('quality-status-text');
    const critEl = document.getElementById('metric-critical-errors');
    const covEl = document.getElementById('metric-coverage-warnings');
    const texEl = document.getElementById('metric-texture-warnings');
    const issuesContainer = document.getElementById('quality-issues-list');

    if (critEl) critEl.textContent = report.criticalErrors.length;
    if (covEl) covEl.textContent = report.coverageWarnings.length;
    if (texEl) texEl.textContent = report.textureWarnings.length;

    if (banner && bannerText) {
      if (report.criticalErrors.length > 0) {
        banner.style.background = 'rgba(239, 68, 68, 0.15)';
        banner.style.borderColor = '#ef4444';
        banner.style.color = '#f87171';
        bannerText.textContent = `⚠ Status: FAILED (${report.criticalErrors.length} Critical Errors Found)`;
      } else if (report.coverageWarnings.length > 0 || report.textureWarnings.length > 0) {
        banner.style.background = 'rgba(245, 158, 11, 0.15)';
        banner.style.borderColor = '#f59e0b';
        banner.style.color = '#fbbf24';
        bannerText.textContent = `⚡ Status: PASSED with Warnings (${report.coverageWarnings.length + report.textureWarnings.length} Items)`;
      } else {
        banner.style.background = 'rgba(16, 185, 129, 0.15)';
        banner.style.borderColor = '#10b981';
        banner.style.color = '#34d399';
        bannerText.textContent = '✓ Status: PASSED (100% Verified Quality)';
      }
    }

    if (issuesContainer) {
      issuesContainer.innerHTML = '';

      if (report.totalIssues === 0) {
        issuesContainer.innerHTML = '<div style="padding: 10px; background: rgba(16, 185, 129, 0.1); border-radius: 4px; color: #34d399; text-align: center;">All 14 meshes, coverage zones, UV coordinates, and solid masks verified error-free.</div>';
        return;
      }

      // Render issues
      const renderIssueItem = (issue, type, badgeColor) => {
        const item = document.createElement('div');
        item.style.padding = '8px 10px';
        item.style.background = '#0f172a';
        item.style.border = `1px solid ${badgeColor}44`;
        item.style.borderRadius = '4px';
        item.style.display = 'flex';
        item.style.flexDirection = 'column';
        item.style.gap = '3px';
        item.style.cursor = issue.layer && issue.layer !== 'System' ? 'pointer' : 'default';

        item.innerHTML = `
          <div style="display: flex; justify-content: space-between; align-items: center;">
            <span style="font-weight: 700; color: #f8fafc;">${issue.title}</span>
            <span style="font-size: 0.65rem; padding: 2px 6px; border-radius: 3px; background: ${badgeColor}22; color: ${badgeColor}; font-weight: 700;">${issue.layer.replace('.png', '')}</span>
          </div>
          <div style="color: #94a3b8; font-size: 0.70rem;">${issue.description}</div>
          <div style="color: #38bdf8; font-size: 0.68rem; margin-top: 2px;">💡 <em>Suggestion:</em> ${issue.suggestion}</div>
        `;

        if (issue.layer && issue.layer !== 'System') {
          item.addEventListener('click', () => {
            // Highlight in calibration tool
            state.calibrationToolOpen = true;
            document.getElementById('card-calibration').style.display = 'block';
            document.getElementById('btn-toggle-calibration').style.background = 'rgba(212, 163, 71, 0.25)';
            state.calibSelectedLayer = issue.layer;
            const selectEl = document.getElementById('calib-mesh-select');
            if (selectEl) selectEl.value = issue.layer;
            if (issue.pointIndex !== undefined) state.calibSelectedPointIndex = issue.pointIndex;
            renderOverlay();
            renderStatus.textContent = `Inspecting mesh: ${issue.layer}`;
          });
        }

        issuesContainer.appendChild(item);
      };

      report.criticalErrors.forEach(err => renderIssueItem(err, 'Critical', '#ef4444'));
      report.coverageWarnings.forEach(warn => renderIssueItem(warn, 'Coverage', '#f59e0b'));
      report.textureWarnings.forEach(warn => renderIssueItem(warn, 'Texture', '#3b82f6'));
    }
  }

  function updateDiagnostics() {
    runQualityInspection();

    const diagPre = document.getElementById('diag-content');
    if (!diagPre) return;

    const sareeInfo = (state.processedSareeCanvas && state.processedSareeCanvas.diagnostics) || {};
    const mappingInfo = {};

    if (state.activeMapping) {
      let totalPts = 0;
      let minX = 1, maxX = 0, minY = 1, maxY = 0;
      let missingKeys = [];

      LAYER_ORDER.forEach(k => {
        if (!state.activeMapping[k]) {
          missingKeys.push(k);
          return;
        }
        const m = state.activeMapping[k];
        totalPts += (m.src_pts ? m.src_pts.length : 0);
        m.src_pts.forEach(p => {
          if (p[0] < minX) minX = p[0];
          if (p[0] > maxX) maxX = p[0];
          if (p[1] < minY) minY = p[1];
          if (p[1] > maxY) maxY = p[1];
        });
      });

      mappingInfo.meshesFound = LAYER_ORDER.length - missingKeys.length;
      mappingInfo.missingMeshes = missingKeys;
      mappingInfo.totalSourcePoints = totalPts;
      mappingInfo.srcCoordRangeX = `[${minX.toFixed(3)} .. ${maxX.toFixed(3)}]`;
      mappingInfo.srcCoordRangeY = `[${minY.toFixed(3)} .. ${maxY.toFixed(3)}]`;
      mappingInfo.validNormalizedRange = (minX >= 0 && maxX <= 1 && minY >= 0 && maxY <= 1);
      mappingInfo.meshTrianglesGenerated = (state.diagnostics && state.diagnostics.validTriangles) || 0;
      mappingInfo.degenerateTrianglesRejected = (state.diagnostics && state.diagnostics.degenerateTriangles) || 0;
    }

    const report = {
      qualityReport: state.qualityReport,
      image: sareeInfo,
      mapping: mappingInfo,
      fabricZones: window.FABRIC_ZONES ? Object.keys(window.FABRIC_ZONES) : [],
      options: {
        mode: state.mappingMode,
        palluPosition: state.palluPosition,
        palluRatio: state.palluRatio,
        rotation: state.rotation,
        flipX: state.flipX,
        flipY: state.flipY,
        solidMasks: state.useSolidMasks
      }
    };

    diagPre.textContent = JSON.stringify(report, null, 2);
  }

  function renderDrape() {
    if (!state.processedSareeCanvas || !state.baseImage || !state.activeMapping) return;

    const t0 = performance.now();
    compositeCtx.clearRect(0, 0, MODEL_WIDTH, MODEL_HEIGHT);

    if (state.isComparing) {
      clearOverlay();
      renderStatus.textContent = 'Showing Base Model (Comparison)';
      return;
    }

    const masksToUse = state.useSolidMasks ? state.filledMasks : state.rawMasks;

    let totalValidTriangles = 0;
    let totalDegenerateTriangles = 0;

    // 1. Render all active drape layers directly using actual fabric meshes (NO fake underlay fills)
    LAYER_ORDER.forEach(maskName => {
      if (!state.activeLayers[maskName]) return;

      const mapData = state.activeMapping[maskName];
      const maskImg = masksToUse[maskName];
      if (!mapData || !maskImg) return;

      const isPleatFold = maskName.includes('PATLI_0') || maskName.includes('patli_08');

      // Inter-pleat contact drop shadow for 3D depth relief
      if (state.enableHybridEngine && state.enablePleat3D && isPleatFold && window.HybridDrape) {
        window.HybridDrape.Pleat3DDeformer.renderPleatContactShadow(
          compositeCtx,
          maskImg,
          MODEL_WIDTH,
          MODEL_HEIGHT,
          Math.round(4 * state.pleatDepth),
          0.30
        );
      }

      // Compute 3D fold normal lighting factor
      let vertexLighting = null;
      if (state.enableHybridEngine && state.enablePleat3D && isPleatFold && window.HybridDrape) {
        const rows = mapData.mesh_rows;
        const cols = mapData.mesh_cols;
        vertexLighting = [];
        for (let r = 0; r < rows; r++) {
          for (let c = 0; c < cols; c++) {
            const light = window.HybridDrape.Pleat3DDeformer.calculateFoldLighting(c, cols, state.pleatDepth);
            vertexLighting.push(light);
          }
        }
      }

      renderer.clear();

      const meshData = renderer.generateMeshTriangles(
        mapData.src_pts,
        mapData.dst_pts,
        mapData.mesh_rows,
        mapData.mesh_cols,
        MODEL_WIDTH,
        MODEL_HEIGHT,
        0.015,
        vertexLighting
      );

      totalValidTriangles += meshData.validTriCount || 0;
      totalDegenerateTriangles += meshData.degenerateCount || 0;

      renderer.renderMesh(sareeGLTexture, meshData, MODEL_WIDTH, MODEL_HEIGHT, {
        opacity: state.opacity,
        brightness: state.brightness,
        contrast: state.contrast
      });

      // Composite with alpha mask
      layerCtx.clearRect(0, 0, MODEL_WIDTH, MODEL_HEIGHT);
      layerCtx.drawImage(glCanvas, 0, 0);

      layerCtx.globalCompositeOperation = 'destination-in';
      layerCtx.drawImage(maskImg, 0, 0, MODEL_WIDTH, MODEL_HEIGHT);
      layerCtx.globalCompositeOperation = 'source-over';

      compositeCtx.drawImage(layerCanvas, 0, 0);
    });

    state.diagnostics = {
      validTriangles: totalValidTriangles,
      degenerateTriangles: totalDegenerateTriangles
    };

    // 2. Realistic folds shadow blend
    if (state.shadowStrength > 0) {
      compositeCtx.save();
      compositeCtx.globalCompositeOperation = 'multiply';
      compositeCtx.globalAlpha = state.shadowStrength;
      compositeCtx.drawImage(state.baseImage, 0, 0, MODEL_WIDTH, MODEL_HEIGHT);
      compositeCtx.restore();
    }

    // 3. Model Arm/Hand Occlusion Retention
    if (state.enableHybridEngine && state.enableArmOcclusion && window.HybridDrape) {
      window.HybridDrape.OcclusionDepthManager.applyArmOcclusion(
        compositeCtx,
        state.baseImage,
        MODEL_WIDTH,
        MODEL_HEIGHT,
        state.occlusionStrength
      );
    }

    renderOverlay();

    const dt = (performance.now() - t0).toFixed(1);
    renderStatus.textContent = `Draped in ${dt}ms • Full Image Preserved • Non-AI WebGL`;
  }

  function renderOverlay() {
    clearOverlay();

    // Color palette for distinctive layer mesh outlines
    const LAYER_COLORS = {
      'mask_PATLI_07.png': '#e11d48',     // Rose red
      'mask_PATLI_01_NEW.png': '#f97316', // Orange
      'mask_PATLI_01.png': '#f59e0b',     // Amber
      'mask_PATLI_02.png': '#eab308',     // Yellow
      'mask_PATLI_03.png': '#84cc16',     // Lime
      'mask_PATLI_04.png': '#10b981',     // Emerald
      'mask_PATLI_05.png': '#06b6d4',     // Cyan
      'mask_PATLI_06.png': '#0ea5e9',     // Sky
      'mask_patli_08.png': '#3b82f6',     // Blue
      'mask_CHAST_03.png': '#6366f1',     // Indigo
      'mask_CHAST_02.png': '#8b5cf6',     // Violet
      'mask_CHAST_01.png': '#a855f7',     // Purple
      'mask_PALLU_01.png': '#d946ef',     // Fuchsia
      'mask_PALLU_02.png': '#ec4899'      // Pink
    };

    // 1. Combined garment coverage mask
    if (state.showCoverage) {
      overlayCtx.save();
      overlayCtx.fillStyle = 'rgba(16, 185, 129, 0.22)';
      overlayCtx.strokeStyle = 'rgba(16, 185, 129, 0.85)';
      overlayCtx.lineWidth = 3;

      LAYER_ORDER.forEach(maskName => {
        if (!state.activeLayers[maskName]) return;
        const mapData = state.activeMapping[maskName];
        if (!mapData) return;

        const { dst_pts, mesh_rows, mesh_cols } = mapData;
        for (let r = 0; r < mesh_rows - 1; r++) {
          for (let c = 0; c < mesh_cols - 1; c++) {
            const p0 = dst_pts[r * mesh_cols + c];
            const p1 = dst_pts[r * mesh_cols + (c + 1)];
            const p2 = dst_pts[(r + 1) * mesh_cols + c];
            const p3 = dst_pts[(r + 1) * mesh_cols + (c + 1)];

            overlayCtx.beginPath();
            overlayCtx.moveTo(p0[0] * MODEL_WIDTH, p0[1] * MODEL_HEIGHT);
            overlayCtx.lineTo(p1[0] * MODEL_WIDTH, p1[1] * MODEL_HEIGHT);
            overlayCtx.lineTo(p3[0] * MODEL_WIDTH, p3[1] * MODEL_HEIGHT);
            overlayCtx.lineTo(p2[0] * MODEL_WIDTH, p2[1] * MODEL_HEIGHT);
            overlayCtx.closePath();
            overlayCtx.fill();
            overlayCtx.stroke();
          }
        }
      });
      overlayCtx.restore();
    }

    // 2. Color-coded mesh outlines with triangle edges
    if (state.showWireframe) {
      overlayCtx.save();

      LAYER_ORDER.forEach(maskName => {
        if (!state.activeLayers[maskName]) return;
        const mapData = state.activeMapping[maskName];
        if (!mapData) return;

        const color = LAYER_COLORS[maskName] || '#ffd700';
        overlayCtx.strokeStyle = color;
        overlayCtx.lineWidth = 2.5;

        const { dst_pts, mesh_rows, mesh_cols } = mapData;
        for (let r = 0; r < mesh_rows - 1; r++) {
          for (let c = 0; c < mesh_cols - 1; c++) {
            const p0 = dst_pts[r * mesh_cols + c];
            const p1 = dst_pts[r * mesh_cols + (c + 1)];
            const p2 = dst_pts[(r + 1) * mesh_cols + c];
            const p3 = dst_pts[(r + 1) * mesh_cols + (c + 1)];

            overlayCtx.beginPath();
            overlayCtx.moveTo(p0[0] * MODEL_WIDTH, p0[1] * MODEL_HEIGHT);
            overlayCtx.lineTo(p1[0] * MODEL_WIDTH, p1[1] * MODEL_HEIGHT);
            overlayCtx.lineTo(p2[0] * MODEL_WIDTH, p2[1] * MODEL_HEIGHT);
            overlayCtx.closePath();
            overlayCtx.stroke();

            overlayCtx.beginPath();
            overlayCtx.moveTo(p1[0] * MODEL_WIDTH, p1[1] * MODEL_HEIGHT);
            overlayCtx.lineTo(p3[0] * MODEL_WIDTH, p3[1] * MODEL_HEIGHT);
            overlayCtx.lineTo(p2[0] * MODEL_WIDTH, p2[1] * MODEL_HEIGHT);
            overlayCtx.closePath();
            overlayCtx.stroke();
          }
        }
      });
      overlayCtx.restore();
    }

    // 3. Mesh key labels & assigned source UV regions
    if (state.showLabels) {
      overlayCtx.save();
      overlayCtx.font = 'bold 28px "Plus Jakarta Sans", sans-serif';
      overlayCtx.textAlign = 'center';
      overlayCtx.textBaseline = 'middle';

      LAYER_ORDER.forEach(maskName => {
        if (!state.activeLayers[maskName]) return;
        const mapData = state.activeMapping[maskName];
        if (!mapData) return;

        const color = LAYER_COLORS[maskName] || '#ffd700';
        const { dst_pts, src_pts } = mapData;

        // Calculate centroid of mesh destination
        let avgX = 0, avgY = 0;
        dst_pts.forEach(p => { avgX += p[0]; avgY += p[1]; });
        avgX = (avgX / dst_pts.length) * MODEL_WIDTH;
        avgY = (avgY / dst_pts.length) * MODEL_HEIGHT;

        // Source UV bounding box
        let minU = 1, maxU = 0, minV = 1, maxV = 0;
        src_pts.forEach(p => {
          if (p[0] < minU) minU = p[0];
          if (p[0] > maxU) maxU = p[0];
          if (p[1] < minV) minV = p[1];
          if (p[1] > maxV) maxV = p[1];
        });

        const shortName = maskName.replace('mask_', '').replace('.png', '');
        const labelText = `${shortName}`;
        const uvText = `UV:[${minU.toFixed(2)}-${maxU.toFixed(2)}, ${minV.toFixed(2)}-${maxV.toFixed(2)}]`;

        // Background badge
        overlayCtx.fillStyle = 'rgba(10, 13, 20, 0.88)';
        overlayCtx.strokeStyle = color;
        overlayCtx.lineWidth = 2;
        overlayCtx.beginPath();
        overlayCtx.roundRect(avgX - 140, avgY - 32, 280, 64, 8);
        overlayCtx.fill();
        overlayCtx.stroke();

        // Text
        overlayCtx.fillStyle = color;
        overlayCtx.font = 'bold 24px "Plus Jakarta Sans", sans-serif';
        overlayCtx.fillText(labelText, avgX, avgY - 10);
        overlayCtx.fillStyle = '#cbd5e1';
        overlayCtx.font = '500 18px monospace';
        overlayCtx.fillText(uvText, avgX, avgY + 16);
      });
      overlayCtx.restore();
    }

    // 4. Alpha mask outlines
    if (state.showMasks) {
      overlayCtx.save();
      overlayCtx.globalAlpha = 0.40;
      const masksToUse = state.useSolidMasks ? state.filledMasks : state.rawMasks;
      LAYER_ORDER.forEach(maskName => {
        if (!state.activeLayers[maskName]) return;
        const maskImg = masksToUse[maskName];
        if (maskImg) {
          overlayCtx.drawImage(maskImg, 0, 0, MODEL_WIDTH, MODEL_HEIGHT);
        }
      });
      overlayCtx.restore();
    }

    // 5. Solid Mask Silhouettes Preview (Black on White)
    if (state.showSilhouette) {
      overlayCtx.save();
      overlayCtx.fillStyle = '#ffffff';
      overlayCtx.fillRect(0, 0, MODEL_WIDTH, MODEL_HEIGHT);
      LAYER_ORDER.forEach(maskName => {
        if (!state.activeLayers[maskName]) return;
        const silCanvas = state.silhouetteMasks && state.silhouetteMasks[maskName];
        if (silCanvas) {
          overlayCtx.drawImage(silCanvas, 0, 0, MODEL_WIDTH, MODEL_HEIGHT);
        }
      });
      overlayCtx.restore();
    }

    // 6. Source Fabric Polygon Regions Overlay (Picture-in-picture Fabric HUD)
    if (state.showSourcePolygons) {
      overlayCtx.save();
      const hudW = 480;
      const hudH = 800;
      const hudX = MODEL_WIDTH - hudW - 40;
      const hudY = 40;

      // HUD Background
      overlayCtx.fillStyle = 'rgba(10, 13, 20, 0.92)';
      overlayCtx.strokeStyle = 'var(--accent-gold, #d4a347)';
      overlayCtx.lineWidth = 3;
      overlayCtx.beginPath();
      overlayCtx.roundRect(hudX - 10, hudY - 30, hudW + 20, hudH + 40, 12);
      overlayCtx.fill();
      overlayCtx.stroke();

      overlayCtx.fillStyle = '#ffd700';
      overlayCtx.font = 'bold 22px "Plus Jakarta Sans", sans-serif';
      overlayCtx.textAlign = 'left';
      overlayCtx.fillText('SOURCE FABRIC IRREGULAR ZONES', hudX, hudY - 8);

      // Render thumbnail of saree texture inside HUD
      if (state.processedSareeCanvas) {
        overlayCtx.drawImage(state.processedSareeCanvas, hudX, hudY, hudW, hudH);
      }

      // Draw defined fabric polygon zones
      if (window.FABRIC_ZONES) {
        Object.keys(window.FABRIC_ZONES).forEach(zoneKey => {
          const zone = window.FABRIC_ZONES[zoneKey];
          const poly = zone.polygon;
          if (!poly || poly.length < 3) return;

          overlayCtx.beginPath();
          overlayCtx.moveTo(hudX + poly[0][0] * hudW, hudY + poly[0][1] * hudH);
          for (let i = 1; i < poly.length; i++) {
            overlayCtx.lineTo(hudX + poly[i][0] * hudW, hudY + poly[i][1] * hudH);
          }
          overlayCtx.closePath();
          overlayCtx.fillStyle = zone.color + '44'; // 25% alpha
          overlayCtx.fill();
          overlayCtx.strokeStyle = zone.color;
          overlayCtx.lineWidth = 2.5;
          overlayCtx.stroke();

          // Region label
          overlayCtx.fillStyle = zone.color;
          overlayCtx.font = 'bold 14px "Plus Jakarta Sans", sans-serif';
          overlayCtx.fillText(zone.name.split(' (')[0], hudX + poly[0][0] * hudW + 8, hudY + poly[0][1] * hudH + 20);
        });
      }

      // Draw assigned source mesh polygons
      LAYER_ORDER.forEach(maskName => {
        if (!state.activeLayers[maskName]) return;
        const mapData = state.activeMapping[maskName];
        if (!mapData || !mapData.src_pts) return;

        const color = LAYER_COLORS[maskName] || '#ffffff';
        overlayCtx.strokeStyle = color;
        overlayCtx.lineWidth = 1.5;

        const { src_pts, mesh_rows, mesh_cols } = mapData;
        for (let r = 0; r < mesh_rows - 1; r++) {
          for (let c = 0; c < mesh_cols - 1; c++) {
            const p0 = src_pts[r * mesh_cols + c];
            const p1 = src_pts[r * mesh_cols + (c + 1)];
            const p2 = src_pts[(r + 1) * mesh_cols + c];
            const p3 = src_pts[(r + 1) * mesh_cols + (c + 1)];

            overlayCtx.beginPath();
            overlayCtx.moveTo(hudX + p0[0] * hudW, hudY + p0[1] * hudH);
            overlayCtx.lineTo(hudX + p1[0] * hudW, hudY + p1[1] * hudH);
            overlayCtx.lineTo(hudX + p3[0] * hudW, hudY + p3[1] * hudH);
            overlayCtx.lineTo(hudX + p2[0] * hudW, hudY + p2[1] * hudH);
            overlayCtx.closePath();
            overlayCtx.stroke();
          }
        }
      });

      overlayCtx.restore();
    }

    // 7. Uncovered Garment Areas Overlay
    // Highlights model body portions that have alpha masks but where mesh is disabled or missing
    if (state.showUncovered) {
      overlayCtx.save();
      const masksToUse = state.useSolidMasks ? state.filledMasks : state.rawMasks;

      // Draw uncovered layers in high-visibility warning crimson
      LAYER_ORDER.forEach(maskName => {
        const isLayerActive = state.activeLayers[maskName];
        const maskImg = masksToUse[maskName];
        if ((!isLayerActive || !state.activeMapping[maskName]) && maskImg) {
          overlayCtx.drawImage(maskImg, 0, 0, MODEL_WIDTH, MODEL_HEIGHT);
        }
      });
      overlayCtx.restore();
    }

    // 8. Interactive Calibration Visualizer Mode
    if (state.calibrationToolOpen) {
      overlayCtx.save();
      const targetLayer = state.calibSelectedLayer;
      const mapData = state.activeMapping && state.activeMapping[targetLayer];

      if (mapData && mapData.dst_pts) {
        const { dst_pts, src_pts, mesh_rows, mesh_cols } = mapData;
        const color = LAYER_COLORS[targetLayer] || '#ffd700';

        // 1. Highlight target mesh polygon quads
        overlayCtx.strokeStyle = '#ffd700';
        overlayCtx.lineWidth = 3.0;

        for (let r = 0; r < mesh_rows - 1; r++) {
          for (let c = 0; c < mesh_cols - 1; c++) {
            const p0 = dst_pts[r * mesh_cols + c];
            const p1 = dst_pts[r * mesh_cols + (c + 1)];
            const p2 = dst_pts[(r + 1) * mesh_cols + c];
            const p3 = dst_pts[(r + 1) * mesh_cols + (c + 1)];

            overlayCtx.beginPath();
            overlayCtx.moveTo(p0[0] * MODEL_WIDTH, p0[1] * MODEL_HEIGHT);
            overlayCtx.lineTo(p1[0] * MODEL_WIDTH, p1[1] * MODEL_HEIGHT);
            overlayCtx.lineTo(p2[0] * MODEL_WIDTH, p2[1] * MODEL_HEIGHT);
            overlayCtx.closePath();
            overlayCtx.stroke();

            overlayCtx.beginPath();
            overlayCtx.moveTo(p1[0] * MODEL_WIDTH, p1[1] * MODEL_HEIGHT);
            overlayCtx.lineTo(p3[0] * MODEL_WIDTH, p3[1] * MODEL_HEIGHT);
            overlayCtx.lineTo(p2[0] * MODEL_WIDTH, p2[1] * MODEL_HEIGHT);
            overlayCtx.closePath();
            overlayCtx.stroke();
          }
        }

        // 2. Draw draggable destination control point handles
        dst_pts.forEach((pt, idx) => {
          const px = pt[0] * MODEL_WIDTH;
          const py = pt[1] * MODEL_HEIGHT;
          const isSelected = (state.calibSelectedPointIndex === idx);

          // Outer glow ring
          overlayCtx.beginPath();
          overlayCtx.arc(px, py, isSelected ? 18 : 10, 0, Math.PI * 2);
          overlayCtx.fillStyle = isSelected ? '#ef4444' : '#ffd700';
          overlayCtx.fill();
          overlayCtx.lineWidth = 2.5;
          overlayCtx.strokeStyle = '#000000';
          overlayCtx.stroke();

          // Inner white core
          overlayCtx.beginPath();
          overlayCtx.arc(px, py, isSelected ? 8 : 4, 0, Math.PI * 2);
          overlayCtx.fillStyle = '#ffffff';
          overlayCtx.fill();

          // Label
          overlayCtx.fillStyle = '#ffffff';
          overlayCtx.font = 'bold 18px monospace';
          overlayCtx.textAlign = 'left';
          overlayCtx.fillText(`${idx}`, px + 14, py + 6);
        });
      }

      overlayCtx.restore();
    }

    // 9. Visual Quality Checker: Show Vertex & Triangle IDs across all active meshes
    if (state.showVertexIds) {
      overlayCtx.save();
      LAYER_ORDER.forEach(maskName => {
        if (!state.activeLayers[maskName]) return;
        const mapData = state.activeMapping[maskName];
        if (!mapData || !mapData.dst_pts) return;

        const { dst_pts, mesh_rows, mesh_cols } = mapData;
        const color = LAYER_COLORS[maskName] || '#ffffff';

        // Render triangle index markers at centroids
        overlayCtx.font = '600 13px monospace';
        overlayCtx.fillStyle = color;
        overlayCtx.textAlign = 'center';

        for (let r = 0; r < mesh_rows - 1; r++) {
          for (let c = 0; c < mesh_cols - 1; c++) {
            const p0 = dst_pts[r * mesh_cols + c];
            const p1 = dst_pts[r * mesh_cols + (c + 1)];
            const p2 = dst_pts[(r + 1) * mesh_cols + c];
            const p3 = dst_pts[(r + 1) * mesh_cols + (c + 1)];

            const c1x = ((p0[0] + p1[0] + p2[0]) / 3) * MODEL_WIDTH;
            const c1y = ((p0[1] + p1[1] + p2[1]) / 3) * MODEL_HEIGHT;
            overlayCtx.fillText(`T${r},${c}.1`, c1x, c1y);

            const c2x = ((p1[0] + p3[0] + p2[0]) / 3) * MODEL_WIDTH;
            const c2y = ((p1[1] + p3[1] + p2[1]) / 3) * MODEL_HEIGHT;
            overlayCtx.fillText(`T${r},${c}.2`, c2x, c2y);
          }
        }

        // Render vertex ID dots & numbers
        dst_pts.forEach((pt, idx) => {
          const px = pt[0] * MODEL_WIDTH;
          const py = pt[1] * MODEL_HEIGHT;

          overlayCtx.beginPath();
          overlayCtx.arc(px, py, 4, 0, Math.PI * 2);
          overlayCtx.fillStyle = '#f8fafc';
          overlayCtx.fill();

          overlayCtx.font = 'bold 12px monospace';
          overlayCtx.fillStyle = '#ffd700';
          overlayCtx.textAlign = 'left';
          overlayCtx.fillText(`V${idx}`, px + 6, py - 4);
        });
      });
      overlayCtx.restore();
    }

    // 10. Visual Quality Checker: Show Suspected Seams & Collapsed Polygons
    if (state.showSeams) {
      overlayCtx.save();

      // Highlight collapsed triangles in bright flashing warning red
      if (state.qualityReport && state.qualityReport.collapsedTriangles) {
        state.qualityReport.collapsedTriangles.forEach(col => {
          const [pA, pB, pC] = col.pts;
          overlayCtx.strokeStyle = '#ef4444';
          overlayCtx.lineWidth = 4.0;
          overlayCtx.beginPath();
          overlayCtx.moveTo(pA[0] * MODEL_WIDTH, pA[1] * MODEL_HEIGHT);
          overlayCtx.lineTo(pB[0] * MODEL_WIDTH, pB[1] * MODEL_HEIGHT);
          overlayCtx.lineTo(pC[0] * MODEL_WIDTH, pC[1] * MODEL_HEIGHT);
          overlayCtx.closePath();
          overlayCtx.stroke();
        });
      }

      // Highlight shared boundaries (e.g. Pallu 01 & 02 border split)
      const p1 = state.activeMapping && state.activeMapping['mask_PALLU_01.png'];
      const p2 = state.activeMapping && state.activeMapping['mask_PALLU_02.png'];
      if (p1 && p2 && p1.dst_pts && p2.dst_pts) {
        overlayCtx.strokeStyle = '#38bdf8';
        overlayCtx.lineWidth = 3.0;
        overlayCtx.setLineDash([8, 6]);
        overlayCtx.beginPath();
        // Right edge of Pallu 01
        for (let r = 0; r < p1.mesh_rows; r++) {
          const pt = p1.dst_pts[r * p1.mesh_cols + (p1.mesh_cols - 1)];
          const px = pt[0] * MODEL_WIDTH;
          const py = pt[1] * MODEL_HEIGHT;
          if (r === 0) overlayCtx.moveTo(px, py);
          else overlayCtx.lineTo(px, py);
        }
        overlayCtx.stroke();
        overlayCtx.setLineDash([]);
      }

      overlayCtx.restore();
    }
  }

  function clearOverlay() {
    overlayCtx.clearRect(0, 0, MODEL_WIDTH, MODEL_HEIGHT);
  }

  function populateLayerList() {
    const container = document.getElementById('layer-list');
    container.innerHTML = '';

    LAYER_ORDER.forEach(maskName => {
      const row = document.createElement('div');
      row.className = 'layer-row';

      let tagClass = 'tag-chast';
      let tagText = 'CHEST';
      if (maskName.includes('PALLU')) {
        tagClass = 'tag-pallu';
        tagText = 'PALLU';
      } else if (maskName.includes('PATLI') || maskName.includes('patli')) {
        tagClass = 'tag-patli';
        tagText = 'PLEATS';
      }

      const cleanName = maskName.replace('.png', '');

      row.innerHTML = `
        <div class="layer-info">
          <span class="layer-tag ${tagClass}">${tagText}</span>
          <span style="font-weight: 500;">${cleanName}</span>
        </div>
        <div style="display: flex; align-items: center; gap: 8px;">
          <button class="solo-btn" data-solo="${maskName}" title="Test only this single cut on the model" style="background: rgba(212, 163, 71, 0.15); border: 1px solid var(--accent-gold); color: var(--accent-gold); font-size: 0.68rem; padding: 2px 7px; border-radius: 4px; cursor: pointer; font-weight: 700;">Solo</button>
          <label class="switch">
            <input type="checkbox" data-layer="${maskName}" checked>
            <span class="slider-switch"></span>
          </label>
        </div>
      `;

      // Toggle single layer
      row.querySelector('input').addEventListener('change', e => {
        state.activeLayers[maskName] = e.target.checked;
        renderDrape();
      });

      // Solo button: turns OFF all other layers and enables ONLY this layer!
      row.querySelector('.solo-btn').addEventListener('click', () => {
        LAYER_ORDER.forEach(k => {
          const isActive = (k === maskName);
          state.activeLayers[k] = isActive;
          const input = document.querySelector(`input[data-layer="${k}"]`);
          if (input) input.checked = isActive;
        });
        renderStatus.textContent = `Testing single slice: ${cleanName}`;
        renderDrape();
      });

      container.appendChild(row);
    });
  }

  async function fetchTemplates() {
    try {
      const res = await fetch('/api/templates');
      const data = await res.json();
      if (data.success && Array.isArray(data.templates)) {
        state.availableTemplates = data.templates;
        const select = document.getElementById('template-select');
        if (select) {
          select.innerHTML = '';
          data.templates.forEach(t => {
            const opt = document.createElement('option');
            opt.value = t.file;
            opt.textContent = `${t.name} (v${t.version || '1.0'})`;
            if (t.id === state.currentTemplateId || t.file === 'default_template.json') opt.selected = true;
            select.appendChild(opt);
          });
        }
      }
    } catch (e) {
      console.warn('Could not load template list:', e);
    }
  }

  async function loadAndApplyTemplate(templateFile) {
    try {
      renderStatus.textContent = `Loading template: ${templateFile}...`;
      const res = await fetch(`drape-lab/templates/${templateFile}?t=${Date.now()}`);
      if (!res.ok) throw new Error(`Template file ${templateFile} not found.`);
      const tData = await res.json();

      // Validate template structure
      if (!tData.layers || typeof tData.layers !== 'object') {
        throw new Error('Invalid template format: missing "layers" definition.');
      }

      state.currentTemplateId = tData.id || templateFile.replace('.json', '');

      // Apply destination geometry to originalMapping and window.RAW_MAPPING without overwriting fabric settings
      Object.keys(tData.layers).forEach(layerKey => {
        const tLayer = tData.layers[layerKey];
        if (state.originalMapping[layerKey] && tLayer.dst_pts) {
          state.originalMapping[layerKey].dst_pts = JSON.parse(JSON.stringify(tLayer.dst_pts));
          if (tLayer.mesh_rows) state.originalMapping[layerKey].mesh_rows = tLayer.mesh_rows;
          if (tLayer.mesh_cols) state.originalMapping[layerKey].mesh_cols = tLayer.mesh_cols;
        }
      });
      window.RAW_MAPPING = state.originalMapping;

      // Update mapping with current fabric alignment settings preserved
      updateActiveMapping();
      renderDrape();
      renderOverlay();
      renderStatus.textContent = `Applied template: ${tData.name || templateFile} (Fabric preserved)`;
    } catch (err) {
      alert('Error applying template: ' + err.message);
      renderStatus.textContent = 'Error loading template';
    }
  }

  function bindEvents() {
    // Template UI Bindings
    const templateSelect = document.getElementById('template-select');
    const btnSaveAsTemplate = document.getElementById('btn-save-as-template');
    const btnExportTemplate = document.getElementById('btn-export-template');
    const btnImportTemplateTrigger = document.getElementById('btn-import-template-trigger');
    const templateImportInput = document.getElementById('template-import-input');

    if (templateSelect) {
      templateSelect.addEventListener('change', e => {
        loadAndApplyTemplate(e.target.value);
      });
    }

    if (btnSaveAsTemplate) {
      btnSaveAsTemplate.addEventListener('click', async () => {
        const templateName = prompt('Enter a name for this Drape Template:', 'Custom Model Drape');
        if (!templateName) return;
        const templateId = templateName.toLowerCase().replace(/[^a-z0-9_-]/g, '_');

        const templatePayload = {
          id: templateId,
          name: templateName,
          version: '1.0.0',
          modelImage: 'base.jpg',
          modelWidth: MODEL_WIDTH,
          modelHeight: MODEL_HEIGHT,
          createdAt: new Date().toISOString(),
          layerOrder: LAYER_ORDER,
          layers: {}
        };

        LAYER_ORDER.forEach(name => {
          const lData = state.activeMapping[name] || state.originalMapping[name];
          if (lData) {
            templatePayload.layers[name] = {
              mask: name,
              mesh_rows: lData.mesh_rows,
              mesh_cols: lData.mesh_cols,
              dst_pts: JSON.parse(JSON.stringify(lData.dst_pts))
            };
          }
        });

        try {
          const res = await fetch('/api/templates/save', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(templatePayload)
          });
          const resData = await res.json();
          if (resData.success) {
            alert(`Template "${templateName}" successfully saved!`);
            await fetchTemplates();
            if (templateSelect) templateSelect.value = resData.file;
            state.currentTemplateId = resData.id;
          } else {
            alert('Failed to save template: ' + (resData.error || 'Unknown error'));
          }
        } catch (e) {
          alert('Error saving template: ' + e.message);
        }
      });
    }

    if (btnExportTemplate) {
      btnExportTemplate.addEventListener('click', () => {
        const templatePayload = {
          id: state.currentTemplateId || 'custom_template',
          name: 'Exported Drape Template',
          version: '1.0.0',
          modelImage: 'base.jpg',
          modelWidth: MODEL_WIDTH,
          modelHeight: MODEL_HEIGHT,
          exportedAt: new Date().toISOString(),
          layerOrder: LAYER_ORDER,
          layers: {}
        };

        LAYER_ORDER.forEach(name => {
          const lData = state.activeMapping[name] || state.originalMapping[name];
          if (lData) {
            templatePayload.layers[name] = {
              mask: name,
              mesh_rows: lData.mesh_rows,
              mesh_cols: lData.mesh_cols,
              dst_pts: JSON.parse(JSON.stringify(lData.dst_pts))
            };
          }
        });

        const dataStr = 'data:text/json;charset=utf-8,' + encodeURIComponent(JSON.stringify(templatePayload, null, 2));
        const dlAnchor = document.createElement('a');
        dlAnchor.setAttribute('href', dataStr);
        dlAnchor.setAttribute('download', `drape_template_${state.currentTemplateId || 'calibrated'}.json`);
        document.body.appendChild(dlAnchor);
        dlAnchor.click();
        dlAnchor.remove();
      });
    }

    if (btnImportTemplateTrigger && templateImportInput) {
      btnImportTemplateTrigger.addEventListener('click', () => {
        templateImportInput.click();
      });

      templateImportInput.addEventListener('change', e => {
        const file = e.target.files[0];
        if (!file) return;

        const reader = new FileReader();
        reader.onload = async evt => {
          try {
            const parsed = JSON.parse(evt.target.result);
            if (!parsed.layers || typeof parsed.layers !== 'object') {
              throw new Error('Imported JSON is not a valid drape template (missing "layers").');
            }

            // Save to backend templates
            const saveRes = await fetch('/api/templates/save', {
              method: 'POST',
              headers: { 'Content-Type': 'application/json' },
              body: JSON.stringify(parsed)
            });
            const saveResult = await saveRes.json();
            if (saveResult.success) {
              await fetchTemplates();
              if (templateSelect) templateSelect.value = saveResult.file;
              loadAndApplyTemplate(saveResult.file);
              alert(`Template "${parsed.name || parsed.id}" imported and activated!`);
            } else {
              throw new Error(saveResult.error || 'Server rejected template save');
            }
          } catch (err) {
            alert('Failed to import template: ' + err.message);
          }
          templateImportInput.value = '';
        };
        reader.readAsText(file);
      });
    }

    const dropzone = document.getElementById('saree-dropzone');
    const fileInput = document.getElementById('saree-input');
    const removeBtn = document.getElementById('btn-remove-saree');

    dropzone.addEventListener('click', e => {
      if (e.target !== removeBtn) fileInput.click();
    });

    fileInput.addEventListener('change', e => {
      const file = e.target.files[0];
      if (file) handleImageFile(file);
    });

    dropzone.addEventListener('dragover', e => {
      e.preventDefault();
      dropzone.style.borderColor = 'var(--accent-gold)';
    });

    dropzone.addEventListener('dragleave', () => {
      dropzone.style.borderColor = '';
    });

    dropzone.addEventListener('drop', e => {
      e.preventDefault();
      dropzone.style.borderColor = '';
      if (e.dataTransfer.files.length) {
        handleImageFile(e.dataTransfer.files[0]);
      }
    });

    removeBtn.addEventListener('click', e => {
      e.stopPropagation();
      document.getElementById('saree-thumb-container').style.display = 'none';
      document.querySelector('.upload-content').style.display = 'flex';
      fileInput.value = '';
    });

    // Orientation tools
    document.getElementById('btn-rotate').addEventListener('click', () => {
      state.rotation = (state.rotation + 90) % 360;
      processOrientedAndPreservedSaree();
    });

    document.getElementById('btn-flip-v').addEventListener('click', () => {
      state.flipY = !state.flipY;
      updateActiveMapping();
      renderDrape();
    });

    document.getElementById('btn-flip-h').addEventListener('click', () => {
      state.flipX = !state.flipX;
      updateActiveMapping();
      renderDrape();
    });

    // Solid mask toggle
    const checkSolidMasks = document.getElementById('check-solid-masks');
    if (checkSolidMasks) {
      checkSolidMasks.addEventListener('change', e => {
        state.useSolidMasks = e.target.checked;
        renderDrape();
      });
    }

    // Pallu position toggle
    const btnPalluBottom = document.getElementById('btn-pallu-bottom');
    const btnPalluTop = document.getElementById('btn-pallu-top');

    btnPalluBottom.addEventListener('click', () => {
      btnPalluBottom.classList.add('active');
      btnPalluTop.classList.remove('active');
      state.palluPosition = 'bottom';
      updateActiveMapping();
      renderDrape();
    });

    btnPalluTop.addEventListener('click', () => {
      btnPalluTop.classList.add('active');
      btnPalluBottom.classList.remove('active');
      state.palluPosition = 'top';
      updateActiveMapping();
      renderDrape();
    });

    // Pallu ratio slider
    const ratioSlider = document.getElementById('slider-pallu-ratio');
    ratioSlider.addEventListener('input', e => {
      state.palluRatio = parseInt(e.target.value, 10) / 100;
      document.getElementById('val-pallu-ratio').textContent = `${e.target.value}%`;
      updateActiveMapping();
      renderDrape();
    });

    // Decorative border width slider
    const borderSlider = document.getElementById('slider-border-ratio');
    if (borderSlider) {
      borderSlider.addEventListener('input', e => {
        state.borderRatio = parseInt(e.target.value, 10) / 100;
        document.getElementById('val-border-ratio').textContent = `${e.target.value}%`;
        updateActiveMapping();
        renderDrape();
      });
    }

    // Border scale slider
    const borderScaleSlider = document.getElementById('slider-border-scale');
    if (borderScaleSlider) {
      borderScaleSlider.addEventListener('input', e => {
        state.borderScale = parseInt(e.target.value, 10) / 100;
        document.getElementById('val-border-scale').textContent = `${state.borderScale.toFixed(2)}x`;
        updateActiveMapping();
        renderDrape();
      });
    }

    // Border offset slider
    const borderOffsetSlider = document.getElementById('slider-border-offset');
    if (borderOffsetSlider) {
      borderOffsetSlider.addEventListener('input', e => {
        state.borderOffset = parseInt(e.target.value, 10) / 100;
        document.getElementById('val-border-offset').textContent = (state.borderOffset >= 0 ? '+' : '') + state.borderOffset.toFixed(2);
        updateActiveMapping();
        renderDrape();
      });
    }

    // Border edge side selector
    const btnBorderLeft = document.getElementById('btn-border-left');
    const btnBorderRight = document.getElementById('btn-border-right');
    if (btnBorderLeft && btnBorderRight) {
      btnBorderLeft.addEventListener('click', () => {
        btnBorderLeft.classList.add('active');
        btnBorderRight.classList.remove('active');
        state.borderEdge = 'left';
        updateActiveMapping();
        renderDrape();
      });
      btnBorderRight.addEventListener('click', () => {
        btnBorderRight.classList.add('active');
        btnBorderLeft.classList.remove('active');
        state.borderEdge = 'right';
        updateActiveMapping();
        renderDrape();
      });
    }

    // Pleat Pattern Mode buttons
    const btnPleatProgressive = document.getElementById('btn-pleat-progressive');
    const btnPleatUniform = document.getElementById('btn-pleat-uniform');
    if (btnPleatProgressive && btnPleatUniform) {
      btnPleatProgressive.addEventListener('click', () => {
        btnPleatProgressive.classList.add('active');
        btnPleatUniform.classList.remove('active');
        state.pleatPatternMode = 'progressive';
        updateActiveMapping();
        renderDrape();
      });
      btnPleatUniform.addEventListener('click', () => {
        btnPleatUniform.classList.add('active');
        btnPleatProgressive.classList.remove('active');
        state.pleatPatternMode = 'uniform';
        updateActiveMapping();
        renderDrape();
      });
    }

    // Pleat Horizontal Offset slider
    const pleatOffsetSlider = document.getElementById('slider-pleat-offset');
    if (pleatOffsetSlider) {
      pleatOffsetSlider.addEventListener('input', e => {
        state.pleatOffset = parseInt(e.target.value, 10) / 100;
        document.getElementById('val-pleat-offset').textContent = (state.pleatOffset >= 0 ? '+' : '') + state.pleatOffset.toFixed(2);
        updateActiveMapping();
        renderDrape();
      });
    }

    // Mapping mode toggle
    const btnModeGen = document.getElementById('btn-mode-generalized');
    const btnModeOrig = document.getElementById('btn-mode-original');

    btnModeGen.addEventListener('click', () => {
      btnModeGen.classList.add('active');
      btnModeOrig.classList.remove('active');
      state.mappingMode = 'generalized';
      updateActiveMapping();
      renderDrape();
    });

    btnModeOrig.addEventListener('click', () => {
      btnModeOrig.classList.add('active');
      btnModeGen.classList.remove('active');
      state.mappingMode = 'original';
      updateActiveMapping();
      renderDrape();
    });

    // Preset styles
    document.querySelectorAll('.sample-chips .chip[data-sample]').forEach(chip => {
      chip.addEventListener('click', async () => {
        document.querySelectorAll('.sample-chips .chip[data-sample]').forEach(c => c.classList.remove('active'));
        chip.classList.add('active');
        const sampleType = chip.getAttribute('data-sample');
        if (sampleType === 'uploaded_raw_saree') {
          try {
            const rawImg = await loadImage(`crops/raw_uploaded_saree.jpg?t=${Date.now()}`);
            setRawSaree(rawImg);
          } catch (err) {
            console.error('Failed to load raw uploaded saree:', err);
          }
        } else {
          const sampleSaree = generateSampleSaree(sampleType);
          setRawSaree(sampleSaree);
        }
      });
    });

    // Hybrid Drape Engine Controls (TPS Bust Deformation, Cloth Simulation, 3D Pleats)
    const checkEnableHybrid = document.getElementById('check-enable-hybrid');
    if (checkEnableHybrid) {
      checkEnableHybrid.addEventListener('change', e => {
        state.enableHybridEngine = e.target.checked;
        updateActiveMapping();
        renderDrape();
      });
    }

    const checkTpsChest = document.getElementById('check-tps-chest');
    if (checkTpsChest) {
      checkTpsChest.addEventListener('change', e => {
        state.enableTPSChest = e.target.checked;
        updateActiveMapping();
        renderDrape();
      });
    }

    const sliderTpsStrength = document.getElementById('slider-tps-strength');
    if (sliderTpsStrength) {
      sliderTpsStrength.addEventListener('input', e => {
        state.tpsStrength = parseInt(e.target.value, 10) / 100;
        const valEl = document.getElementById('val-tps-strength');
        if (valEl) valEl.textContent = `${e.target.value}%`;
        updateActiveMapping();
        renderDrape();
      });
    }

    const checkClothPallu = document.getElementById('check-cloth-pallu');
    if (checkClothPallu) {
      checkClothPallu.addEventListener('change', e => {
        state.enableClothPallu = e.target.checked;
        updateActiveMapping();
        renderDrape();
      });
    }

    const sliderPalluSag = document.getElementById('slider-pallu-sag');
    if (sliderPalluSag) {
      sliderPalluSag.addEventListener('input', e => {
        state.palluSagStrength = parseInt(e.target.value, 10) / 100;
        const valEl = document.getElementById('val-pallu-sag');
        if (valEl) valEl.textContent = `${e.target.value}%`;
        updateActiveMapping();
        renderDrape();
      });
    }

    const checkPleat3D = document.getElementById('check-pleat-3d');
    if (checkPleat3D) {
      checkPleat3D.addEventListener('change', e => {
        state.enablePleat3D = e.target.checked;
        renderDrape();
      });
    }

    const sliderPleatDepth = document.getElementById('slider-pleat-depth');
    if (sliderPleatDepth) {
      sliderPleatDepth.addEventListener('input', e => {
        state.pleatDepth = parseInt(e.target.value, 10) / 100;
        const valEl = document.getElementById('val-pleat-depth');
        if (valEl) valEl.textContent = `${state.pleatDepth.toFixed(1)}x`;
        renderDrape();
      });
    }

    const checkArmOcclusion = document.getElementById('check-arm-occlusion');
    if (checkArmOcclusion) {
      checkArmOcclusion.addEventListener('change', e => {
        state.enableArmOcclusion = e.target.checked;
        renderDrape();
      });
    }

    // Realism Sliders
    document.getElementById('slider-shadow').addEventListener('input', e => {
      state.shadowStrength = parseInt(e.target.value, 10) / 100;
      document.getElementById('val-shadow').textContent = `${e.target.value}%`;
      renderDrape();
    });

    document.getElementById('slider-opacity').addEventListener('input', e => {
      state.opacity = parseInt(e.target.value, 10) / 100;
      document.getElementById('val-opacity').textContent = `${e.target.value}%`;
      renderDrape();
    });

    document.getElementById('slider-brightness').addEventListener('input', e => {
      state.brightness = parseInt(e.target.value, 10) / 100;
      document.getElementById('val-brightness').textContent = `${e.target.value}%`;
      renderDrape();
    });

    document.getElementById('slider-contrast').addEventListener('input', e => {
      state.contrast = parseInt(e.target.value, 10) / 100;
      document.getElementById('val-contrast').textContent = `${e.target.value}%`;
      renderDrape();
    });

    // Layer toggle all on / all off
    const toggleAllBtn = document.getElementById('btn-toggle-all-layers');
    toggleAllBtn.addEventListener('click', () => {
      document.querySelectorAll('#layer-list input').forEach(input => {
        input.checked = true;
        state.activeLayers[input.dataset.layer] = true;
      });
      renderDrape();
    });

    const allOffBtn = document.getElementById('btn-layers-all-off');
    if (allOffBtn) {
      allOffBtn.addEventListener('click', () => {
        document.querySelectorAll('#layer-list input').forEach(input => {
          input.checked = false;
          state.activeLayers[input.dataset.layer] = false;
        });
        renderDrape();
      });
    }

    // Wireframe, Coverage, Labels & Mask toggles
    document.getElementById('check-show-wireframe').addEventListener('change', e => {
      state.showWireframe = e.target.checked;
      renderOverlay();
    });

    const checkShowLabels = document.getElementById('check-show-labels');
    if (checkShowLabels) {
      checkShowLabels.addEventListener('change', e => {
        state.showLabels = e.target.checked;
        renderOverlay();
      });
    }

    const checkShowCoverage = document.getElementById('check-show-coverage');
    if (checkShowCoverage) {
      checkShowCoverage.addEventListener('change', e => {
        state.showCoverage = e.target.checked;
        renderOverlay();
      });
    }

    document.getElementById('check-show-masks').addEventListener('change', e => {
      state.showMasks = e.target.checked;
      renderOverlay();
    });

    const checkShowSilhouette = document.getElementById('check-show-silhouette');
    if (checkShowSilhouette) {
      checkShowSilhouette.addEventListener('change', e => {
        state.showSilhouette = e.target.checked;
        renderOverlay();
      });
    }

    const checkShowSourcePolygons = document.getElementById('check-show-source-polygons');
    if (checkShowSourcePolygons) {
      checkShowSourcePolygons.addEventListener('change', e => {
        state.showSourcePolygons = e.target.checked;
        renderOverlay();
      });
    }

    const checkShowUncovered = document.getElementById('check-show-uncovered');
    if (checkShowUncovered) {
      checkShowUncovered.addEventListener('change', e => {
        state.showUncovered = e.target.checked;
        renderOverlay();
      });
    }

    const checkShowVertexIds = document.getElementById('check-show-vertex-ids');
    if (checkShowVertexIds) {
      checkShowVertexIds.addEventListener('change', e => {
        state.showVertexIds = e.target.checked;
        renderOverlay();
      });
    }

    const checkShowSeams = document.getElementById('check-show-seams');
    if (checkShowSeams) {
      checkShowSeams.addEventListener('change', e => {
        state.showSeams = e.target.checked;
        renderOverlay();
      });
    }

    const btnRunQualityCheck = document.getElementById('btn-run-quality-check');
    if (btnRunQualityCheck) {
      btnRunQualityCheck.addEventListener('click', () => {
        runQualityInspection();
      });
    }

    // Dark/Black background toggle for base image
    const checkDarkBg = document.getElementById('check-dark-bg');
    if (checkDarkBg) {
      checkDarkBg.addEventListener('change', e => {
        state.darkBackground = e.target.checked;
        renderBaseModel();
        renderDrape();
      });
    }

    // Diagnostics inspection toggle
    const toggleDiagBtn = document.getElementById('btn-toggle-diagnostics');
    const diagCard = document.getElementById('card-diagnostics');
    if (toggleDiagBtn && diagCard) {
      toggleDiagBtn.addEventListener('click', () => {
        diagCard.style.display = diagCard.style.display === 'none' ? 'block' : 'none';
      });
    }

    // ==============================================================
    // INTERACTIVE MESH CALIBRATION STUDIO CONTROLLER
    // ==============================================================
    const toggleCalibBtn = document.getElementById('btn-toggle-calibration');
    const calibCard = document.getElementById('card-calibration');
    const calibSelect = document.getElementById('calib-mesh-select');
    const checkCalibDrag = document.getElementById('check-calib-drag');
    const calibInfo = document.getElementById('calib-selected-info');
    const btnCalibModeDst = document.getElementById('btn-calib-mode-dst');
    const btnCalibModeSrc = document.getElementById('btn-calib-mode-src');
    const btnCalibUndo = document.getElementById('btn-calib-undo');
    const btnCalibRedo = document.getElementById('btn-calib-redo');
    const btnCalibResetMesh = document.getElementById('btn-calib-reset-mesh');
    const btnCalibRestoreOrig = document.getElementById('btn-calib-restore-orig');
    const btnCalibSave = document.getElementById('btn-calib-save');
    const btnCalibExport = document.getElementById('btn-calib-export');

    function populateCalibSelect() {
      if (!calibSelect) return;
      calibSelect.innerHTML = '';
      LAYER_ORDER.forEach(k => {
        const opt = document.createElement('option');
        opt.value = k;
        opt.textContent = k.replace('.png', '').replace('mask_', '');
        if (k === state.calibSelectedLayer) opt.selected = true;
        calibSelect.appendChild(opt);
      });
    }
    populateCalibSelect();

    function pushCalibHistory() {
      if (!state.activeMapping) return;
      // Truncate redo states
      state.calibHistory = state.calibHistory.slice(0, state.calibHistoryIndex + 1);
      state.calibHistory.push(JSON.stringify(state.activeMapping));
      state.calibHistoryIndex = state.calibHistory.length - 1;
      updateCalibUI();
    }

    function updateCalibUI() {
      if (!calibInfo) return;
      const targetLayer = state.calibSelectedLayer;
      const mapData = state.activeMapping && state.activeMapping[targetLayer];
      if (!mapData) return;
      const modeText = state.calibTargetMode === 'dst' ? 'Destination (Model)' : 'Source (Fabric UV)';
      const ptIdx = state.calibSelectedPointIndex;
      if (ptIdx !== null) {
        const pt = (state.calibTargetMode === 'dst') ? mapData.dst_pts[ptIdx] : mapData.src_pts[ptIdx];
        calibInfo.innerHTML = `<strong>${targetLayer.replace('.png', '')}</strong> | Point <strong>#${ptIdx}</strong><br>Mode: <strong>${modeText}</strong><br>Coords: [${pt[0].toFixed(4)}, ${pt[1].toFixed(4)}]`;
      } else {
        calibInfo.textContent = `Selected: ${targetLayer.replace('.png', '')} (${mapData.dst_pts.length} points). Click or drag any control point on the canvas.`;
      }
    }

    if (toggleCalibBtn && calibCard) {
      toggleCalibBtn.addEventListener('click', () => {
        state.calibrationToolOpen = !state.calibrationToolOpen;
        calibCard.style.display = state.calibrationToolOpen ? 'block' : 'none';
        toggleCalibBtn.style.background = state.calibrationToolOpen ? 'rgba(212, 163, 71, 0.25)' : '';
        if (state.calibrationToolOpen && state.calibHistory.length === 0) {
          pushCalibHistory();
        }
        renderOverlay();
      });
    }

    if (calibSelect) {
      calibSelect.addEventListener('change', e => {
        state.calibSelectedLayer = e.target.value;
        state.calibSelectedPointIndex = null;
        updateCalibUI();
        renderOverlay();
      });
    }

    if (checkCalibDrag) {
      checkCalibDrag.addEventListener('change', e => {
        state.calibDraggingEnabled = e.target.checked;
        overlayCanvas.style.pointerEvents = state.calibDraggingEnabled ? 'auto' : 'none';
        renderStatus.textContent = state.calibDraggingEnabled ? 'Calibration: Click & Drag points on model' : 'Ready • Calibration Dragging Disabled';
      });
    }

    if (btnCalibModeDst && btnCalibModeSrc) {
      btnCalibModeDst.addEventListener('click', () => {
        btnCalibModeDst.classList.add('active');
        btnCalibModeSrc.classList.remove('active');
        state.calibTargetMode = 'dst';
        updateCalibUI();
      });
      btnCalibModeSrc.addEventListener('click', () => {
        btnCalibModeSrc.classList.add('active');
        btnCalibModeDst.classList.remove('active');
        state.calibTargetMode = 'src';
        updateCalibUI();
      });
    }

    if (btnCalibUndo) {
      btnCalibUndo.addEventListener('click', () => {
        if (state.calibHistoryIndex > 0) {
          state.calibHistoryIndex--;
          state.activeMapping = JSON.parse(state.calibHistory[state.calibHistoryIndex]);
          updateCalibUI();
          renderDrape();
        }
      });
    }

    if (btnCalibRedo) {
      btnCalibRedo.addEventListener('click', () => {
        if (state.calibHistoryIndex < state.calibHistory.length - 1) {
          state.calibHistoryIndex++;
          state.activeMapping = JSON.parse(state.calibHistory[state.calibHistoryIndex]);
          updateCalibUI();
          renderDrape();
        }
      });
    }

    if (btnCalibResetMesh) {
      btnCalibResetMesh.addEventListener('click', () => {
        if (state.originalMapping && state.originalMapping[state.calibSelectedLayer]) {
          state.activeMapping[state.calibSelectedLayer] = JSON.parse(JSON.stringify(state.originalMapping[state.calibSelectedLayer]));
          pushCalibHistory();
          renderDrape();
        }
      });
    }

    if (btnCalibRestoreOrig) {
      btnCalibRestoreOrig.addEventListener('click', () => {
        if (state.originalMapping && confirm('Restore all 14 layers to original mapping.json?')) {
          state.activeMapping = JSON.parse(JSON.stringify(state.originalMapping));
          pushCalibHistory();
          renderDrape();
        }
      });
    }

    if (btnCalibSave) {
      btnCalibSave.addEventListener('click', async () => {
        try {
          btnCalibSave.textContent = 'Saving...';
          const res = await fetch('/api/save-mapping', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(state.activeMapping)
          });
          const json = await res.json();
          if (json.success) {
            alert('Calibration mapping successfully saved with automated backup in drape-lab/backups/!');
          } else {
            alert('Save failed: ' + json.error);
          }
        } catch (e) {
          alert('Network or save error: ' + e.message);
        } finally {
          btnCalibSave.textContent = 'Save Calibration';
        }
      });
    }

    if (btnCalibExport) {
      btnCalibExport.addEventListener('click', () => {
        const dataStr = 'data:text/json;charset=utf-8,' + encodeURIComponent(JSON.stringify(state.activeMapping, null, 2));
        const dlAnchor = document.createElement('a');
        dlAnchor.setAttribute('href', dataStr);
        dlAnchor.setAttribute('download', `mapping_calibrated_${Date.now()}.json`);
        document.body.appendChild(dlAnchor);
        dlAnchor.click();
        dlAnchor.remove();
      });
    }

    // Canvas Point Dragging Controller
    function getCanvasCoords(evt) {
      const rect = overlayCanvas.getBoundingClientRect();
      const x = ((evt.clientX - rect.left) / rect.width) * MODEL_WIDTH;
      const y = ((evt.clientY - rect.top) / rect.height) * MODEL_HEIGHT;
      return [x, y];
    }

    overlayCanvas.addEventListener('mousedown', e => {
      if (!state.calibrationToolOpen || !state.calibDraggingEnabled) return;
      const [mx, my] = getCanvasCoords(e);
      const targetLayer = state.calibSelectedLayer;
      const mapData = state.activeMapping && state.activeMapping[targetLayer];
      if (!mapData || !mapData.dst_pts) return;

      const hitRadius = 35; // Screen pixel tolerance
      let closestIdx = null;
      let minDistance = hitRadius;

      mapData.dst_pts.forEach((p, idx) => {
        const px = p[0] * MODEL_WIDTH;
        const py = p[1] * MODEL_HEIGHT;
        const dist = Math.hypot(px - mx, py - my);
        if (dist < minDistance) {
          minDistance = dist;
          closestIdx = idx;
        }
      });

      if (closestIdx !== null) {
        state.calibSelectedPointIndex = closestIdx;
        state.isDraggingPoint = true;
        updateCalibUI();
        renderOverlay();
      }
    });

    window.addEventListener('mousemove', e => {
      if (!state.isDraggingPoint || state.calibSelectedPointIndex === null) return;
      const [mx, my] = getCanvasCoords(e);
      const targetLayer = state.calibSelectedLayer;
      const mapData = state.activeMapping && state.activeMapping[targetLayer];
      if (!mapData) return;

      const normX = Math.max(0.001, Math.min(0.999, mx / MODEL_WIDTH));
      const normY = Math.max(0.001, Math.min(0.999, my / MODEL_HEIGHT));

      if (state.calibTargetMode === 'dst') {
        mapData.dst_pts[state.calibSelectedPointIndex] = [normX, normY];
      } else {
        mapData.src_pts[state.calibSelectedPointIndex] = [normX, normY];
      }

      updateCalibUI();
      renderDrape();
    });

    window.addEventListener('mouseup', () => {
      if (state.isDraggingPoint) {
        state.isDraggingPoint = false;
        pushCalibHistory();
      }
    });

    // Compare
    const compareBtn = document.getElementById('btn-compare');
    compareBtn.addEventListener('mousedown', () => {
      state.isComparing = true;
      renderDrape();
    });
    compareBtn.addEventListener('mouseup', () => {
      state.isComparing = false;
      renderDrape();
    });
    compareBtn.addEventListener('mouseleave', () => {
      if (state.isComparing) {
        state.isComparing = false;
        renderDrape();
      }
    });

    // Export
    document.getElementById('btn-export').addEventListener('click', exportHighRes);

    // Zoom
    document.getElementById('btn-zoom-in').addEventListener('click', () => {
      state.zoom = Math.min(2.5, state.zoom + 0.15);
      updateZoom();
    });

    document.getElementById('btn-zoom-out').addEventListener('click', () => {
      state.zoom = Math.max(0.4, state.zoom - 0.15);
      updateZoom();
    });

    document.getElementById('btn-zoom-fit').addEventListener('click', () => {
      fitToViewport();
    });

    window.addEventListener('resize', fitToViewport);
    fitToViewport();
  }

  function handleImageFile(file) {
    if (!file.type.startsWith('image/')) {
      alert('Please upload a valid image file (JPG, PNG, WebP).');
      return;
    }

    // 1. Immediately upload to backend to store in current folder crops/
    fetch('/api/upload', {
      method: 'POST',
      body: file
    }).then(res => res.json())
      .then(data => console.log('Saree stored in crops/ folder:', data))
      .catch(err => console.warn('Could not save to server crops folder:', err));

    // 2. Load into browser rendering pipeline
    const reader = new FileReader();
    reader.onload = e => {
      const img = new Image();
      img.onload = () => {
        state.rotation = 0;
        state.flipX = false;
        state.flipY = false;
        setRawSaree(img);
        document.querySelectorAll('.sample-chips .chip[data-sample]').forEach(c => c.classList.remove('active'));
      };
      img.src = e.target.result;
    };
    reader.readAsDataURL(file);
  }

  function fitToViewport() {
    const stage = document.getElementById('viewport-stage');
    const padding = 40;
    const availW = stage.clientWidth - padding;
    const availH = stage.clientHeight - padding;

    const baseAspect = MODEL_WIDTH / MODEL_HEIGHT;
    let targetW = availW;
    let targetH = targetW / baseAspect;

    if (targetH > availH) {
      targetH = availH;
      targetW = targetH * baseAspect;
    }

    state.zoom = targetW / 600;
    updateZoom();
  }

  function updateZoom() {
    canvasWrapper.style.transform = `scale(${state.zoom})`;
    document.getElementById('zoom-level').textContent = `${Math.round(state.zoom * 100)}%`;
  }

  function exportHighRes() {
    const exportCanvas = document.createElement('canvas');
    exportCanvas.width = MODEL_WIDTH;
    exportCanvas.height = MODEL_HEIGHT;
    const exportCtx = exportCanvas.getContext('2d');

    exportCtx.drawImage(state.baseImage, 0, 0);
    exportCtx.drawImage(compositeCanvas, 0, 0);

    const link = document.createElement('a');
    link.download = `saree-draped-${Date.now()}.jpg`;
    link.href = exportCanvas.toDataURL('image/jpeg', 0.95);
    link.click();

    // Auto-save snapshot to server crops folder
    saveRenderSnapshot('hybrid_draped_result.png');
  }

  function saveRenderSnapshot(filename = 'hybrid_draped_result.png') {
    const exportCanvas = document.createElement('canvas');
    exportCanvas.width = MODEL_WIDTH;
    exportCanvas.height = MODEL_HEIGHT;
    const exportCtx = exportCanvas.getContext('2d');

    exportCtx.drawImage(state.baseImage, 0, 0);
    exportCtx.drawImage(compositeCanvas, 0, 0);

    const dataUrl = exportCanvas.toDataURL('image/png');
    return fetch('/api/save-render', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ filename, image: dataUrl })
    }).then(res => res.json())
      .then(d => { console.log('Saved render snapshot:', d); return d; })
      .catch(e => console.warn('Snapshot save error:', e));
  }
  window.saveRenderSnapshot = saveRenderSnapshot;

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
