Add-Type -AssemblyName System.Drawing

$saree = [System.Drawing.Bitmap]::FromFile('crops/raw_uploaded_saree.jpg')
$w = $saree.Width
$h = $saree.Height

Write-Host "Scanning specific features in raw saree..."

# 1. Zari Stripe Bands: Y from 900 to 1150
Write-Host "`n--- Zari Stripes (Y=900..1150) ---"
for ($y = 890; $y -le 1140; $y += 15) {
    $c = $saree.GetPixel([int]($w * 0.5), $y)
    $v = [Math]::Round($y / $h, 4)
    Write-Host "Y=$y (V=$v): ($($c.R), $($c.G), $($c.B))"
}

# 2. Lotus & Twin Swans: Y from 1100 to 1400
Write-Host "`n--- Lotus & Swans (Y=1100..1400) ---"
for ($y = 1140; $y -le 1380; $y += 15) {
    $c = $saree.GetPixel([int]($w * 0.5), $y)
    $v = [Math]::Round($y / $h, 4)
    Write-Host "Y=$y (V=$v): ($($c.R), $($c.G), $($c.B))"
}

# 3. Lower Zari bands and hem: Y from 1350 to 1600
Write-Host "`n--- Lower Zari Bands & Hem (Y=1350..1600) ---"
for ($y = 1380; $y -le 1590; $y += 15) {
    $c = $saree.GetPixel([int]($w * 0.5), $y)
    $v = [Math]::Round($y / $h, 4)
    Write-Host "Y=$y (V=$v): ($($c.R), $($c.G), $($c.B))"
}

# 4. Borders: X from 0 to 960 at Y = 500 (body)
Write-Host "`n--- Left & Right Borders at Y=500 ---"
for ($x = 0; $x -lt $w; $x += 20) {
    $c = $saree.GetPixel($x, 500)
    $u = [Math]::Round($x / $w, 4)
    Write-Host "X=$x (U=$u): ($($c.R), $($c.G), $($c.B))"
}

$saree.Dispose()

