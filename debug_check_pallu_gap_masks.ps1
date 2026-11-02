Add-Type -AssemblyName System.Drawing

# Check drape-lab/mask_PALLU_01.png and mask_PALLU_02.png at Y = 1200..1450 (scaled to 1200x1800 mask: Y = 600..725)
$m1 = [System.Drawing.Bitmap]::FromFile((Resolve-Path "drape-lab/mask_PALLU_01.png"))
$m2 = [System.Drawing.Bitmap]::FromFile((Resolve-Path "drape-lab/mask_PALLU_02.png"))

Write-Host "Mask size: $($m1.Width) x $($m1.Height)"
# In 1200x1800: Y = 600 is YNorm = 0.333, Y = 700 is YNorm = 0.389
for ($y = 600; $y -le 725; $y += 25) {
    for ($x = 550; $x -le 660; $x += 20) {
        $a1 = $m1.GetPixel($x, $y).A
        $a2 = $m2.GetPixel($x, $y).A
        $xN = [Math]::Round($x / $m1.Width, 3)
        $yN = [Math]::Round($y / $m1.Height, 3)
        Write-Host "X=$x ($xN), Y=$y ($yN): A1=$a1, A2=$a2"
    }
}
$m1.Dispose()
$m2.Dispose()

