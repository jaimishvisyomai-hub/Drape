Add-Type -AssemblyName System.Drawing
function Crop-Image($src, $rect, $dst) {
    $bmp = [System.Drawing.Bitmap]::FromFile($src)
    $c = $bmp.Clone($rect, $bmp.PixelFormat)
    $c.Save($dst, [System.Drawing.Imaging.ImageFormat]::Png)
    $c.Dispose()
    $bmp.Dispose()
}

Crop-Image 'crops/raw_uploaded_saree.jpg' (New-Object System.Drawing.Rectangle(150, 860, 700, 220)) 'crops/raw_stripes_zone4.png'
Crop-Image 'C:\Users\CORE i7\.gemini\antigravity\brain\02f32bd2-18d1-4ceb-a44b-30d096678914\.user_uploaded\media_1793595637172_bc78bab3.jpg' (New-Object System.Drawing.Rectangle(140, 520, 260, 160)) 'crops/sv_stripes_crop.png'
Crop-Image 'C:\Users\CORE i7\.gemini\antigravity\brain\02f32bd2-18d1-4ceb-a44b-30d096678914\.user_uploaded\media_1793595614500_32ba2d80.jpg' (New-Object System.Drawing.Rectangle(110, 430, 220, 140)) 'crops/cur_stripes_crop.png'

Write-Host 'Cropped stripes successfully.'

