Add-Type -AssemblyName System.Drawing
$img = [System.Drawing.Bitmap]::FromFile((Resolve-Path "crops/raw_uploaded_saree.jpg"))

# Let's inspect along the center column x=480, and also x=300, x=600
# to see every feature from Y=800 to 1600
for ($y = 800; $y -lt 1600; $y += 25) {
    $v = [Math]::Round($y / 1600, 3)
    $c300 = $img.GetPixel(300, $y)
    $c480 = $img.GetPixel(480, $y)
    $c600 = $img.GetPixel(600, $y)
    
    # Classify feature
    $feature = "body"
    if ($c480.R -gt 150 -and $c480.G -gt 130 -and $c480.B -lt 120) { $feature = "GOLD_STRIPE/BORDER" }
    elseif ($c480.R -gt 130 -and $c480.G -lt 80 -and $c480.B -lt 80) { $feature = "RED_PETAL" }
    elseif ($c480.R -gt 200 -and $c480.G -gt 190 -and $c480.B -gt 160) { $feature = "SWAN/CREAM" }
    elseif ($c480.R -gt 180 -and $c480.G -gt 120 -and $c480.B -lt 90) { $feature = "ORANGE/YELLOW_PETAL" }

    Write-Host "Y=$y (V=$v): 480=[$($c480.R),$($c480.G),$($c480.B)] -> $feature"
}
$img.Dispose()

