Add-Type -AssemblyName System.Drawing
function Crop-Image($src, $rect, $dst) {
    $bmp = [System.Drawing.Bitmap]::FromFile($src)
    $c = $bmp.Clone($rect, $bmp.PixelFormat)
    $c.Save($dst, [System.Drawing.Imaging.ImageFormat]::Png)
    $c.Dispose()
    $bmp.Dispose()
}

Crop-Image 'crops/raw_uploaded_saree.jpg' (New-Object System.Drawing.Rectangle(0, 0, 350, 250)) 'crops/raw_shoulder_corner.png'
Write-Host 'Cropped raw shoulder corner.'

