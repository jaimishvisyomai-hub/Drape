Add-Type -AssemblyName System.Drawing

$crop = [System.Drawing.Bitmap]::FromFile((Resolve-Path "crops/debug_sareeviz_pallu_crop.png"))
Write-Host "Crop size: $($crop.Width) x $($crop.Height)"

# Let's inspect along vertical line through the pallu (X = 120 in crop, which is X = 240 in sv)
for ($y = 0; $y -lt $crop.Height; $y += 15) {
    $c = $crop.GetPixel(120, $y)
    $desc = "background/other"
    if ($c.G -gt $c.R -and $c.G -gt $c.B -and $c.G -lt 80) { $desc = "GREEN_BODY" }
    elseif ($c.R -gt 130 -and $c.G -lt 80 -and $c.B -lt 80) { $desc = "RED_LOTUS" }
    elseif ($c.R -gt 150 -and $c.G -gt 120 -and $c.B -lt 110) { $desc = "GOLD_STRIPE/BORDER" }
    elseif ($c.R -gt 200 -and $c.G -gt 200 -and $c.B -gt 200) { $desc = "WHITE_BG" }

    Write-Host "Y=$y : R=$($c.R), G=$($c.G), B=$($c.B) -> $desc"
}
$crop.Dispose()

