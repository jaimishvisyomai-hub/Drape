Add-Type -AssemblyName System.Drawing

$rawPath = Join-Path (Get-Location) "crops/raw_uploaded_saree.jpg"
$rawImg = [System.Drawing.Bitmap]::FromFile($rawPath)
$W = $rawImg.Width
$H = $rawImg.Height

Write-Host "Raw image dimensions: $W x $H"

# 1. Full Pallu Section (Image 1 region: y from ~58% to 100%)
$y0 = [int]($H * 0.58)
$hCrop = $H - $y0
$rectPallu = New-Object System.Drawing.Rectangle(0, $y0, $W, $hCrop)
$cropPallu = $rawImg.Clone($rectPallu, $rawImg.PixelFormat)
$cropPallu.Save((Join-Path (Get-Location) "crops/cropped_pallu_section.jpg"), [System.Drawing.Imaging.ImageFormat]::Jpeg)
$cropPallu.Dispose()
Write-Host "Saved: crops/cropped_pallu_section.jpg"

# 2. Saree Body (Floral vines for Chest & Skirt Pleats: y from 0% to 58%)
$rectBody = New-Object System.Drawing.Rectangle(0, 0, $W, $y0)
$cropBody = $rawImg.Clone($rectBody, $rawImg.PixelFormat)
$cropBody.Save((Join-Path (Get-Location) "crops/cropped_saree_body_section.jpg"), [System.Drawing.Imaging.ImageFormat]::Jpeg)
$cropBody.Dispose()
Write-Host "Saved: crops/cropped_saree_body_section.jpg"

# 3. Chest Wrap Slice (Neckline gold border + diagonal floral vine body: y from 10% to 50%)
$rectChest = New-Object System.Drawing.Rectangle(0, [int]($H * 0.10), $W, [int]($H * 0.40))
$cropChest = $rawImg.Clone($rectChest, $rawImg.PixelFormat)
$cropChest.Save((Join-Path (Get-Location) "crops/cropped_chest_wrap_slice.jpg"), [System.Drawing.Imaging.ImageFormat]::Jpeg)
$cropChest.Dispose()
Write-Host "Saved: crops/cropped_chest_wrap_slice.jpg"

# 4. Pleat Fold Unit (Vertical skirt pleat slice: x from 10% to 45%, y from 15% to 58%)
$rectPleat = New-Object System.Drawing.Rectangle([int]($W * 0.10), [int]($H * 0.15), [int]($W * 0.35), [int]($H * 0.43))
$cropPleat = $rawImg.Clone($rectPleat, $rawImg.PixelFormat)
$cropPleat.Save((Join-Path (Get-Location) "crops/cropped_skirt_pleats_slice.jpg"), [System.Drawing.Imaging.ImageFormat]::Jpeg)
$cropPleat.Dispose()
Write-Host "Saved: crops/cropped_skirt_pleats_slice.jpg"

# 5. Side Gold Zari Border Strip (vertical border running down the side)
$rectBorder = New-Object System.Drawing.Rectangle(0, 0, [int]($W * 0.16), $H)
$cropBorder = $rawImg.Clone($rectBorder, $rawImg.PixelFormat)
$cropBorder.Save((Join-Path (Get-Location) "crops/cropped_side_zari_border.jpg"), [System.Drawing.Imaging.ImageFormat]::Jpeg)
$cropBorder.Dispose()
Write-Host "Saved: crops/cropped_side_zari_border.jpg"

$rawImg.Dispose()
Write-Host "All meaningful crops generated successfully."
