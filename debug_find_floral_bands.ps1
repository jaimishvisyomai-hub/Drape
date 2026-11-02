Add-Type -AssemblyName System.Drawing

$img = [System.Drawing.Bitmap]::FromFile((Resolve-Path "crops/raw_uploaded_saree.jpg"))

# Let's find the Y bounds of each floral band by looking for non-green pixels in X = 300..700
Write-Host "--- Scanning Floral Vine Bands (Y=0..860) ---"
$bandRows = @()
for ($y = 0; $y -lt 860; $y += 5) {
    $flowerCount = 0
    for ($x = 300; $x -lt 700; $x += 10) {
        $c = $img.GetPixel($x, $y)
        # Flower petals: red or orange/gold
        if (($c.R -gt 130 -and $c.G -lt 80 -and $c.B -lt 80) -or ($c.R -gt 160 -and $c.G -gt 130 -and $c.B -lt 110)) {
            $flowerCount++
        }
    }
    if ($flowerCount -gt 3) {
        $bandRows += $y
    }
}

# Group contiguous rows into bands
$bands = @()
$currentBand = @()
for ($i = 0; $i -lt $bandRows.Count; $i++) {
    if ($currentBand.Count -eq 0 -or ($bandRows[$i] - $currentBand[-1]) -le 15) {
        $currentBand += $bandRows[$i]
    } else {
        $bands += ,$currentBand
        $currentBand = @($bandRows[$i])
    }
}
if ($currentBand.Count -gt 0) { $bands += ,$currentBand }

$bIdx = 1
foreach ($b in $bands) {
    $y0 = $b[0]; $y1 = $b[-1]
    $v0 = [Math]::Round($y0/1600, 3); $v1 = [Math]::Round($y1/1600, 3)
    $h = $y1 - $y0
    Write-Host "Band $bIdx : Y=[$y0 .. $y1] (V: $v0 .. $v1), height=$h px"
    $bIdx++
}

$img.Dispose()

