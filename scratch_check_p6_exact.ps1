Add-Type -AssemblyName System.Drawing
$bmp = [System.Drawing.Bitmap]::FromFile((Join-Path (Get-Location) 'drape-lab/mask_PATLI_06.png'))
$w = $bmp.Width
$h = $bmp.Height

$ys = @(0.504, 0.578, 0.648, 0.717, 0.786, 0.854, 0.927)
for ($i=0; $i -lt $ys.Length; $i++) {
    $yNorm = $ys[$i]
    $y = [int]($yNorm * $h)
    $minX = $w; $maxX = -1
    for ($x = 0; $x -lt $w; $x++) {
        if ($bmp.GetPixel($x, $y).A -gt 20) {
            if ($x -lt $minX) { $minX = $x }
            if ($x -gt $maxX) { $maxX = $x }
        }
    }
    if ($maxX -ge $minX) {
        Write-Host ('Row {0} (Y={1:N3}): minX={2:N3} maxX={3:N3} (width={4:N3})' -f $i, $yNorm, ($minX/$w), ($maxX/$w), (($maxX-$minX)/$w))
    } else {
        Write-Host ('Row {0} (Y={1:N3}): EMPTY' -f $i, $yNorm)
    }
}
$bmp.Dispose()

