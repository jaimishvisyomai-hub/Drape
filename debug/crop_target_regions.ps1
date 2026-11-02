Add-Type -AssemblyName System.Drawing

$target = [System.Drawing.Bitmap]::FromFile('C:/Users/CORE i7/.gemini/antigravity/brain/02f32bd2-18d1-4ceb-a44b-30d096678914/.user_uploaded/media_1793440789961_79d5ba07.jpg')
$w = $target.Width
$h = $target.Height

$cropRect = New-Object System.Drawing.Rectangle([int]($w * 0.12), [int]($h * 0.35), [int]($w * 0.40), [int]($h * 0.60))
$cropBmp = $target.Clone($cropRect, [System.Drawing.Imaging.PixelFormat]::Format24bppRgb)
$cropBmp.Save('crops/target_skirt_crop.png', [System.Drawing.Imaging.ImageFormat]::Png)
$cropBmp.Dispose()

$cropChest = New-Object System.Drawing.Rectangle([int]($w * 0.15), [int]($h * 0.15), [int]($w * 0.40), [int]($h * 0.28))
$cropBmp2 = $target.Clone($cropChest, [System.Drawing.Imaging.PixelFormat]::Format24bppRgb)
$cropBmp2.Save('crops/target_chest_crop.png', [System.Drawing.Imaging.ImageFormat]::Png)
$cropBmp2.Dispose()

$cropPallu = New-Object System.Drawing.Rectangle([int]($w * 0.35), [int]($h * 0.35), [int]($w * 0.60), [int]($h * 0.60))
$cropBmp3 = $target.Clone($cropPallu, [System.Drawing.Imaging.PixelFormat]::Format24bppRgb)
$cropBmp3.Save('crops/target_pallu_crop.png', [System.Drawing.Imaging.ImageFormat]::Png)
$cropBmp3.Dispose()

$target.Dispose()
Write-Host "Target crops saved successfully."

