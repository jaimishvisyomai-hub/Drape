Add-Type -AssemblyName System.Drawing

$mPallu = [System.Drawing.Bitmap]::FromFile('drape-lab/mask_PALLU_01.png')
$w = $mPallu.Width
$h = $mPallu.Height

for ($i = 0; $i -lt 10; $i++) {
    $t = $i / 9.0
    $normY = 0.315 + (0.932 - 0.315) * $t
    $y = [int]($normY * $h)
    $minX = $w
    $maxX = 0
    $count = 0
    for ($dy = -2; $dy -le 2; $dy++) {
        $cy = [Math]::Max(0, [Math]::Min($h - 1, $y + $dy))
        for ($x = 0; $x -lt $w; $x++) {
            if ($mPallu.GetPixel($x, $cy).A -gt 25) {
                $count++
                if ($x -lt $minX) { $minX = $x }
                if ($x -gt $maxX) { $maxX = $x }
            }
        }
    }
    Write-Host "P1 Row $i (Y=$([Math]::Round($normY, 4))): X = $([Math]::Round($minX/$w, 4)) .. $([Math]::Round($maxX/$w, 4)) (count=$count)"
}
$mPallu.Dispose()

