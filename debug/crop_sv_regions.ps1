Add-Type -AssemblyName System.Drawing

$p = (Resolve-Path "crops/sareeviz_target_card.png").Path
$bmp = [System.Drawing.Bitmap]::FromFile($p)
Write-Host "sareeviz_target_card size: $($bmp.Width) x $($bmp.Height)"

# 1. Crop the Pallu in SareeViz
# Looking at the card (361 x 546):
# Pallu spans x from approx 150 to 360, y from 120 to 520
$rectPallu = New-Object System.Drawing.Rectangle(140, 120, 220, 400)
$cropPallu = $bmp.Clone($rectPallu, $bmp.PixelFormat)
$cropPallu.Save("crops/sv_pallu_crop.png", [System.Drawing.Imaging.ImageFormat]::Png)
$cropPallu.Dispose()

# 2. Crop the Chest Wrap in SareeViz
# Spans x from 50 to 200, y from 100 to 260
$rectChest = New-Object System.Drawing.Rectangle(40, 100, 160, 160)
$cropChest = $bmp.Clone($rectChest, $bmp.PixelFormat)
$cropChest.Save("crops/sv_chest_crop.png", [System.Drawing.Imaging.ImageFormat]::Png)
$cropChest.Dispose()

# 3. Crop the Front Pleats in SareeViz
# Spans x from 30 to 180, y from 220 to 540
$rectPleats = New-Object System.Drawing.Rectangle(20, 220, 160, 320)
$cropPleats = $bmp.Clone($rectPleats, $bmp.PixelFormat)
$cropPleats.Save("crops/sv_pleats_crop.png", [System.Drawing.Imaging.ImageFormat]::Png)
$cropPleats.Dispose()

$bmp.Dispose()
Write-Host "Cropped SareeViz regions."

