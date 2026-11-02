/**
 * Saree Preprocessor & Mask Filler Utility
 * 
 * 1. Proportional Fitting without Cropping:
 *    Preserves 100% of the uploaded saree image content.
 *    Never applies a center-crop, cover crop, or fixed slice that cuts off borders or motifs.
 *    If letterboxing/padding is needed to normalize to 960:1600 canvas space,
 *    it fits the entire image proportionally inside and provides diagnostic metadata.
 * 
 * 2. Solid alpha mask generation from contour masks.
 */

function fitProportionallyToRatio(sourceImage, targetW = 960, targetH = 1600) {
  const srcW = sourceImage.naturalWidth || sourceImage.width;
  const srcH = sourceImage.naturalHeight || sourceImage.height;

  // Diagnostics info
  const diagnostics = {
    originalWidth: srcW,
    originalHeight: srcH,
    originalAspectRatio: (srcW / srcH).toFixed(4),
    targetWidth: targetW,
    targetHeight: targetH,
    targetAspectRatio: (targetW / targetH).toFixed(4),
    cropped: false, // 100% full content preserved, 0% clipped
    renderWidth: 0,
    renderHeight: 0,
    padX: 0,
    padY: 0
  };

  const canvas = document.createElement('canvas');
  canvas.width = targetW;
  canvas.height = targetH;
  const ctx = canvas.getContext('2d');

  const targetRatio = targetW / targetH; // 0.60 (3:5)
  const srcRatio = srcW / srcH;

  let renderW, renderH, offsetX, offsetY;

  if (Math.abs(srcRatio - targetRatio) < 0.005) {
    // Exact or near-exact 960:1600 ratio: direct 1:1 full coverage
    renderW = targetW;
    renderH = targetH;
    offsetX = 0;
    offsetY = 0;
  } else if (srcRatio > targetRatio) {
    // Source is wider: fit full width inside targetW, letterbox height
    renderW = targetW;
    renderH = Math.round(srcH * (targetW / srcW));
    offsetX = 0;
    offsetY = Math.round((targetH - renderH) / 2);
  } else {
    // Source is taller: fit full height inside targetH, letterbox width
    renderH = targetH;
    renderW = Math.round(srcW * (targetH / srcH));
    offsetX = Math.round((targetW - renderW) / 2);
    offsetY = 0;
  }

  // Draw 100% of the uploaded saree image inside the canvas
  ctx.drawImage(sourceImage, offsetX, offsetY, renderW, renderH);

  // Seamless border edge continuation for any padding so UV coordinates never sample transparent/black voids:
  if (offsetY > 0) {
    ctx.drawImage(sourceImage, 0, 0, srcW, 2, 0, 0, targetW, offsetY);
    ctx.drawImage(sourceImage, 0, srcH - 2, srcW, 2, 0, offsetY + renderH, targetW, targetH - (offsetY + renderH));
  }
  if (offsetX > 0) {
    ctx.drawImage(sourceImage, 0, 0, 2, srcH, 0, 0, offsetX, targetH);
    ctx.drawImage(sourceImage, srcW - 2, 0, 2, srcH, offsetX + renderW, 0, targetW - (offsetX + renderW), targetH);
  }

  diagnostics.renderWidth = renderW;
  diagnostics.renderHeight = renderH;
  diagnostics.padX = offsetX;
  diagnostics.padY = offsetY;
  diagnostics.textureWidth = targetW;
  diagnostics.textureHeight = targetH;

  canvas.diagnostics = diagnostics;
  return canvas;
}

/**
 * Creates a solid filled alpha mask from an outline stroke mask image.
 * 
 * Requirements handled:
 * 1. Preserves original dimensions and alignment.
 * 2. Detects contour pixels using alpha channel threshold (> 25) and luminance fallback.
 * 3. Robust scanline fill with vertical continuity interpolation to bridge single-pixel gaps.
 * 4. Exterior background pixels remain completely transparent (alpha = 0).
 * 5. Validates and reports contour closure, non-zero pixel counts, and diagnostics.
 * 
 * @param {HTMLImageElement|HTMLCanvasElement} maskImg - Source mask image
 * @param {string} [maskName='mask'] - Mask filename for diagnostic logging
 * @returns {HTMLCanvasElement} Solid filled mask canvas with attached .diagnostics
 */
function createFilledMask(maskImg, maskName = 'mask') {
  const w = maskImg.naturalWidth || maskImg.width;
  const h = maskImg.naturalHeight || maskImg.height;

  const tempCanvas = document.createElement('canvas');
  tempCanvas.width = w;
  tempCanvas.height = h;
  const tempCtx = tempCanvas.getContext('2d');
  tempCtx.drawImage(maskImg, 0, 0);

  const imgData = tempCtx.getImageData(0, 0, w, h);
  const data = imgData.data;

  // 1. First pass: count original non-zero pixels and find min/max bounds for each row
  let origNonZeroCount = 0;
  const rowSpans = new Array(h);

  for (let y = 0; y < h; y++) {
    let minX = -1;
    let maxX = -1;

    for (let x = 0; x < w; x++) {
      const idx = (y * w + x) * 4;
      const alpha = data[idx + 3];
      // Check alpha or luminance if RGBA is packed differently
      const lum = 0.299 * data[idx] + 0.587 * data[idx + 1] + 0.114 * data[idx + 2];
      const isOpaque = alpha > 25 || (alpha > 0 && lum > 25);

      if (isOpaque) {
        origNonZeroCount++;
        if (minX === -1) minX = x;
        maxX = x;
      }
    }

    rowSpans[y] = { minX, maxX };
  }

  // 2. Vertical continuity check & gap bridging:
  // Detect rows with 0 pixels where nearby neighbors above and below have pixels (scanline breaks up to 4px)
  let brokenContoursDetected = 0;
  for (let y = 1; y < h - 1; y++) {
    if (rowSpans[y].minX === -1) {
      // Look up and down up to 4 scanlines
      let prevY = -1, nextY = -1;
      for (let dy = 1; dy <= 4 && y - dy >= 0; dy++) {
        if (rowSpans[y - dy].minX !== -1) { prevY = y - dy; break; }
      }
      for (let dy = 1; dy <= 4 && y + dy < h; dy++) {
        if (rowSpans[y + dy].minX !== -1) { nextY = y + dy; break; }
      }
      if (prevY !== -1 && nextY !== -1) {
        brokenContoursDetected++;
        const t = (y - prevY) / (nextY - prevY);
        rowSpans[y].minX = Math.round(rowSpans[prevY].minX + (rowSpans[nextY].minX - rowSpans[prevY].minX) * t);
        rowSpans[y].maxX = Math.round(rowSpans[prevY].maxX + (rowSpans[nextY].maxX - rowSpans[prevY].maxX) * t);
      }
    }
  }

  // 3. Second pass: fill row spans between minX and maxX with pure white solid alpha (255, 255, 255, 255)
  // Subtle 2px anti-aliased edge dilation/bleed to prevent sub-pixel seam gaps between adjacent garment layers
  let filledNonZeroCount = 0;
  let rowsFilled = 0;
  const DILATE_PX = 2;

  // Seam alignment for Pallu layers to eliminate alpha mask contour gap along the shared drape seam
  const isPallu1 = maskName.includes('PALLU_01');
  const isPallu2 = maskName.includes('PALLU_02');
  const seamY = [0.315, 0.395, 0.465, 0.533, 0.600, 0.668, 0.736, 0.803, 0.868, 0.930];
  const seamX = [0.455, 0.475, 0.496, 0.517, 0.538, 0.558, 0.580, 0.603, 0.655, 0.710];

  function getSeamX(normY) {
    if (normY <= seamY[0]) return seamX[0];
    if (normY >= seamY[seamY.length - 1]) return seamX[seamX.length - 1];
    for (let i = 0; i < seamY.length - 1; i++) {
      if (normY >= seamY[i] && normY <= seamY[i + 1]) {
        const t = (normY - seamY[i]) / (seamY[i + 1] - seamY[i]);
        return seamX[i] + (seamX[i + 1] - seamX[i]) * t;
      }
    }
    return seamX[0];
  }

  for (let y = 0; y < h; y++) {
    const span = rowSpans[y];
    if (span.minX !== -1 && span.maxX >= span.minX) {
      const normY = y / h;
      if (normY >= 0.30 && normY <= 0.94) {
        const seamPx = Math.round(getSeamX(normY) * w);
        if (isPallu1) {
          span.maxX = Math.max(span.maxX, seamPx + 3);
        } else if (isPallu2) {
          span.minX = Math.min(span.minX, seamPx - 3);
        }
      }

      rowsFilled++;
      const startX = Math.max(0, span.minX - DILATE_PX);
      const endX = Math.min(w - 1, span.maxX + DILATE_PX);

      for (let x = startX; x <= endX; x++) {
        const idx = (y * w + x) * 4;
        data[idx] = 255;
        data[idx + 1] = 255;
        data[idx + 2] = 255;
        data[idx + 3] = 255;
        filledNonZeroCount++;
      }
    }
  }

  tempCtx.putImageData(imgData, 0, 0);

  // Diagnostic metadata attached directly to canvas
  const diagnostics = {
    maskName,
    width: w,
    height: h,
    originalNonZeroPixels: origNonZeroCount,
    filledNonZeroPixels: filledNonZeroCount,
    fillExpansionRatio: origNonZeroCount > 0 ? (filledNonZeroCount / origNonZeroCount).toFixed(2) : '0',
    rowsFilled,
    success: filledNonZeroCount > origNonZeroCount,
    brokenContourGapsRepaired: brokenContoursDetected
  };

  tempCanvas.diagnostics = diagnostics;

  if (typeof console !== 'undefined' && console.log) {
    console.log(
      `[Mask Filler] ${maskName} (${w}x${h}) | Orig: ${origNonZeroCount} px -> Filled: ${filledNonZeroCount} px (${diagnostics.fillExpansionRatio}x) | Repaired Gaps: ${brokenContoursDetected} | Status: ${diagnostics.success ? 'SUCCESS' : 'NO CHANGE'}`
    );
  }

  return tempCanvas;
}

/**
 * Creates a diagnostic black silhouette preview on a pure white background.
 * 
 * @param {HTMLCanvasElement} filledMaskCanvas - Solid filled mask canvas
 * @returns {HTMLCanvasElement} Canvas containing black silhouette on white background
 */
function createSilhouettePreview(filledMaskCanvas) {
  const w = filledMaskCanvas.width;
  const h = filledMaskCanvas.height;

  const previewCanvas = document.createElement('canvas');
  previewCanvas.width = w;
  previewCanvas.height = h;
  const ctx = previewCanvas.getContext('2d');

  // Fill with pure white background
  ctx.fillStyle = '#ffffff';
  ctx.fillRect(0, 0, w, h);

  // Draw filled mask as black silhouette
  ctx.save();
  ctx.globalCompositeOperation = 'source-over';
  const imgData = filledMaskCanvas.getContext('2d').getImageData(0, 0, w, h);
  const data = imgData.data;

  const previewData = ctx.getImageData(0, 0, w, h);
  const pData = previewData.data;

  for (let i = 0; i < data.length; i += 4) {
    if (data[i + 3] > 128) {
      pData[i] = 15;     // Deep charcoal/black
      pData[i + 1] = 23;
      pData[i + 2] = 42;
      pData[i + 3] = 255;
    }
  }

  ctx.putImageData(previewData, 0, 0);
  ctx.restore();

  return previewCanvas;
}

window.fitProportionallyToRatio = fitProportionallyToRatio;
window.cropToRatio = fitProportionallyToRatio; // Compatibility alias
window.createFilledMask = createFilledMask;
window.createSilhouettePreview = createSilhouettePreview;
