Add-Type -AssemblyName System.Drawing

$p = (Resolve-Path "crops/raw_uploaded_saree.jpg").Path
$bmp = [System.Drawing.Bitmap]::FromFile($p)
Write-Host "raw_uploaded_saree.jpg: $($bmp.Width) x $($bmp.Height)"

# Inspect vertical segments from y=0 to y=Height
# We want to identify the zones:
# 1. Top to middle: Body fabric (green with small flowers)
# 2. Middle to bottom: What is in the pallu panel?
# Let's sample colors down a vertical line at x = Width / 2
$step = [int]($bmp.Height / 20)
for ($y = 0; $y -lt $bmp.Height; $y += $step) {
    $c = $bmp.GetPixel([int]($bmp.Width * 0.5), $y)
    $normY = [Math]::Round($y / $bmp.Height, 3)
    Write-Host "Y=$normY (px $y): R=$($c.R), G=$($c.G), B=$($c.B)"
}

$bmp.Dispose()

