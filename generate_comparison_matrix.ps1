Add-Type -AssemblyName System.Drawing

$prevPath = "C:\Users\CORE i7\.gemini\antigravity\brain\02f32bd2-18d1-4ceb-a44b-30d096678914\.user_uploaded\media_1793441720341_35b8af94.jpg"
$newPath  = Resolve-Path "crops/hybrid_draped_result.png"
$tgtPath  = "C:\Users\CORE i7\.gemini\antigravity\brain\02f32bd2-18d1-4ceb-a44b-30d096678914\.user_uploaded\media_1793441760113_87a2f0bd.jpg"

$prevImg = [System.Drawing.Bitmap]::FromFile($prevPath)
$newFull = [System.Drawing.Bitmap]::FromFile($newPath)
$tgtImg  = [System.Drawing.Bitmap]::FromFile($tgtPath)

# Crop the model region from newFull (2400x3600):
# The model stands from X ~ 400 to 2350, Y ~ 350 to 3500
$modelRect = New-Object System.Drawing.Rectangle(450, 400, 1900, 3100)
$newCrop = $newFull.Clone($modelRect, $newFull.PixelFormat)

# Output canvas: 3 panels of 600 x 900 each
$panelW = 600
$panelH = 900
$bannerH = 60
$outW = $panelW * 3
$outH = $panelH + $bannerH

$outBmp = New-Object System.Drawing.Bitmap($outW, $outH)
$g = [System.Drawing.Graphics]::FromImage($outBmp)
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$g.Clear([System.Drawing.Color]::FromArgb(26, 27, 30))

# Draw Header Banners
$fontTitle = New-Object System.Drawing.Font("Arial", 16, [System.Drawing.FontStyle]::Bold)
$fontSub = New-Object System.Drawing.Font("Arial", 11, [System.Drawing.FontStyle]::Regular)
$brushWhite = [System.Drawing.Brushes]::White
$brushGold = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(234, 179, 8))
$brushGreen = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(34, 197, 94))
$brushRed = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(239, 68, 68))

# Panel 1: Previous Output
$g.FillRectangle((New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(40, 20, 20))), 0, 0, $panelW, $bannerH)
$g.DrawString("BEFORE: Visual Seam & Swans Defect", $fontTitle, $brushRed, 15, 10)
$g.DrawString("White slit on pallu • Lower swans dominating • Skirt border inverted", $fontSub, $brushWhite, 15, 34)
$g.DrawImage($prevImg, 0, $bannerH, $panelW, $panelH)

# Panel 2: Corrected Output
$g.FillRectangle((New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(20, 45, 25))), $panelW, 0, $panelW, $bannerH)
$g.DrawString("AFTER: Corrected WebGL Hybrid Drape", $fontTitle, $brushGreen, $panelW + 15, 10)
$g.DrawString("0 white gaps • Centered Red Lotus • Continuous vertical front border", $fontSub, $brushWhite, $panelW + 15, 34)
$g.DrawImage($newCrop, $panelW, $bannerH, $panelW, $panelH)

# Panel 3: SareeViz Target
$g.FillRectangle((New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(30, 35, 45))), $panelW * 2, 0, $panelW, $bannerH)
$g.DrawString("TARGET: SareeViz Ground Truth", $fontTitle, $brushGold, $panelW * 2 + 15, 10)
$g.DrawString("Continuous flowing pallu • Central red lotus • Straight front border", $fontSub, $brushWhite, $panelW * 2 + 15, 34)
$g.DrawImage($tgtImg, $panelW * 2, $bannerH, $panelW, $panelH)

# Draw dividing vertical lines
$penLine = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(80, 80, 80), 2)
$g.DrawLine($penLine, $panelW, 0, $panelW, $outH)
$g.DrawLine($penLine, $panelW * 2, 0, $panelW * 2, $outH)

$outPath = "crops/visual_audit_comparison_matrix.png"
$outBmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)

$artPath = "C:\Users\CORE i7\.gemini\antigravity\brain\02f32bd2-18d1-4ceb-a44b-30d096678914\visual_audit_comparison_matrix.png"
$outBmp.Save($artPath, [System.Drawing.Imaging.ImageFormat]::Png)

# Also copy hybrid_draped_result.png to artifacts
$newCrop.Save("C:\Users\CORE i7\.gemini\antigravity\brain\02f32bd2-18d1-4ceb-a44b-30d096678914\hybrid_draped_result.png", [System.Drawing.Imaging.ImageFormat]::Png)

$g.Dispose()
$outBmp.Dispose()
$prevImg.Dispose()
$newFull.Dispose()
$newCrop.Dispose()
$tgtImg.Dispose()

Write-Host "Visual comparison matrix successfully generated and saved to artifacts!"

