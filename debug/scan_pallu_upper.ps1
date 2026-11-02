Add-Type -AssemblyName System.Drawing

$mPallu = [System.Drawing.Bitmap]::FromFile('drape-lab/mask_PALLU_01.png')
$mw = $mPallu.Width
$mh = $mPallu.Height

$testRows = @(0.316, 0.32, 0.33, 0.34, 0.35, 0.36, 0.37, 0.38)
foreach ($normY in $testRows) {
    $my = [int]($normY * $mh)
    $minX = $mw
    $maxX = 0
    $count = 0
    for ($x = 0; $x -lt $mw; $x++) {
        if ($mPallu.GetPixel($x, $my).A -gt 25) {
            $count++
            if ($x -lt $minX) { $minX = $x }
            if ($x -gt $maxX) { $maxX = $x }
        }
    }
    Write-Host "PALLU_01 Y=$normY -> X: $([Math]::Round($minX/$mw, 4)) .. $([Math]::Round($maxX/$mw, 4)) (count=$count)"
}
$mPallu.Dispose()

