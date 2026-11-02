Add-Type -AssemblyName System.Drawing
function Crop-Image($src, $rect, $dst) {
    $bmp = [System.Drawing.Bitmap]::FromFile($src)
    $c = $bmp.Clone($rect, $bmp.PixelFormat)
    $c.Save($dst, [System.Drawing.Imaging.ImageFormat]::Png)
    $c.Dispose()
    $bmp.Dispose()
}

Crop-Image 'crops/raw_uploaded_saree.jpg' (New-Object System.Drawing.Rectangle(140, 0, 770, 200)) 'crops/raw_vines_row1.png'
Crop-Image 'crops/raw_uploaded_saree.jpg' (New-Object System.Drawing.Rectangle(140, 200, 770, 200)) 'crops/raw_vines_row2.png'

Write-Host 'Cropped vine rows successfully.'

