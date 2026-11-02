Add-Type -AssemblyName System.Drawing

$crop = [System.Drawing.Bitmap]::FromFile('crops/target_pallu_crop.png')
$w = $crop.Width
$h = $crop.Height
Write-Host "Pallu crop size: $w x $h"

for ($normY = 0.10; $normY -le 0.90; $normY += 0.10) {
    $y = [int]($normY * $h)
    $maxX = 0
    for ($x = 0; $x -lt $w; $x++) {
        $c = $crop.GetPixel($x, $y)
        if ($c.R -lt 240 -or $c.G -lt 240 -or $c.B -lt 240) {
            if ($x -gt $maxX) { $maxX = $x }
        }
    }
    if ($maxX -gt 0) {
        $edgeC = $crop.GetPixel([Math]::Max(0, $maxX - 4), $y)
        Write-Host "Y=$([Math]::Round($normY,2)) (y=$y) -> MaxX=$maxX : Color=($($edgeC.R), $($edgeC.G), $($edgeC.B))"
    }
}
$crop.Dispose()

