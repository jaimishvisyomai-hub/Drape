Add-Type -AssemblyName System.Drawing

$m1 = [System.Drawing.Bitmap]::FromFile((Resolve-Path "drape-lab/mask_PALLU_01.png"))
$m2 = [System.Drawing.Bitmap]::FromFile((Resolve-Path "drape-lab/mask_PALLU_02.png"))

# Simulate createFilledMask with DILATE_PX = 2
$dilate = 2
$gapsFound = 0

for ($y = 600; $y -lt 1650; $y += 20) {
    # M1 minX/maxX
    $minX1 = -1; $maxX1 = -1
    for ($x = 0; $x -lt $m1.Width; $x++) {
        if ($m1.GetPixel($x, $y).A -gt 25) {
            if ($minX1 -eq -1) { $minX1 = $x }
            $maxX1 = $x
        }
    }
    # M2 minX/maxX
    $minX2 = -1; $maxX2 = -1
    for ($x = 0; $x -lt $m2.Width; $x++) {
        if ($m2.GetPixel($x, $y).A -gt 25) {
            if ($minX2 -eq -1) { $minX2 = $x }
            $maxX2 = $x
        }
    }
    
    if ($maxX1 -ne -1 -and $minX2 -ne -1) {
        # With dilation:
        $dilMaxX1 = $maxX1 + $dilate
        $dilMinX2 = $minX2 - $dilate
        if ($dilMinX2 -gt $dilMaxX1) {
            $gapsFound++
            Write-Host "GAP remaining at Y=$($y) : M1 max=$($dilMaxX1) vs M2 min=$($dilMinX2) (gap of $($dilMinX2 - $dilMaxX1) px)"
        }
    }
}
Write-Host "Test complete with DILATE_PX=$($dilate) : $($gapsFound) gaps found"
$m1.Dispose()
$m2.Dispose()
