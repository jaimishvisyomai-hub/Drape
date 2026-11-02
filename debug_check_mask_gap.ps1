Add-Type -AssemblyName System.Drawing

$m1 = [System.Drawing.Bitmap]::FromFile((Resolve-Path "drape-lab/mask_PALLU_01.png"))
$m2 = [System.Drawing.Bitmap]::FromFile((Resolve-Path "drape-lab/mask_PALLU_02.png"))

# Check if there is any pixel where the union of masks has a gap inside the pallu bounding box
# Let's inspect along rows Y = 600, 800, 1000, 1200, 1400, 1600 (in mask coordinates 1200x1800)
for ($y = 600; $y -lt 1650; $y += 50) {
    # Find minX where either mask is > 0, and maxX where either mask is > 0
    $minX = 1200; $maxX = 0
    for ($x = 200; $x -lt 1180; $x++) {
        $a1 = $m1.GetPixel($x, $y).A
        $a2 = $m2.GetPixel($x, $y).A
        if ($a1 -gt 10 -or $a2 -gt 10) {
            if ($x -lt $minX) { $minX = $x }
            if ($x -gt $maxX) { $maxX = $x }
        }
    }
    # Now check if there is any gap between minX and maxX
    $gapStart = -1
    for ($x = $minX; $x -le $maxX; $x++) {
        $a1 = $m1.GetPixel($x, $y).A
        $a2 = $m2.GetPixel($x, $y).A
        if ($a1 -le 10 -and $a2 -le 10) {
            if ($gapStart -eq -1) { $gapStart = $x }
        } else {
            if ($gapStart -ne -1) {
                Write-Host "GAP in masks at Y=$y : X=[$gapStart .. $($x-1)]"
                $gapStart = -1
            }
        }
    }
}
$m1.Dispose()
$m2.Dispose()
Write-Host "Mask gap check complete."

