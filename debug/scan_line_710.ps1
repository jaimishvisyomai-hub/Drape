Add-Type -AssemblyName System.Drawing

$diff = [System.Drawing.Bitmap]::FromFile('crops/uncovered_regions_difference.png')
$m1 = [System.Drawing.Bitmap]::FromFile('drape-lab/mask_PALLU_01.png')
$m2 = [System.Drawing.Bitmap]::FromFile('drape-lab/mask_PALLU_02.png')
$w = $diff.Width
$h = $diff.Height

for ($x = 520; $x -le 620; $x += 10) {
    $normX = [Math]::Round($x / $w, 4)
    $cDiff = $diff.GetPixel($x, 710)
    $a1 = $m1.GetPixel($x, 710).A
    $a2 = $m2.GetPixel($x, 710).A
    $isRed = ($cDiff.R -gt 200 -and $cDiff.G -lt 50)
    Write-Host "X=$x ($normX) -> P1_A=$a1 P2_A=$a2 IsRed=$isRed"
}
$diff.Dispose()
$m1.Dispose()
$m2.Dispose()

