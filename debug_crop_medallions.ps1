Add-Type -AssemblyName System.Drawing

$sv = [System.Drawing.Bitmap]::FromFile("C:\Users\CORE i7\.gemini\antigravity\brain\02f32bd2-18d1-4ceb-a44b-30d096678914\.user_uploaded\media_1793593006051_abaece7b.jpg")
$cur = [System.Drawing.Bitmap]::FromFile("C:\Users\CORE i7\.gemini\antigravity\brain\02f32bd2-18d1-4ceb-a44b-30d096678914\.user_uploaded\media_1793593009182_92517453.jpg")

# SareeViz medallion crop: X=[200 .. 560], Y=[500 .. 850]
$svRect = New-Object System.Drawing.Rectangle(200, 500, 360, 350)
$svCrop = $sv.Clone($svRect, $sv.PixelFormat)
$svCrop.Save("crops/debug_medallion_sv.png", [System.Drawing.Imaging.ImageFormat]::Png)
$svCrop.Dispose()

# Current render medallion crop: X=[150 .. 500], Y=[450 .. 750]
$curRect = New-Object System.Drawing.Rectangle(150, 450, 350, 300)
$curCrop = $cur.Clone($curRect, $cur.PixelFormat)
$curCrop.Save("crops/debug_medallion_cur.png", [System.Drawing.Imaging.ImageFormat]::Png)
$curCrop.Dispose()

$sv.Dispose()
$cur.Dispose()
Write-Host "Medallion crops saved."

