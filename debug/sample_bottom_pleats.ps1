Add-Type -AssemblyName System.Drawing

$p = (Resolve-Path "crops/current_exact_card.png").Path
$bmp = [System.Drawing.Bitmap]::FromFile($p)

# Scan row Y = 400 (approx 90% height) across X from 10 to 80
Write-Host "Scanning bottom pleats in current_exact_card at Y=400 (height $($bmp.Height)):"
for ($x = 10; $x -le 90; $x += 5) {
    $c = $bmp.GetPixel($x, 400)
    Write-Host "X=$x : R=$($c.R), G=$($c.G), B=$($c.B)"
}

$bmp.Dispose()

