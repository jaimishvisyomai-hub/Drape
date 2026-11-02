Add-Type -AssemblyName System.Drawing

$cropsDir = (Resolve-Path "crops").Path
$targetBmp = [System.Drawing.Bitmap]::FromFile((Join-Path $cropsDir "target_card.png"))
$prevBmp = [System.Drawing.Bitmap]::FromFile((Join-Path $cropsDir "current_card.png"))
$newBmp = [System.Drawing.Bitmap]::FromFile((Join-Path $cropsDir "hybrid_draped_result.png"))

$targetH = 545
$targetW = 370

$prevH = 545
$prevW = [int]($prevBmp.Width * ($targetH / $prevBmp.Height))

$newH = 545
$newW = [int]($newBmp.Width * ($targetH / $newBmp.Height))

$totalW = $targetW + $prevW + $newW + 80
$totalH = $targetH + 80

$compBmp = New-Object System.Drawing.Bitmap($totalW, $totalH)
$g = [System.Drawing.Graphics]::FromImage($compBmp)
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.Clear([System.Drawing.Color]::FromArgb(15, 23, 42))

$fontTitle = New-Object System.Drawing.Font("Arial", 13, [System.Drawing.FontStyle]::Bold)
$fontLabel = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)
$brushGold = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(212, 163, 71))
$brushRed = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(239, 68, 68))
$brushGreen = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(34, 197, 94))

$g.DrawString("SAREE DRAPE ENGINE - VISUAL COMPARISON MATRIX", $fontTitle, $brushGold, 20, 12)

# Panel 1: Target Reference (SareeViz)
$x1 = 20
$y1 = 45
$g.DrawString("TARGET (SareeViz Preview)", $fontLabel, $brushGold, $x1, $y1)
$g.DrawImage($targetBmp, [System.Drawing.Rectangle]::new($x1, $y1 + 20, $targetW, $targetH))

# Panel 2: Previous Defect
$x2 = $x1 + $targetW + 20
$g.DrawString("PREVIOUS (White Gap Defect)", $fontLabel, $brushRed, $x2, $y1)
$g.DrawImage($prevBmp, [System.Drawing.Rectangle]::new($x2, $y1 + 20, $prevW, $prevH))

# Panel 3: Corrected Output
$x3 = $x2 + $prevW + 20
$g.DrawString("CORRECTED OUTPUT (Hybrid Engine)", $fontLabel, $brushGreen, $x3, $y1)
$g.DrawImage($newBmp, [System.Drawing.Rectangle]::new($x3, $y1 + 20, $newW, $newH))

$targetBmp.Dispose()
$prevBmp.Dispose()
$newBmp.Dispose()

$compPath = Join-Path $cropsDir "before_after_target_comparison.png"
$compBmp.Save($compPath, [System.Drawing.Imaging.ImageFormat]::Png)
$compBmp.Dispose()
$g.Dispose()

Write-Host "Saved comparison matrix to: $compPath"

