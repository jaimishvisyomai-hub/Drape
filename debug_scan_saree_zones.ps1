Add-Type -AssemblyName System.Drawing

$img = [System.Drawing.Bitmap]::FromFile((Resolve-Path "crops/raw_uploaded_saree.jpg"))

# Find bird motifs along the left side (X = 140 to 240)
# Bird motifs have red/orange/yellow/white features
Write-Host "--- Scanning for Left Bird Motifs (X=140..240) ---"
$birdY = @()
for ($y = 0; $y -lt 950; $y += 5) {
    $redOrOrange = 0
    for ($x = 150; $x -lt 240; $x += 5) {
        $c = $img.GetPixel($x, $y)
        # Red or bright orange/yellow
        if (($c.R -gt 150 -and $c.G -lt 80 -and $c.B -lt 80) -or ($c.R -gt 180 -and $c.G -gt 130 -and $c.B -lt 100)) {
            $redOrOrange++
        }
    }
    if ($redOrOrange -gt 5) {
        $v = [Math]::Round($y / 1600, 3)
        Write-Host "Left Bird feature at Y=$y (V=$v): $redOrOrange pixels"
    }
}

# Scan stripes between Y=850 and 1150
Write-Host "`n--- Scanning Upper Stripes (Y=850..1150) ---"
for ($y = 850; $y -lt 1150; $y += 5) {
    $goldCount = 0
    for ($x = 200; $x -lt 800; $x += 10) {
        $c = $img.GetPixel($x, $y)
        if ($c.R -gt 150 -and $c.G -gt 130 -and $c.B -lt 120) {
            $goldCount++
        }
    }
    if ($goldCount -gt 25) {
        $v = [Math]::Round($y / 1600, 3)
        Write-Host "Upper Stripe at Y=$y (V=$v): $goldCount gold pixels"
    }
}

# Scan Central Medallion (Y=1100..1400)
Write-Host "`n--- Scanning Central Medallion (Y=1100..1400) ---"
$medMinX = 960; $medMaxX = 0; $medMinY = 1600; $medMaxY = 0
for ($y = 1100; $y -lt 1400; $y += 5) {
    for ($x = 150; $x -lt 850; $x += 5) {
        $c = $img.GetPixel($x, $y)
        $isMedallion = ($c.R -gt 130 -and $c.G -lt 80 -and $c.B -lt 80) -or `
                       ($c.R -gt 200 -and $c.G -gt 190 -and $c.B -gt 150) -or `
                       ($c.R -gt 170 -and $c.G -gt 120 -and $c.B -lt 90)
        if ($isMedallion) {
            if ($x -lt $medMinX) { $medMinX = $x }
            if ($x -gt $medMaxX) { $medMaxX = $x }
            if ($y -lt $medMinY) { $medMinY = $y }
            if ($y -gt $medMaxY) { $medMaxY = $y }
        }
    }
}
$u0 = [Math]::Round($medMinX/960, 3); $u1 = [Math]::Round($medMaxX/960, 3)
$v0 = [Math]::Round($medMinY/1600, 3); $v1 = [Math]::Round($medMaxY/1600, 3)
Write-Host "Central Medallion bounds: X=[$medMinX .. $medMaxX] (U: $u0 .. $u1), Y=[$medMinY .. $medMaxY] (V: $v0 .. $v1)"
Write-Host "Medallion width: $($medMaxX - $medMinX) px, height: $($medMaxY - $medMinY) px, aspect ratio: $([Math]::Round(($medMaxX - $medMinX)/($medMaxY - $medMinY), 2))"

# Scan Lower Stripes (Y=1400..1600)
Write-Host "`n--- Scanning Lower Stripes & Hem (Y=1400..1600) ---"
for ($y = 1400; $y -lt 1600; $y += 5) {
    $goldCount = 0
    for ($x = 200; $x -lt 800; $x += 10) {
        $c = $img.GetPixel($x, $y)
        if ($c.R -gt 150 -and $c.G -gt 130 -and $c.B -lt 120) {
            $goldCount++
        }
    }
    if ($goldCount -gt 25) {
        $v = [Math]::Round($y / 1600, 3)
        Write-Host "Lower Stripe/Hem at Y=$y (V=$v): $goldCount gold pixels"
    }
}

$img.Dispose()

