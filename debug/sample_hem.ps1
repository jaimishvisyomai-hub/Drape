Add-Type -AssemblyName System.Drawing

$p = (Resolve-Path "crops/current_exact_card.png").Path
$bmp = [System.Drawing.Bitmap]::FromFile($p)

Write-Host "Scanning bottom hem in current_exact_card at Y=415 (height $($bmp.Height)):"
for ($x = 10; $x -le 90; $x += 5) {
    $c = $bmp.GetPixel($x, 415)
    Write-Host "X=$x : R=$($c.R), G=$($c.G), B=$($c.B)"
}

$bmp.Dispose()

