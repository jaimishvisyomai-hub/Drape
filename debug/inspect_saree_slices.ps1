Add-Type -AssemblyName System.Drawing

$p = (Resolve-Path "crops/raw_uploaded_saree.jpg").Path
$bmp = [System.Drawing.Bitmap]::FromFile($p)

for ($yFrac = 0.50; $yFrac -le 0.95; $yFrac += 0.05) {
    $y = [int]($yFrac * $bmp.Height)
    $h = [int](0.05 * $bmp.Height)
    $rect = New-Object System.Drawing.Rectangle(0, $y, $bmp.Width, $h)
    $slice = $bmp.Clone($rect, $bmp.PixelFormat)
    $yPct = [int]($yFrac * 100)
    $slicePath = "crops/slice_y_${yPct}.jpg"
    $slice.Save($slicePath, [System.Drawing.Imaging.ImageFormat]::Jpeg)
    $slice.Dispose()
    Write-Host "Saved slice Y=${yFrac} to ${slicePath}"
}

$bmp.Dispose()
