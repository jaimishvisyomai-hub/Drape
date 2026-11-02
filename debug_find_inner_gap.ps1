Add-Type -AssemblyName System.Drawing

$img = [System.Drawing.Bitmap]::FromFile((Resolve-Path "crops/hybrid_draped_result.png"))

for ($y = 1200; $y -lt 3400; $y += 100) {
    $yNorm = [Math]::Round($y / $img.Height, 3)
    $gaps = @()
    for ($x = 400; $x -lt 900; $x++) {
        $c = $img.GetPixel($x, $y)
        if ($c.R -gt 240 -and $c.G -gt 240 -and $c.B -gt 240) {
            # Check if left is saree and right is saree
            $leftIsSaree = ($img.GetPixel($x - 20, $y).G -gt 40 -and $img.GetPixel($x - 20, $y).R -lt 200)
            $rightIsSaree = ($img.GetPixel($x + 20, $y).G -gt 40 -and $img.GetPixel($x + 20, $y).R -lt 200)
            if ($leftIsSaree -and $rightIsSaree) {
                $gaps += $x
            }
        }
    }
    if ($gaps.Count -gt 0) {
        $minX = $gaps[0]
        $maxX = $gaps[-1]
        Write-Host "Y=$y ($yNorm): Interior white at X=[$minX .. $maxX] ($([Math]::Round($minX/$img.Width,3)) .. $([Math]::Round($maxX/$img.Width,3))), count=$($gaps.Count)"
    }
}
$img.Dispose()

