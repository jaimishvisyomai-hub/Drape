Add-Type -AssemblyName System.Drawing

$img = [System.Drawing.Bitmap]::FromFile((Resolve-Path "crops/raw_uploaded_saree.jpg"))
Write-Host "Raw Saree Image: $($img.Width) x $($img.Height)"

# 1. Left Border: measure where the silver/grey border ends
# In the border, R, G, B are roughly equal and bright (silver/grey jacquard), or have gold
# Let's inspect along Y = 400 from X = 0 to 200
Write-Host "`n--- Measuring Left Border (at Y=400) ---"
for ($x = 0; $x -lt 200; $x += 10) {
    $c = $img.GetPixel($x, 400)
    Write-Host "X=$x : R=$($c.R), G=$($c.G), B=$($c.B)"
}

# 2. Right Border: measure from X = 800 to 960
Write-Host "`n--- Measuring Right Border (at Y=400) ---"
for ($x = 850; $x -lt $img.Width; $x += 10) {
    $c = $img.GetPixel($x, 400)
    Write-Host "X=$x : R=$($c.R), G=$($c.G), B=$($c.B)"
}

# 3. Vertical profile down the middle (X = 480)
Write-Host "`n--- Vertical Profile at X=480 ---"
for ($y = 0; $y -lt $img.Height; $y += 25) {
    $c = $img.GetPixel(480, $y)
    $type = "green"
    if ($c.R -gt 150 -and $c.G -gt 130 -and $c.B -lt 110) { $type = "GOLD" }
    elseif ($c.R -gt 130 -and $c.G -lt 80 -and $c.B -lt 80) { $type = "RED" }
    elseif ($c.R -gt 200 -and $c.G -gt 200 -and $c.B -gt 180) { $type = "WHITE" }
    Write-Host "Y=$y ($([Math]::Round($y/1600, 3))) : [$($c.R),$($c.G),$($c.B)] -> $type"
}

$img.Dispose()

