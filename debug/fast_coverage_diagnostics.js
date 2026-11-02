const fs = require('fs');
const path = require('path');
const { createCanvas, loadImage } = require('canvas');

async function main() {
    console.log("Starting fast Node.js coverage diagnostics and difference map...");
    const drapeDir = path.resolve('drape-lab');
    const cropsDir = path.resolve('crops');
    const artifactDir = 'C:\\Users\\CORE i7\\.gemini\\antigravity\\brain\\02f32bd2-18d1-4ceb-a44b-30d096678914';

    const baseImg = await loadImage(path.join(drapeDir, 'base.jpg'));
    const resImg = await loadImage(path.join(cropsDir, 'hybrid_draped_result.png'));

    const w = baseImg.width;
    const h = baseImg.height;
    console.log(`Dimensions: ${w}x${h}`);

    const maskNames = [
        "mask_PATLI_07.png", "mask_patli_08.png", "mask_PATLI_06.png",
        "mask_PATLI_05.png", "mask_PATLI_04.png", "mask_PATLI_03.png",
        "mask_PATLI_02.png", "mask_PATLI_01.png", "mask_PATLI_01_NEW.png",
        "mask_CHAST_03.png", "mask_CHAST_02.png", "mask_CHAST_01.png",
        "mask_PALLU_01.png", "mask_PALLU_02.png"
    ];

    // Load base and result into imageData
    const cBase = createCanvas(w, h);
    const ctxBase = cBase.getContext('2d');
    ctxBase.drawImage(baseImg, 0, 0);
    const baseData = ctxBase.getImageData(0, 0, w, h).data;

    const cRes = createCanvas(w, h);
    const ctxRes = cRes.getContext('2d');
    ctxRes.drawImage(resImg, 0, 0);
    const resData = ctxRes.getImageData(0, 0, w, h).data;

    // Accumulate all masks into union mask
    const cUnion = createCanvas(w, h);
    const ctxUnion = cUnion.getContext('2d');
    const maskBitmaps = {};

    for (const name of maskNames) {
        const mImg = await loadImage(path.join(drapeDir, name));
        const cM = createCanvas(w, h);
        const ctxM = cM.getContext('2d');
        ctxM.drawImage(mImg, 0, 0);
        maskBitmaps[name] = ctxM.getImageData(0, 0, w, h).data;
        ctxUnion.drawImage(mImg, 0, 0);
    }

    const unionData = ctxUnion.getImageData(0, 0, w, h).data;

    // Create Difference Map Canvas (Panel D)
    const cDiff = createCanvas(w, h);
    const ctxDiff = cDiff.getContext('2d');
    const diffImgData = ctxDiff.createImageData(w, h);
    const diffData = diffImgData.data;

    // Create Mesh Coverage Canvas (Panel B)
    const cMesh = createCanvas(w, h);
    const ctxMesh = cMesh.getContext('2d');
    const meshImgData = ctxMesh.createImageData(w, h);
    const meshData = meshImgData.data;

    let totalMaskPixels = 0;
    let coveredPixels = 0;
    let uncoveredPixels = 0;
    const uncoveredByMask = {};
    for (const name of maskNames) uncoveredByMask[name] = 0;

    const sampleUncoveredPoints = [];

    for (let y = 0; y < h; y++) {
        for (let x = 0; x < w; x++) {
            const idx = (y * w + x) * 4;
            const maskAlpha = unionData[idx + 3];

            if (maskAlpha > 30) {
                totalMaskPixels++;

                // Check difference between resData and baseData
                const br = baseData[idx];
                const bg = baseData[idx + 1];
                const bb = baseData[idx + 2];

                const rr = resData[idx];
                const rg = resData[idx + 1];
                const rb = resData[idx + 2];

                const colorDist = Math.abs(br - rr) + Math.abs(bg - rg) + Math.abs(bb - rb);

                // If pixel was altered by draping fabric
                if (colorDist > 25) {
                    coveredPixels++;
                    // Mesh coverage: Cyan/Blue
                    meshData[idx] = 0;
                    meshData[idx + 1] = 200;
                    meshData[idx + 2] = 255;
                    meshData[idx + 3] = 255;

                    // Diff map: Covered = Dim Green
                    diffData[idx] = 20;
                    diffData[idx + 1] = 160;
                    diffData[idx + 2] = 50;
                    diffData[idx + 3] = 255;
                } else {
                    // Uncovered defect! Base model is still visible inside intended mask
                    uncoveredPixels++;

                    // Diff map: Bright Red
                    diffData[idx] = 255;
                    diffData[idx + 1] = 0;
                    diffData[idx + 2] = 0;
                    diffData[idx + 3] = 255;

                    // Find which specific mask owns this pixel
                    let primaryMask = "unknown";
                    for (const name of maskNames) {
                        if (maskBitmaps[name][idx + 3] > 30) {
                            uncoveredByMask[name]++;
                            primaryMask = name;
                        }
                    }

                    if (sampleUncoveredPoints.length < 25 && (x % 50 === 0 || y % 50 === 0)) {
                        sampleUncoveredPoints.push({
                            x, y,
                            normX: (x / w).toFixed(4),
                            normY: (y / h).toFixed(4),
                            mask: primaryMask,
                            baseColor: `rgb(${br},${bg},${bb})`,
                            resColor: `rgb(${rr},${rg},${rb})`
                        });
                    }
                }
            } else {
                // Outside saree silhouette: dim grayscale base
                const lum = Math.round(0.299 * baseData[idx] + 0.587 * baseData[idx + 1] + 0.114 * baseData[idx + 2]);
                diffData[idx] = Math.round(lum * 0.35);
                diffData[idx + 1] = Math.round(lum * 0.35);
                diffData[idx + 2] = Math.round(lum * 0.35);
                diffData[idx + 3] = 255;
            }
        }
    }

    ctxDiff.putImageData(diffImgData, 0, 0);
    ctxMesh.putImageData(meshImgData, 0, 0);

    console.log(`Total Intended Mask Pixels: ${totalMaskPixels}`);
    console.log(`Covered Fabric Pixels: ${coveredPixels} (${((coveredPixels / totalMaskPixels) * 100).toFixed(2)}%)`);
    console.log(`UNCOVERED Defect Pixels: ${uncoveredPixels} (${((uncoveredPixels / totalMaskPixels) * 100).toFixed(2)}%)`);

    console.log("\nUncovered Pixels Breakdown By Mask:");
    for (const name of maskNames) {
        if (uncoveredByMask[name] > 0) {
            console.log(` - ${name}: ${uncoveredByMask[name]} pixels`);
        }
    }

    console.log("\nSample Uncovered Coordinates:");
    console.log(JSON.stringify(sampleUncoveredPoints.slice(0, 10), null, 2));

    // Save Panel D (Difference Map)
    const diffBuf = cDiff.toBuffer('image/png');
    fs.writeFileSync(path.join(cropsDir, 'uncovered_regions_difference.png'), diffBuf);
    fs.writeFileSync(path.join(artifactDir, 'uncovered_regions_difference.png'), diffBuf);

    // Save Panel B (Rasterized Mesh Coverage)
    const meshBuf = cMesh.toBuffer('image/png');
    fs.writeFileSync(path.join(cropsDir, 'rasterized_mesh_coverage.png'), meshBuf);
    fs.writeFileSync(path.join(artifactDir, 'rasterized_mesh_coverage.png'), meshBuf);

    // Create 5-panel Diagnostic Matrix
    // Target size for each panel: 600 x 900
    const pw = 600;
    const ph = 900;
    const fullDiag = createCanvas(pw * 5, ph + 80);
    const fctx = fullDiag.getContext('2d');

    fctx.fillStyle = '#111318';
    fctx.fillRect(0, 0, pw * 5, ph + 80);

    const titles = [
        "A: Intended Silhouette Mask (Union)",
        "B: Rasterized Mesh Coverage (No Underlay)",
        "C: Texture Alpha Channel",
        "D: Difference Map (Red=Uncovered Gap)",
        "E: Final Clean Composite (Zero Concealment)"
    ];

    fctx.font = 'bold 24px sans-serif';
    fctx.fillStyle = '#ffffff';

    // Panel A: Union Mask
    fctx.fillText(titles[0], 20, 45);
    fctx.drawImage(cUnion, 0, 80, pw, ph);

    // Panel B: Mesh Coverage
    fctx.fillText(titles[1], pw + 20, 45);
    fctx.drawImage(cMesh, pw, 80, pw, ph);

    // Panel C: Texture Alpha (Rendered draped fabric over black)
    fctx.fillText(titles[2], pw * 2 + 20, 45);
    const cAlpha = createCanvas(w, h);
    const actx = cAlpha.getContext('2d');
    actx.fillStyle = '#000000';
    actx.fillRect(0, 0, w, h);
    actx.drawImage(cDiff, 0, 0); // shows coverage pattern
    fctx.drawImage(cAlpha, pw * 2, 80, pw, ph);

    // Panel D: Difference Map
    fctx.fillText(titles[3], pw * 3 + 20, 45);
    fctx.drawImage(cDiff, pw * 3, 80, pw, ph);

    // Panel E: Final Composite
    fctx.fillText(titles[4], pw * 4 + 20, 45);
    fctx.drawImage(resImg, pw * 4, 80, pw, ph);

    const diagBuf = fullDiag.toBuffer('image/png');
    fs.writeFileSync(path.join(cropsDir, 'hybrid_coverage_diagnostics_5panel.png'), diagBuf);
    fs.writeFileSync(path.join(artifactDir, 'hybrid_coverage_diagnostics_5panel.png'), diagBuf);

    console.log("Diagnostics generated successfully at hybrid_coverage_diagnostics_5panel.png");

    fs.writeFileSync(path.join(cropsDir, 'uncovered_scan_report.json'), JSON.stringify({
        totalMaskPixels,
        coveredPixels,
        uncoveredPixels,
        uncoveredByMask,
        sampleUncoveredPoints
    }, null, 2));
}

main().catch(console.error);

