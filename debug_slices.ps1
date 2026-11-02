Add-Type -AssemblyName System.Drawing
$imgPath = Resolve-Path "crops/raw_uploaded_saree.jpg"
$img = [System.Drawing.Bitmap]::FromFile($imgPath)

# Let's save 8 slices of raw saree as images so we can inspect them or measure them
for ($i = 0; $i -lt 8; $i++) {
    $yStart = [int]($i * $img.Height / 8)
    $h = [int]($img.Height / 8)
    $rect = New-Object System.Drawing.Rectangle(0, $yStart, $img.Width, $h)
    $slice = $img.Clone($rect, $img.PixelFormat)
    $slice.Save("crops/debug_slice_$i.png", [System.Drawing.Imaging.ImageFormat]::Png)
    $slice.Dispose()
    Write-Host "Slice $i : Y=[$yStart .. $($yStart + $h)], V=[$($i/8) .. $(($i+1)/8)]"
}
$img.Dispose()

