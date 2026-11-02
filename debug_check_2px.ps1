Add-Type -AssemblyName System.Drawing

$img = [System.Drawing.Bitmap]::FromFile((Resolve-Path "crops/hybrid_draped_result.png"))

# Check around Y=3168
for ($y = 3165; $y -le 3172; $y++) {
    for ($x = 1000; $x -lt 1800; $x++) {
        $c = $img.GetPixel($x, $y)
        if ($c.R -gt 240 -and $c.G -gt 240 -and $c.B -gt 240) {
            $left = $img.GetPixel($x - 30, $y)
            $right = $img.GetPixel($x + 30, $y)
            $isLeftSaree = ($left.G -gt 40 -and $left.R -lt 200)
            $isRightSaree = ($right.G -gt 40 -and $right.R -lt 200)
            if ($isLeftSaree -and $isRightSaree) {
                Write-Host "Pixel at X=$x ($([Math]::Round($x/2400,3))), Y=$y ($([Math]::Round($y/3600,3))): [$($c.R),$($c.G),$($c.B)]"
            }
        }
    }
}
$img.Dispose()

