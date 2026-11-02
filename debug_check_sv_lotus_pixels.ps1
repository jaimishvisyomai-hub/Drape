Add-Type -AssemblyName System.Drawing

$sv = [System.Drawing.Bitmap]::FromFile((Resolve-Path "crops/sareeviz_exact_card.png"))

# Look at the motif in SareeViz: X = 180 to 260, Y = 420 to 480
Write-Host "Checking pixels in SareeViz motif:"
for ($y = 420; $y -le 480; $y += 5) {
    $rowStr = ""
    for ($x = 180; $x -le 260; $x += 4) {
        $c = $sv.GetPixel($x, $y)
        # Check colors
        if ($c.R -gt 200 -and $c.G -gt 190 -and $c.B -gt 150) { $rowStr += "W" } # white/cream
        elseif ($c.R -gt 130 -and $c.G -lt 80 -and $c.B -lt 80) { $rowStr += "R" } # red
        elseif ($c.R -gt 160 -and $c.G -gt 110 -and $c.B -lt 90) { $rowStr += "O" } # orange/gold
        elseif ($c.G -gt $c.R -and $c.G -gt $c.B) { $rowStr += "G" } # green
        else { $rowStr += "." }
    }
    Write-Host "Y=$y : $rowStr"
}
$sv.Dispose()

