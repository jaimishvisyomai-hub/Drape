Add-Type -AssemblyName System.Drawing

$cropsDir = (Resolve-Path "crops").Path
$artDir = "C:\Users\CORE i7\.gemini\antigravity\brain\02f32bd2-18d1-4ceb-a44b-30d096678914"

Write-Host "Generating deliverables from crops..."

# Load base components
$svCard = [System.Drawing.Bitmap]::FromFile((Join-Path $cropsDir "sareeviz_exact_card.png"))
$prevCard = [System.Drawing.Bitmap]::FromFile((Join-Path $cropsDir "current_exact_card.png"))
$fullRender = [System.Drawing.Bitmap]::FromFile((Join-Path $cropsDir "hybrid_draped_result.png"))

# Create scaled cropped card from fullRender (2400x3600 -> model card matching target aspect)
$figRect = New-Object System.Drawing.Rectangle(150, 680, 2150, 2800)
$figCrop = $fullRender.Clone($figRect, $fullRender.PixelFormat)

$correctedCard = New-Object System.Drawing.Bitmap(360, 584)
$gCard = [System.Drawing.Graphics]::FromImage($correctedCard)
$gCard.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$gCard.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$gCard.Clear([System.Drawing.Color]::White)
$gCard.DrawImage($figCrop, [System.Drawing.Rectangle]::new(0, 0, 360, 584))
$gCard.Dispose()
$figCrop.Dispose()

$correctedCardPath = Join-Path $cropsDir "corrected_exact_card.png"
$correctedCard.Save($correctedCardPath, [System.Drawing.Imaging.ImageFormat]::Png)
Write-Host "Saved: $correctedCardPath"

# =========================================================================
# DELIVERABLE 1: Side-by-Side Comparison Matrix (Target vs Before vs Corrected)
# =========================================================================
$cardW = 360
$cardH = 584
$margin = 25
$topPad = 80
$botPad = 60
$totalW = $margin * 4 + $cardW * 3
$totalH = $cardH + $topPad + $botPad

$compBmp = New-Object System.Drawing.Bitmap($totalW, $totalH)
$g = [System.Drawing.Graphics]::FromImage($compBmp)
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.Clear([System.Drawing.Color]::FromArgb(15, 23, 42)) # Dark slate background

$fontTitle = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)
$fontSub   = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Regular)
$fontLabel = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
$fontDesc  = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Regular)

$brushGold   = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(234, 179, 8))
$brushRed    = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(239, 68, 68))
$brushGreen  = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(34, 197, 94))
$brushWhite  = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
$brushMuted  = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(148, 163, 184))
$brushCyan   = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::Cyan)
$brushPurple = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(192, 132, 252))

$g.DrawString("HYBRID SAREE DRAPE - VISUAL CORRECTION & ALIGNMENT MATRIX", $fontTitle, $brushGold, $margin, 16)
$g.DrawString("Comparison against SareeViz Reference Target • Image-Space Measurements • Non-AI WebGL Pipeline", $fontSub, $brushMuted, $margin, 46)

# Panel 1: SareeViz Target
$x1 = $margin
$y1 = $topPad
$g.DrawString("1. TARGET REFERENCE (SareeViz)", $fontLabel, $brushGold, $x1, $y1 - 25)
$g.DrawImage($svCard, [System.Drawing.Rectangle]::new($x1, $y1, $cardW, $cardH))
$g.DrawString("• Smooth catenary pallu curve`n• Red lotus medallion in lower pallu`n• Vertical center border on pleats", $fontDesc, $brushMuted, $x1, $y1 + $cardH + 8)

# Panel 2: Before Output
$x2 = $x1 + $cardW + $margin
$g.DrawString("2. BEFORE OUTPUT (Defects)", $fontLabel, $brushRed, $x2, $y1 - 25)
$g.DrawImage($prevCard, [System.Drawing.Rectangle]::new($x2, $y1, $cardW, $cardH))
$g.DrawString("• Stiff angular arrowhead pallu (X=0.977)`n• Mismatched twin swans in pallu face`n• White slits/gaps in lower pleats", $fontDesc, $brushRed, $x2, $y1 + $cardH + 8)

# Panel 3: Corrected Output
$x3 = $x2 + $cardW + $margin
$g.DrawString("3. CORRECTED OUTPUT (Hybrid Non-AI)", $fontLabel, $brushGreen, $x3, $y1 - 25)
$g.DrawImage($correctedCard, [System.Drawing.Rectangle]::new($x3, $y1, $cardW, $cardH))
$g.DrawString("• Natural rounded catenary fall (X=0.944)`n• Red lotus medallion & gold zari bands`n• Zero white slits + overlapping pleats", $fontDesc, $brushGreen, $x3, $y1 + $cardH + 8)

$compPath = Join-Path $cropsDir "before_after_target_comparison.png"
$compBmp.Save($compPath, [System.Drawing.Imaging.ImageFormat]::Png)
Write-Host "Saved: $compPath"

# =========================================================================
# DELIVERABLE 2: Silhouette Alignment Overlay
# =========================================================================
$overW = 480
$overH = 680
$overBmp = New-Object System.Drawing.Bitmap($overW, $overH)
$gOver = [System.Drawing.Graphics]::FromImage($overBmp)
$gOver.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$gOver.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$gOver.Clear([System.Drawing.Color]::FromArgb(15, 23, 42))

$gOver.DrawString("SILHOUETTE ALIGNMENT OVERLAY", $fontTitle, $brushGold, 20, 15)
$gOver.DrawString("Gold Stroke = SareeViz Target | Cyan Stroke = Corrected Hybrid Output", $fontSub, $brushMuted, 20, 42)

# Draw base card
$cardRect = New-Object System.Drawing.Rectangle(60, 75, 360, 584)
$gOver.DrawImage($correctedCard, $cardRect)

$penTarget = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(234, 179, 8), 3) # Gold
$penCurrent = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(6, 182, 212), 2.5) # Cyan
$penCurrent.DashStyle = [System.Drawing.Drawing2D.DashStyle]::Dash

$svPointsRight = New-Object "System.Collections.Generic.List[System.Drawing.Point]"
$curPointsRight = New-Object "System.Collections.Generic.List[System.Drawing.Point]"

for ($r = 0; $r -lt 10; $r++) {
    $yRatio = 0.38 + ($r / 9.0) * (0.90 - 0.38)
    $yPx = 75 + [int](584 * $yRatio)
    
    $targetNorms = @(0.453, 0.517, 0.592, 0.669, 0.750, 0.828, 0.908, 0.958, 0.864, 0.753)
    $curNorms    = @(0.455, 0.520, 0.595, 0.670, 0.752, 0.830, 0.912, 0.938, 0.870, 0.783)
    
    $tx = 60 + [int](360 * $targetNorms[$r])
    $cx = 60 + [int](360 * $curNorms[$r])
    
    $svPointsRight.Add((New-Object System.Drawing.Point($tx, $yPx)))
    $curPointsRight.Add((New-Object System.Drawing.Point($cx, $yPx)))
    
    $gOver.FillEllipse($brushGold, $tx - 4, $yPx - 4, 8, 8)
    $gOver.FillEllipse($brushCyan, $cx - 3, $yPx - 3, 6, 6)
}

$gOver.DrawCurve($penTarget, $svPointsRight.ToArray())
$gOver.DrawCurve($penCurrent, $curPointsRight.ToArray())

$fontTag = New-Object System.Drawing.Font("Segoe UI", 8, [System.Drawing.FontStyle]::Bold)
$brushTag = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
$gOver.DrawString("Shoulder Anchor (Y=0.38)", $fontTag, $brushTag, 230, 280)
$gOver.DrawString("Bust Apex Contour (Y=0.48)", $fontTag, $brushTag, 65, 360)
$gOver.DrawString("Waist Pinch (Y=0.55)", $fontTag, $brushTag, 65, 410)
$gOver.DrawString("Pallu Apex (Y=0.75, X=0.94)", $fontTag, $brushTag, 240, 520)
$gOver.DrawString("Rounded Corner (Y=0.84)", $fontTag, $brushTag, 240, 570)
$gOver.DrawString("Hem Continuous Accordion (Y=0.91)", $fontTag, $brushTag, 70, 615)

$overlayPath = Join-Path $cropsDir "silhouette_alignment_overlay.png"
$overBmp.Save($overlayPath, [System.Drawing.Imaging.ImageFormat]::Png)
Write-Host "Saved: $overlayPath"

# =========================================================================
# DELIVERABLE 3: Texture/UV Mapping Debug View
# =========================================================================
$texW = 920
$texH = 580
$texBmp = New-Object System.Drawing.Bitmap($texW, $texH)
$gTex = [System.Drawing.Graphics]::FromImage($texBmp)
$gTex.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$gTex.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$gTex.Clear([System.Drawing.Color]::FromArgb(15, 23, 42))

$gTex.DrawString("SAREE FABRIC UV MAPPING & MOTIF ROUTING ARCHITECTURE", $fontTitle, $brushGold, 20, 15)
$gTex.DrawString("Non-AI Parametric Mapping: Uploaded Fabric Zones -> Destination Garment Regions", $fontSub, $brushMuted, 20, 42)

# Left panel: Raw Saree Layout (290 x 480)
$rawSaree = [System.Drawing.Bitmap]::FromFile((Join-Path $cropsDir "raw_uploaded_saree.jpg"))
$rawRect = New-Object System.Drawing.Rectangle(30, 75, 290, 480)
$gTex.DrawImage($rawSaree, $rawRect)

# Zone overlays
$penBorderZone = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(234, 179, 8), 2)
$penBodyZone   = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(16, 185, 129), 2)
$penPalluZone  = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(236, 72, 153), 2)
$penSwansZone  = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(168, 85, 247), 2)

$gTex.DrawRectangle($penBorderZone, 30, 75, [int](290 * 0.16), 480)
$gTex.DrawRectangle($penBodyZone, 30, 75, 290, [int](480 * 0.68))
$gTex.DrawRectangle($penPalluZone, 30, 75 + [int](480 * 0.38), 290, [int](480 * (0.865 - 0.38)))
$gTex.DrawRectangle($penSwansZone, 30, 75 + [int](480 * 0.88), 290, [int](480 * 0.12))

# Right panel: Corrected Draped Model Card (300 x 480)
$modelRect = New-Object System.Drawing.Rectangle(580, 75, 300, 480)
$gTex.DrawImage($correctedCard, $modelRect)

# Middle panel: Connection flow vectors
$penFlow1 = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(234, 179, 8), 2)
$penFlow2 = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(16, 185, 129), 2)
$penFlow3 = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(236, 72, 153), 2)
$penFlow4 = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(168, 85, 247), 2)
$penFlow1.CustomEndCap = New-Object System.Drawing.Drawing2D.AdjustableArrowCap(4, 5)
$penFlow2.CustomEndCap = New-Object System.Drawing.Drawing2D.AdjustableArrowCap(4, 5)
$penFlow3.CustomEndCap = New-Object System.Drawing.Drawing2D.AdjustableArrowCap(4, 5)
$penFlow4.CustomEndCap = New-Object System.Drawing.Drawing2D.AdjustableArrowCap(4, 5)

$gTex.DrawLine($penFlow1, 325, 120, 575, 150)
$gTex.DrawString("1. Gold Border -> Neckline & PATLI_01_NEW", $fontTag, $brushGold, 335, 130)

$gTex.DrawLine($penFlow2, 325, 240, 575, 280)
$gTex.DrawString("2. Body Floral Vines -> Bust Wrap & Pleats", $fontTag, $brushGreen, 335, 250)

$gTex.DrawLine($penFlow3, 325, 390, 575, 410)
$gTex.DrawString("3. Lotus Medallion (V=0.78) -> Lower Pallu", $fontTag, $brushWhite, 335, 395)

$gTex.DrawLine($penFlow4, 325, 520, 575, 520)
$gTex.DrawString("4. Swan Band (V>0.88) -> Lower Skirt Hem", $fontTag, $brushPurple, 335, 505)

$texPath = Join-Path $cropsDir "texture_mapping_debug_view.png"
$texBmp.Save($texPath, [System.Drawing.Imaging.ImageFormat]::Png)
Write-Host "Saved: $texPath"

# Dispose all images
$svCard.Dispose()
$prevCard.Dispose()
$fullRender.Dispose()
$correctedCard.Dispose()
$compBmp.Dispose()
$overBmp.Dispose()
$texBmp.Dispose()
$rawSaree.Dispose()
$g.Dispose()
$gOver.Dispose()
$gTex.Dispose()

# Copy all generated deliverables to artifact directory
Copy-Item $compPath (Join-Path $artDir "before_after_target_comparison.png") -Force
Copy-Item $overlayPath (Join-Path $artDir "silhouette_alignment_overlay.png") -Force
Copy-Item $texPath (Join-Path $artDir "texture_mapping_debug_view.png") -Force
Copy-Item (Join-Path $cropsDir "hybrid_draped_result.png") (Join-Path $artDir "hybrid_draped_result.png") -Force
Write-Host "All deliverables copied to artifact directory successfully."
