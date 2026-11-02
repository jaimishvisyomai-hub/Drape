Add-Type -AssemblyName System.Drawing
$imgPath = Resolve-Path "crops/raw_uploaded_saree.jpg"
$img = [System.Drawing.Bitmap]::FromFile($imgPath)

# Let's crop strips of raw saree and save them to inspect
$stripHeight = 200
for ($y = 0; $y -lt $img.Height; $y += $stripHeight) {
    $rect = New-Object System.Drawing.Rectangle(0, $y, $img.Width, [Math]::Min($stripHeight, $img.Height - $y))
    $crop = $img.Clone($rect, $img.PixelFormat)
    $vStart = [Math]::Round($y / $img.Height, 2)
    $vEnd = [Math]::Round(($y + $rect.Height) / $img.Height, 2)
    $outName = "debug_saree_y_${y}_v_${vStart}_${vEnd}.png"
    # Just check average color
    $crop.Dispose()
}

Write-Host "Checking target sareeviz image..."
$svPath = Resolve-Path "crops/sareeviz_exact_card.png"
if (Test-Path $svPath) {
    $svImg = [System.Drawing.Bitmap]::FromFile($svPath)
    Write-Host "SareeViz card: $($svImg.Width) x $($svImg.Height)"
    $svImg.Dispose()
}

$img.Dispose()

