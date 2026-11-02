Add-Type -AssemblyName System.Drawing

$p = (Resolve-Path "crops/raw_uploaded_saree.jpg").Path
$bmp = [System.Drawing.Bitmap]::FromFile($p)

# Sample horizontally across Y=800
Write-Host "Horizontal profile across Y=800 (width $($bmp.Width)):"
for ($x = 0; $x -lt $bmp.Width; $x += 40) {
    $c = $bmp.GetPixel($x, 800)
    $normX = [Math]::Round($x / $bmp.Width, 3)
    Write-Host "X=$normX (px $x): R=$($c.R), G=$($c.G), B=$($c.B)"
}

$bmp.Dispose()

