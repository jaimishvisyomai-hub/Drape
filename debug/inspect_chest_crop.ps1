Add-Type -AssemblyName System.Drawing

$crop = [System.Drawing.Bitmap]::FromFile('crops/target_chest_crop.png')
$w = $crop.Width
$h = $crop.Height
Write-Host "Chest crop size: $w x $h"

for ($x = 0; $x -lt $w; $x += 15) {
    $c = $crop.GetPixel($x, [int]($h * 0.35))
    Write-Host "X=$x ($([Math]::Round($x / $w, 2))) -> ($($c.R), $($c.G), $($c.B))"
}
$crop.Dispose()

