Add-Type -AssemblyName System.Drawing

$p = (Resolve-Path "drape-lab/mask_PATLI_07.png").Path
$bmp = [System.Drawing.Bitmap]::FromFile($p)
Write-Host "mask_PATLI_07.png size: $($bmp.Width) x $($bmp.Height)"

# Inspect row at Y = 0.92 (approx 1656 px) across X from 0.02 to 0.25 (24 to 300 px)
$yPx = [int](0.92 * $bmp.Height)
Write-Host "Scanning mask_PATLI_07 at Y=0.92 (px $yPx):"
for ($x = 20; $x -le 300; $x += 20) {
    $a = $bmp.GetPixel($x, $yPx).A
    $normX = [Math]::Round($x / $bmp.Width, 3)
    Write-Host "X=$normX (px $x): Alpha=$a"
}

$bmp.Dispose()

