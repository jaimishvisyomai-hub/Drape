Add-Type -AssemblyName System.Drawing

$p1 = (Resolve-Path "C:/Users/CORE i7/.gemini/antigravity/brain/02f32bd2-18d1-4ceb-a44b-30d096678914/.user_uploaded/media_1793428446789_ef4e3b17.jpg").Path
$bmp1 = [System.Drawing.Bitmap]::FromFile($p1)
$rect1 = New-Object System.Drawing.Rectangle(496, 129, 299, 448)
$crop1 = $bmp1.Clone($rect1, $bmp1.PixelFormat)
$crop1.Save("crops/current_exact_card.png", [System.Drawing.Imaging.ImageFormat]::Png)
$crop1.Dispose()
$bmp1.Dispose()

$p2 = (Resolve-Path "C:/Users/CORE i7/.gemini/antigravity/brain/02f32bd2-18d1-4ceb-a44b-30d096678914/.user_uploaded/media_1793428452712_e5976dfa.jpg").Path
$bmp2 = [System.Drawing.Bitmap]::FromFile($p2)
$rect2 = New-Object System.Drawing.Rectangle(332, 2, 360, 584)
$crop2 = $bmp2.Clone($rect2, $bmp2.PixelFormat)
$crop2.Save("crops/sareeviz_exact_card.png", [System.Drawing.Imaging.ImageFormat]::Png)
$crop2.Dispose()
$bmp2.Dispose()

Write-Host "Both exact cards cropped successfully!"

