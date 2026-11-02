Add-Type -AssemblyName System.Drawing

$p = (Resolve-Path "drape-lab/mask_PATLI_01_NEW.png").Path
$bmp = [System.Drawing.Bitmap]::FromFile($p)
$yPx = [int](0.92 * $bmp.Height)
Write-Host "Scanning mask_PATLI_01_NEW at Y=0.92 (px $yPx):"
for ($x = 20; $x -le 300; $x += 20) {
    $a = $bmp.GetPixel($x, $yPx).A
    $normX = [Math]::Round($x / $bmp.Width, 3)
    Write-Host "X=$normX (px $x): Alpha=$a"
}
$bmp.Dispose()

