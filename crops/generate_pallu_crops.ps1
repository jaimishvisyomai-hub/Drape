Add-Type -AssemblyName System.Drawing

$rawPath = Join-Path $PSScriptRoot "raw_uploaded_saree.jpg"
$rawImg = [System.Drawing.Bitmap]::FromFile($rawPath)
$W = $rawImg.Width
$H = $rawImg.Height

Write-Host "Raw image: ${W}x${H}"

# In Image 3:
# Pallu area is in the lower 42% (Y from 58% to 100%)
$yTop = [int]($H * 0.58)
$hPallu = $H - $yTop

# The red dividing line runs vertically down the middle between the peacocks / swans:
# Across width, x is approx 48% of W
$xSplit = [int]($W * 0.48)

# 1. Pallu 1 (Left side of cropped pallu in Image 3)
$rectP1 = New-Object System.Drawing.Rectangle(0, $yTop, $xSplit, $hPallu)
$cropP1 = $rawImg.Clone($rectP1, $rawImg.PixelFormat)
$p1Path = Join-Path $PSScriptRoot "cropped_pallu_1_left.jpg"
$cropP1.Save($p1Path, [System.Drawing.Imaging.ImageFormat]::Jpeg)
$cropP1.Dispose()
Write-Host "Saved Pallu 1 (Left): $p1Path"

# 2. Pallu 2 (Right side of cropped pallu in Image 3)
$rectP2 = New-Object System.Drawing.Rectangle($xSplit, $yTop, ($W - $xSplit), $hPallu)
$cropP2 = $rawImg.Clone($rectP2, $rawImg.PixelFormat)
$p2Path = Join-Path $PSScriptRoot "cropped_pallu_2_right.jpg"
$cropP2.Save($p2Path, [System.Drawing.Imaging.ImageFormat]::Jpeg)
$cropP2.Dispose()
Write-Host "Saved Pallu 2 (Right): $p2Path"

$rawImg.Dispose()
