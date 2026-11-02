Add-Type -AssemblyName System.Drawing
$img = [System.Drawing.Bitmap]::FromFile((Resolve-Path "crops/raw_uploaded_saree.jpg"))

# Let's save a 600x600 crop around Y=1100 to 1600
$rect = New-Object System.Drawing.Rectangle(0, 1100, $img.Width, 500)
$crop = $img.Clone($rect, $img.PixelFormat)
$crop.Save("crops/debug_lower_saree.png", [System.Drawing.Imaging.ImageFormat]::Png)
$crop.Dispose()
$img.Dispose()
Write-Host "debug_lower_saree.png saved"

