Add-Type -AssemblyName System.Drawing

$img = [System.Drawing.Bitmap]::FromFile((Resolve-Path "crops/hybrid_draped_result.png"))

foreach ($y in @(1800, 1980, 2050, 3060, 3150, 3250)) {
    $yNorm = [Math]::Round($y / $img.Height, 3)
    $minX = 9999; $maxX = 0; $cnt = 0
    for ($x = 800; $x -lt 2000; $x++) {
        $c = $img.GetPixel($x, $y)
        if ($c.R -gt 240 -and $c.G -gt 240 -and $c.B -gt 240) {
            # check if between saree
            $leftIsSaree = ($img.GetPixel($x - 30, $y).G -gt 40 -and $img.GetPixel($x - 30, $y).R -lt 200)
            $rightIsSaree = ($img.GetPixel($x + 30, $y).G -gt 40 -and $img.GetPixel($x + 30, $y).R -lt 200)
            if ($leftIsSaree -and $rightIsSaree) {
                if ($x -lt $minX) { $minX = $x }
                if ($x -gt $maxX) { $maxX = $x }
                $cnt++
            }
        }
    }
    Write-Host "Y=$y ($yNorm): Interior white count=$cnt, X=[$minX .. $maxX] ($([Math]::Round($minX/$img.Width,3)) .. $([Math]::Round($maxX/$img.Width,3)))"
}
$img.Dispose()

