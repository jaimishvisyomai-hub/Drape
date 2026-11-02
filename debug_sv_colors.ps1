Add-Type -AssemblyName System.Drawing
$sv = [System.Drawing.Bitmap]::FromFile((Resolve-Path "crops/sareeviz_exact_card.png"))

# Let's sample colors in the lower pallu of Sareeviz:
# X from 150 to 300, Y from 350 to 500
for ($y = 350; $y -lt 500; $y += 10) {
    for ($x = 150; $x -lt 300; $x += 10) {
        $c = $sv.GetPixel($x, $y)
        # Check if reddish or pinkish or orange
        if ($c.R -gt 120 -and $c.R -gt ($c.G + 20) -and $c.R -gt ($c.B + 20)) {
            Write-Host "Reddish at X=$x, Y=$y : R=$($c.R), G=$($c.G), B=$($c.B)"
        }
    }
}
$sv.Dispose()

