Add-Type -AssemblyName System.Drawing

$img = [System.Drawing.Bitmap]::FromFile((Resolve-Path "crops/raw_uploaded_saree.jpg"))

# Let's check rows between 850 and 1100 at X = 500
Write-Host "--- Scanning rows 850..1100 at X=500 ---"
for ($y = 850; $y -lt 1100; $y += 10) {
    $c = $img.GetPixel(500, $y)
    $v = [Math]::Round($y / 1600, 3)
    # Check if stripe:
    Write-Host "Y=$y (V=$v): [$($c.R), $($c.G), $($c.B)]"
}

# Let's check rows between 1400 and 1600 at X = 500
Write-Host "`n--- Scanning rows 1400..1600 at X=500 ---"
for ($y = 1400; $y -lt 1600; $y += 10) {
    $c = $img.GetPixel(500, $y)
    $v = [Math]::Round($y / 1600, 3)
    Write-Host "Y=$y (V=$v): [$($c.R), $($c.G), $($c.B)]"
}

$img.Dispose()

