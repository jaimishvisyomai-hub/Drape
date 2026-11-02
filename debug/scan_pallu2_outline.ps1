Add-Type -AssemblyName System.Drawing

$mPallu2 = [System.Drawing.Bitmap]::FromFile('drape-lab/mask_PALLU_02.png')
$w = $mPallu2.Width
$h = $mPallu2.Height

for ($y = 0; $y -lt $h; $y += 45) {
    $minX = $w
    $maxX = 0
    $count = 0
    for ($x = 0; $x -lt $w; $x++) {
        if ($mPallu2.GetPixel($x, $y).A -gt 25) {
            $count++
            if ($x -lt $minX) { $minX = $x }
            if ($x -gt $maxX) { $maxX = $x }
        }
    }
    if ($count -gt 0) {
        $normY = [Math]::Round($y / $h, 4)
        $normMinX = [Math]::Round($minX / $w, 4)
        $normMaxX = [Math]::Round($maxX / $w, 4)
        Write-Host "Y=$normY ($y) -> X: $normMinX .. $normMaxX"
    }
}
$mPallu2.Dispose()

