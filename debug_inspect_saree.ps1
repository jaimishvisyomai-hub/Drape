Add-Type -AssemblyName System.Drawing
$imgPath = Resolve-Path "crops/raw_uploaded_saree.jpg"
$img = [System.Drawing.Bitmap]::FromFile($imgPath)
Write-Host "Width: $($img.Width), Height: $($img.Height)"

# Sample down the vertical center line (x = 480) every 40 pixels
for ($y = 0; $y -lt $img.Height; $y += 50) {
    $c = $img.GetPixel(480, $y)
    $v = [Math]::Round($y / $img.Height, 3)
    Write-Host "Y=$y (V=$v): R=$($c.R), G=$($c.G), B=$($c.B)"
}
$img.Dispose()

