Add-Type -AssemblyName System.Drawing

$img = [System.Drawing.Bitmap]::FromFile((Resolve-Path "crops/raw_uploaded_saree.jpg"))

# Sample down column X = 50 (in the silver border)
Write-Host "--- Scanning Silver Border Repeat at X=50 ---"
$peaks = @()
for ($y = 0; $y -lt 1600; $y += 5) {
    $c = $img.GetPixel(50, $y)
    # Bright silver medallion has high brightness: (R+G+B)/3 > 180
    $bright = ($c.R + $c.G + $c.B) / 3
    if ($bright -gt 180) {
        $peaks += $y
    }
}

# Group peaks to find centers of repeating medallions
$medallions = @()
$current = @()
for ($i = 0; $i -lt $peaks.Count; $i++) {
    if ($current.Count -eq 0 -or ($peaks[$i] - $current[-1]) -le 15) {
        $current += $peaks[$i]
    } else {
        $medallions += [int](($current[0] + $current[-1]) / 2)
        $current = @($peaks[$i])
    }
}
if ($current.Count -gt 0) { $medallions += [int](($current[0] + $current[-1]) / 2) }

Write-Host "Found $($medallions.Count) repeating medallions at Y:"
for ($i = 0; $i -lt $medallions.Count; $i++) {
    $y = $medallions[$i]
    $v = [Math]::Round($y / 1600, 3)
    $diff = if ($i -gt 0) { $y - $medallions[$i-1] } else { 0 }
    Write-Host "Medallion $i at Y=$y (V=$v), distance from prev=$diff px"
}

$img.Dispose()

