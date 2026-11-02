Add-Type -AssemblyName System.Drawing

$sv = [System.Drawing.Bitmap]::FromFile((Resolve-Path "crops/sareeviz_exact_card.png"))

# Look at rows Y = 100 to 550, find where the pallu is (X from 150 to 350)
for ($y = 150; $y -lt 550; $y += 20) {
    $minX = 999; $maxX = 0
    for ($x = 100; $x -lt $sv.Width; $x++) {
        $c = $sv.GetPixel($x, $y)
        # Saree pixel (not pure white)
        if ($c.R -lt 240 -or $c.G -lt 240 -or $c.B -lt 240) {
            if ($x -lt $minX) { $minX = $x }
            if ($x -gt $maxX) { $maxX = $x }
        }
    }
    # Sample center of saree at this row
    $midX = [int](($minX + $maxX) / 2)
    $cMid = $sv.GetPixel($midX, $y)
    Write-Host "Y=$y : X=[$minX .. $maxX] (width=$($maxX - $minX)), MidPixel at $midX=[$($cMid.R),$($cMid.G),$($cMid.B)]"
}
$sv.Dispose()

