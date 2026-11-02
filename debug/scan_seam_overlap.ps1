Add-Type -AssemblyName System.Drawing

$m1 = [System.Drawing.Bitmap]::FromFile('drape-lab/mask_PALLU_01.png')
$m2 = [System.Drawing.Bitmap]::FromFile('drape-lab/mask_PALLU_02.png')
$w = $m1.Width
$h = $m1.Height

for ($normY = 0.35; $normY -le 0.90; $normY += 0.05) {
    $y = [int]($normY * $h)
    $m1MaxX = 0
    $m2MinX = $w
    for ($x = 0; $x -lt $w; $x++) {
        if ($m1.GetPixel($x, $y).A -gt 25) {
            if ($x -gt $m1MaxX) { $m1MaxX = $x }
        }
        if ($m2.GetPixel($x, $y).A -gt 25) {
            if ($x -lt $m2MinX) { $m2MinX = $x }
        }
    }
    $norm1Max = [Math]::Round($m1MaxX / $w, 4)
    $norm2Min = [Math]::Round($m2MinX / $w, 4)
    $diff = [Math]::Round($norm1Max - $norm2Min, 4)
    Write-Host "Y=$([Math]::Round($normY,2)) -> P1_MaxX: $norm1Max | P2_MinX: $norm2Min | Overlap: $diff"
}
$m1.Dispose()
$m2.Dispose()

