Add-Type -AssemblyName System.Drawing

$p = (Resolve-Path "C:/Users/CORE i7/.gemini/antigravity/brain/02f32bd2-18d1-4ceb-a44b-30d096678914/.user_uploaded/media_1793428452712_e5976dfa.jpg").Path
$bmp = [System.Drawing.Bitmap]::FromFile($p)

# Scan row 250 across width to find where dark UI turns to white card
Write-Host "Scanning Image 2 at Y=250 across width $($bmp.Width):"
$cardX0 = -1; $cardX1 = -1
for ($x = 0; $x -lt $bmp.Width; $x++) {
    $c = $bmp.GetPixel($x, 250)
    # White card background: R>245, G>245, B>245
    if ($c.R -gt 240 -and $c.G -gt 240 -and $c.B -gt 240) {
        if ($cardX0 -eq -1) { $cardX0 = $x }
        $cardX1 = $x
    }
}
Write-Host "SareeViz White Card at Y=250: X=[$cardX0 .. $cardX1] (width=$($cardX1 - $cardX0))"

# Scan col $cardX0 + 10 down height
$cardY0 = -1; $cardY1 = -1
for ($y = 0; $y -lt $bmp.Height; $y++) {
    $c = $bmp.GetPixel($cardX0 + 10, $y)
    if ($c.R -gt 240 -and $c.G -gt 240 -and $c.B -gt 240) {
        if ($cardY0 -eq -1) { $cardY0 = $y }
        $cardY1 = $y
    }
}
Write-Host "SareeViz White Card Height: Y=[$cardY0 .. $cardY1] (height=$($cardY1 - $cardY0))"

# Now crop the actual white card
$rect = New-Object System.Drawing.Rectangle($cardX0, $cardY0, ($cardX1 - $cardX0), ($cardY1 - $cardY0))
$crop = $bmp.Clone($rect, $bmp.PixelFormat)
$crop.Save("crops/sv_white_card_only.png", [System.Drawing.Imaging.ImageFormat]::Png)
$crop.Dispose()
$bmp.Dispose()
Write-Host "Saved crops/sv_white_card_only.png"

