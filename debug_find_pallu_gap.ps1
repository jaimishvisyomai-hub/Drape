Add-Type -AssemblyName System.Drawing

$img = [System.Drawing.Bitmap]::FromFile((Resolve-Path "crops/hybrid_draped_result.png"))

# Look at rows from Y = 1200 to 2400 (YNorm = 0.33 to 0.67)
# Across XNorm = 0.40 to 0.55 (X = 960 to 1320)
for ($y = 1200; $y -lt 2400; $y += 50) {
    $yNorm = [Math]::Round($y / $img.Height, 3)
    $whiteFound = @()
    for ($x = 960; $x -lt 1320; $x += 2) {
        $c = $img.GetPixel($x, $y)
        if ($c.R -gt 240 -and $c.G -gt 240 -and $c.B -gt 240) {
            $xNorm = [Math]::Round($x / $img.Width, 3)
            $whiteFound += "$x ($xNorm)"
        }
    }
    if ($whiteFound.Count -gt 0) {
        Write-Host "Y=$y ($yNorm): White pixels at count=$($whiteFound.Count), first=$($whiteFound[0]), last=$($whiteFound[-1])"
    }
}
$img.Dispose()

