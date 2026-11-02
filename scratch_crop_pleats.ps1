Add-Type -AssemblyName System.Drawing
function Crop-Image($src, $rect, $dst) {
    $bmp = [System.Drawing.Bitmap]::FromFile($src)
    $c = $bmp.Clone($rect, $bmp.PixelFormat)
    $c.Save($dst, [System.Drawing.Imaging.ImageFormat]::Png)
    $c.Dispose()
    $bmp.Dispose()
}

Crop-Image 'C:\Users\CORE i7\.gemini\antigravity\brain\02f32bd2-18d1-4ceb-a44b-30d096678914\.user_uploaded\media_1793595614500_32ba2d80.jpg' (New-Object System.Drawing.Rectangle(10, 320, 160, 390)) 'crops/user_pleats_cur.png'
Crop-Image 'C:\Users\CORE i7\.gemini\antigravity\brain\02f32bd2-18d1-4ceb-a44b-30d096678914\.user_uploaded\media_1793595637172_bc78bab3.jpg' (New-Object System.Drawing.Rectangle(10, 390, 190, 480)) 'crops/user_pleats_sv.png'

Write-Host 'Cropped pleats successfully.'

