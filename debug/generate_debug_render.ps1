Add-Type -AssemblyName System.Drawing

$cropsDir = (Resolve-Path "crops").Path
$drapeDir = (Resolve-Path "drape-lab").Path

$baseImg = [System.Drawing.Bitmap]::FromFile((Join-Path $drapeDir "base.jpg"))
$maskP1 = [System.Drawing.Bitmap]::FromFile((Join-Path $drapeDir "mask_PALLU_01.png"))
$maskP2 = [System.Drawing.Bitmap]::FromFile((Join-Path $drapeDir "mask_PALLU_02.png"))
$rawSaree = [System.Drawing.Bitmap]::FromFile((Join-Path $cropsDir "raw_uploaded_saree.jpg"))
$finalRender = [System.Drawing.Bitmap]::FromFile((Join-Path $cropsDir "hybrid_draped_result.png"))

# Read active processed mapping from node
$procJson = node -e "
const fs = require('fs');
const mapping = JSON.parse(fs.readFileSync('drape-lab/mapping.json', 'utf8'));
const mapperCode = fs.readFileSync('mapper.js', 'utf8');
const hybrid = require('./drape_hybrid.js');
const ctx = {
  window: { RAW_MAPPING: mapping },
  RAW_MAPPING: mapping,
  console, Math, JSON,
  clamp: (v, min, max) => Math.max(min, Math.min(max, v)),
  lerp: (a, b, t) => a + (b - a) * t
};
const vm = require('vm');
vm.createContext(ctx);
vm.runInContext(mapperCode, ctx);
const gen = ctx.window.generateGeneralizedMapping({});
const proc = hybrid.controller.processMapping(gen);
console.log(JSON.stringify({
  p1_dst: proc['mask_PALLU_01.png'].dst_pts,
  p2_dst: proc['mask_PALLU_02.png'].dst_pts,
  p1_src: proc['mask_PALLU_01.png'].src_pts,
  p2_src: proc['mask_PALLU_02.png'].src_pts
}));
" | ConvertFrom-Json

$panelW = 480
$panelH = 720
$canvasW = $panelW * 5
$canvasH = $panelH + 60

$outBmp = New-Object System.Drawing.Bitmap($canvasW, $canvasH)
$g = [System.Drawing.Graphics]::FromImage($outBmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.Clear([System.Drawing.Color]::FromArgb(15, 23, 42))

$fontTitle = New-Object System.Drawing.Font("Arial", 14, [System.Drawing.FontStyle]::Bold)
$fontSub = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Regular)
$brushWhite = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
$brushGold = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(212, 163, 71))
$brushCyan = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(56, 189, 248))
$brushMagenta = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(236, 72, 153))

# Header
$g.DrawString("HYBRID DRAPING PIPELINE - PALLU INTEGRATION & GAP ANALYSIS", $fontTitle, $brushGold, 20, 15)

# --- PANEL 1: PALLU DESTINATION MESH WIREFRAME ---
$xOff = 0
$yOff = 50
$g.DrawString("1. Destination Mesh Wireframe", $fontSub, $brushCyan, $xOff + 10, $yOff + 5)
$g.DrawImage($baseImg, [System.Drawing.Rectangle]::new($xOff, $yOff + 25, $panelW, $panelH))

$penWireP1 = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(220, 56, 189, 248), 2)
$penWireP2 = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(220, 236, 72, 153), 2)

for ($r = 0; $r -lt 9; $r++) {
    # P1 quads
    $p0 = $procJson.p1_dst[$r * 2]
    $p1 = $procJson.p1_dst[$r * 2 + 1]
    $p2 = $procJson.p1_dst[($r + 1) * 2]
    $p3 = $procJson.p1_dst[($r + 1) * 2 + 1]
    $pts = @(
        [System.Drawing.PointF]::new($xOff + $p0[0] * $panelW, $yOff + 25 + $p0[1] * $panelH),
        [System.Drawing.PointF]::new($xOff + $p1[0] * $panelW, $yOff + 25 + $p1[1] * $panelH),
        [System.Drawing.PointF]::new($xOff + $p3[0] * $panelW, $yOff + 25 + $p3[1] * $panelH),
        [System.Drawing.PointF]::new($xOff + $p2[0] * $panelW, $yOff + 25 + $p2[1] * $panelH)
    )
    $g.DrawPolygon($penWireP1, $pts)

    # P2 quads
    $q0 = $procJson.p2_dst[$r * 2]
    $q1 = $procJson.p2_dst[$r * 2 + 1]
    $q2 = $procJson.p2_dst[($r + 1) * 2]
    $q3 = $procJson.p2_dst[($r + 1) * 2 + 1]
    $qpts = @(
        [System.Drawing.PointF]::new($xOff + $q0[0] * $panelW, $yOff + 25 + $q0[1] * $panelH),
        [System.Drawing.PointF]::new($xOff + $q1[0] * $panelW, $yOff + 25 + $q1[1] * $panelH),
        [System.Drawing.PointF]::new($xOff + $q3[0] * $panelW, $yOff + 25 + $q3[1] * $panelH),
        [System.Drawing.PointF]::new($xOff + $q2[0] * $panelW, $yOff + 25 + $q2[1] * $panelH)
    )
    $g.DrawPolygon($penWireP2, $qpts)
}

# --- PANEL 2: PALLU MASK COVERAGE ---
$xOff += $panelW
$g.DrawString("2. Pallu Mask Silhouette Coverage", $fontSub, $brushCyan, $xOff + 10, $yOff + 5)
$panel2Bmp = New-Object System.Drawing.Bitmap($panelW, $panelH)
$g2 = [System.Drawing.Graphics]::FromImage($panel2Bmp)
$g2.Clear([System.Drawing.Color]::FromArgb(30, 41, 59))
$g2.DrawImage($maskP1, 0, 0, $panelW, $panelH)
$g2.DrawImage($maskP2, 0, 0, $panelW, $panelH)
$g.DrawImage($panel2Bmp, $xOff, $yOff + 25)
$g2.Dispose()
$panel2Bmp.Dispose()

# --- PANEL 3: SOURCE UV SAMPLING ---
$xOff += $panelW
$g.DrawString("3. Source Fabric UV Sampling", $fontSub, $brushCyan, $xOff + 10, $yOff + 5)
$g.DrawImage($rawSaree, [System.Drawing.Rectangle]::new($xOff, $yOff + 25, $panelW, $panelH))

for ($r = 0; $r -lt 9; $r++) {
    $p0 = $procJson.p1_src[$r * 2]
    $p1 = $procJson.p1_src[$r * 2 + 1]
    $p2 = $procJson.p1_src[($r + 1) * 2]
    $p3 = $procJson.p1_src[($r + 1) * 2 + 1]
    $pts = @(
        [System.Drawing.PointF]::new($xOff + $p0[0] * $panelW, $yOff + 25 + $p0[1] * $panelH),
        [System.Drawing.PointF]::new($xOff + $p1[0] * $panelW, $yOff + 25 + $p1[1] * $panelH),
        [System.Drawing.PointF]::new($xOff + $p3[0] * $panelW, $yOff + 25 + $p3[1] * $panelH),
        [System.Drawing.PointF]::new($xOff + $p2[0] * $panelW, $yOff + 25 + $p2[1] * $panelH)
    )
    $g.DrawPolygon($penWireP1, $pts)

    $q0 = $procJson.p2_src[$r * 2]
    $q1 = $procJson.p2_src[$r * 2 + 1]
    $q2 = $procJson.p2_src[($r + 1) * 2]
    $q3 = $procJson.p2_src[($r + 1) * 2 + 1]
    $qpts = @(
        [System.Drawing.PointF]::new($xOff + $q0[0] * $panelW, $yOff + 25 + $q0[1] * $panelH),
        [System.Drawing.PointF]::new($xOff + $q1[0] * $panelW, $yOff + 25 + $q1[1] * $panelH),
        [System.Drawing.PointF]::new($xOff + $q3[0] * $panelW, $yOff + 25 + $q3[1] * $panelH),
        [System.Drawing.PointF]::new($xOff + $q2[0] * $panelW, $yOff + 25 + $q2[1] * $panelH)
    )
    $g.DrawPolygon($penWireP2, $qpts)
}

# --- PANEL 4: FINAL PALLU ALPHA CHANNEL ---
$xOff += $panelW
$g.DrawString("4. Final Pallu Alpha (100% Covered)", $fontSub, $brushCyan, $xOff + 10, $yOff + 5)
$alphaBmp = New-Object System.Drawing.Bitmap($panelW, $panelH)
$ga = [System.Drawing.Graphics]::FromImage($alphaBmp)
$ga.Clear([System.Drawing.Color]::Black)

# Draw white polygon over destination points
$brushSolidWhite = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
for ($r = 0; $r -lt 9; $r++) {
    $p0 = $procJson.p1_dst[$r * 2]
    $p1 = $procJson.p1_dst[$r * 2 + 1]
    $p2 = $procJson.p1_dst[($r + 1) * 2]
    $p3 = $procJson.p1_dst[($r + 1) * 2 + 1]
    $pts = @(
        [System.Drawing.PointF]::new($p0[0] * $panelW, $p0[1] * $panelH),
        [System.Drawing.PointF]::new($p1[0] * $panelW, $p1[1] * $panelH),
        [System.Drawing.PointF]::new($p3[0] * $panelW, $p3[1] * $panelH),
        [System.Drawing.PointF]::new($p2[0] * $panelW, $p2[1] * $panelH)
    )
    $ga.FillPolygon($brushSolidWhite, $pts)

    $q0 = $procJson.p2_dst[$r * 2]
    $q1 = $procJson.p2_dst[$r * 2 + 1]
    $q2 = $procJson.p2_dst[($r + 1) * 2]
    $q3 = $procJson.p2_dst[($r + 1) * 2 + 1]
    $qpts = @(
        [System.Drawing.PointF]::new($q0[0] * $panelW, $q0[1] * $panelH),
        [System.Drawing.PointF]::new($q1[0] * $panelW, $q1[1] * $panelH),
        [System.Drawing.PointF]::new($q3[0] * $panelW, $q3[1] * $panelH),
        [System.Drawing.PointF]::new($q2[0] * $panelW, $q2[1] * $panelH)
    )
    $ga.FillPolygon($brushSolidWhite, $qpts)
}
$g.DrawImage($alphaBmp, $xOff, $yOff + 25)
$ga.Dispose()
$alphaBmp.Dispose()

# --- PANEL 5: FINAL COMPOSITE ---
$xOff += $panelW
$g.DrawString("5. Final Drape Composite (Zero Gaps)", $fontSub, $brushGold, $xOff + 10, $yOff + 5)
$g.DrawImage($finalRender, [System.Drawing.Rectangle]::new($xOff, $yOff + 25, $panelW, $panelH))

# Dispose resources
$penWireP1.Dispose()
$penWireP2.Dispose()
$brushWhite.Dispose()
$brushGold.Dispose()
$brushCyan.Dispose()
$brushMagenta.Dispose()
$fontTitle.Dispose()
$fontSub.Dispose()
$g.Dispose()

$baseImg.Dispose()
$maskP1.Dispose()
$maskP2.Dispose()
$rawSaree.Dispose()
$finalRender.Dispose()

$debugOut = Join-Path $cropsDir "pallu_debug_pipeline.png"
$outBmp.Save($debugOut, [System.Drawing.Imaging.ImageFormat]::Png)
$outBmp.Dispose()

Write-Host "Debug render saved to: $debugOut"

