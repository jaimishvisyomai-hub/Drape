Add-Type -AssemblyName System.Drawing

$saree = [System.Drawing.Bitmap]::FromFile((Resolve-Path "crops/raw_uploaded_saree.jpg"))
$bmp = New-Object System.Drawing.Bitmap($saree.Width, $saree.Height)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.DrawImage($saree, 0, 0, $saree.Width, $saree.Height)

$font = New-Object System.Drawing.Font("Arial", 14, [System.Drawing.FontStyle]::Bold)
$fontSmall = New-Object System.Drawing.Font("Arial", 11, [System.Drawing.FontStyle]::Regular)
$brushText = [System.Drawing.Brushes]::White
$brushShadow = [System.Drawing.Brushes]::Black

function Draw-AnnotatedBox($x0, $y0, $x1, $y1, $color, $label, $sub) {
    $w = $x1 - $x0
    $h = $y1 - $y0
    $pen = New-Object System.Drawing.Pen($color, 3)
    $brushSemi = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(45, $color.R, $color.G, $color.B))
    $g.FillRectangle($brushSemi, $x0, $y0, $w, $h)
    $g.DrawRectangle($pen, $x0, $y0, $w, $h)
    
    # Label box
    $bgBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(210, 20, 20, 20))
    $g.FillRectangle($bgBrush, $x0 + 6, $y0 + 6, [Math]::Min(400, $w - 12), 44)
    $g.DrawString($label, $font, [System.Drawing.Brushes]::Yellow, $x0 + 10, $y0 + 8)
    $g.DrawString($sub, $fontSmall, [System.Drawing.Brushes]::White, $x0 + 10, $y0 + 28)
}

# 1. Left Silver Jacquard Border
Draw-AnnotatedBox 0 0 135 1600 `
    ([System.Drawing.Color]::FromArgb(192, 192, 220)) `
    "Zone 1: Silver Jacquard Border" `
    "U: [0.000..0.141] • Vertical Front Border"

# 2. Right Gold Border
Draw-AnnotatedBox 910 0 960 1600 `
    ([System.Drawing.Color]::FromArgb(234, 179, 8)) `
    "Zone 2: Gold Border" `
    "U: [0.948..1.000] • Outer Selvage"

# 3. Body Floral Vines
Draw-AnnotatedBox 140 0 905 860 `
    ([System.Drawing.Color]::FromArgb(34, 197, 94)) `
    "Zone 3: Saree Body (Floral Vines & Birds)" `
    "U: [0.146..0.943], V: [0.000..0.538] • Chest & Pleat Field"

# 4. Upper Stripes
Draw-AnnotatedBox 140 860 905 1080 `
    ([System.Drawing.Color]::FromArgb(249, 115, 22)) `
    "Zone 4: Upper Zari Stripes" `
    "V: [0.538..0.675] • Mid Pallu Transition"

# 5. Central Medallion (Swans & Lotus)
Draw-AnnotatedBox 155 1100 845 1395 `
    ([System.Drawing.Color]::FromArgb(239, 68, 68)) `
    "Zone 5: Central Medallion (Swans & Lotus)" `
    "U: [0.161..0.880], V: [0.688..0.872] • 690x295 (AR: 2.34)"

# 6. Lower Stripes
Draw-AnnotatedBox 140 1410 905 1560 `
    ([System.Drawing.Color]::FromArgb(249, 115, 22)) `
    "Zone 6: Lower Zari Stripes" `
    "V: [0.881..0.975] • Post-Medallion Bands"

# 7. Bottom Hem
Draw-AnnotatedBox 0 1560 960 1600 `
    ([System.Drawing.Color]::FromArgb(234, 179, 8)) `
    "Zone 7: Bottom Hem Border" `
    "V: [0.975..1.000] • Bottom Fringe Hem"

$outPath1 = "crops/diagnostic_1_source_saree_annotated.png"
$bmp.Save($outPath1, [System.Drawing.Imaging.ImageFormat]::Png)

$artPath1 = "C:\Users\CORE i7\.gemini\antigravity\brain\02f32bd2-18d1-4ceb-a44b-30d096678914\diagnostic_1_source_saree_annotated.png"
$bmp.Save($artPath1, [System.Drawing.Imaging.ImageFormat]::Png)

$g.Dispose()
$bmp.Dispose()
$saree.Dispose()

Write-Host "Diagnostic 1 successfully saved!"

