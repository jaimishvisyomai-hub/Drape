Add-Type -AssemblyName System.Drawing

$sv = [System.Drawing.Bitmap]::FromFile((Resolve-Path "crops/sareeviz_exact_card.png"))

# In Sareeviz (width 360), let's find the vertical border:
# It is silver/gold (R ~ 160-200, G ~ 150-190, B ~ 130-170)
# Running vertically between Y = 250 and Y = 500
Write-Host "Finding vertical border in SareeViz:"
for ($y = 250; $y -lt 500; $y += 30) {
    for ($x = 70; $x -lt 200; $x++) {
        $c = $sv.GetPixel($x, $y)
        # Silver/gold border has distinct high brightness and slight warm tint
        if ($c.R -gt 150 -and $c.G -gt 145 -and $c.B -gt 120 -and ($c.R - $c.B) -lt 40) {
            $xNorm = [Math]::Round($x / $sv.Width, 3)
            $yNorm = [Math]::Round($y / $sv.Height, 3)
            Write-Host "Silver/Gold Border at X=$x ($xNorm), Y=$y ($yNorm): [$($c.R),$($c.G),$($c.B)]"
            break
        }
    }
}
$sv.Dispose()

