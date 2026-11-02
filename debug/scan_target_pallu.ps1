Add-Type -AssemblyName System.Drawing

$targetBmp = [System.Drawing.Bitmap]::FromFile('crops/sareeviz_exact_card.png')
$w = $targetBmp.Width
$h = $targetBmp.Height
Write-Host "Target size: $w x $h"

for ($y = 0; $y -lt $h; $y += 30) {
    $maxX = 0
    for ($x = [int]($w * 0.7); $x -lt $w; $x++) {
        $c = $targetBmp.GetPixel($x, $y)
        if ($c.R -lt 240 -or $c.G -lt 240 -or $c.B -lt 240) {
            if ($x -gt $maxX) { $maxX = $x }
        }
    }
    if ($maxX -gt 0) {
        Write-Host "Target Y=$([Math]::Round($y/$h, 4)) -> MaxX=$([Math]::Round($maxX/$w, 4))"
    }
}
$targetBmp.Dispose()

