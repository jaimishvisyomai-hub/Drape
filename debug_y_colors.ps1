Add-Type -AssemblyName System.Drawing
$img = [System.Drawing.Bitmap]::FromFile((Resolve-Path "crops/raw_uploaded_saree.jpg"))

for ($y = 800; $y -lt 1600; $y += 20) {
    # Check middle pixel
    $c = $img.GetPixel(480, $y)
    $v = [Math]::Round($y / 1600, 3)
    Write-Host "Y=$y (V=$v): R=$($c.R), G=$($c.G), B=$($c.B)"
}
$img.Dispose()

