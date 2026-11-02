Add-Type -AssemblyName System.Drawing

$sv = [System.Drawing.Bitmap]::FromFile((Resolve-Path "crops/sareeviz_exact_card.png"))

# Let's save a crop of the pallu in SareeViz so we can inspect it in high resolution
# In 360 x 584: pallu is from X = 130 to 350, Y = 100 to 550
$rect = New-Object System.Drawing.Rectangle(120, 100, 240, 450)
$crop = $sv.Clone($rect, $sv.PixelFormat)
$crop.Save("crops/debug_sareeviz_pallu_crop.png", [System.Drawing.Imaging.ImageFormat]::Png)
$crop.Dispose()
$sv.Dispose()
Write-Host "debug_sareeviz_pallu_crop.png saved"

