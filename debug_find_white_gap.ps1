Add-Type -AssemblyName System.Drawing

$img = [System.Drawing.Bitmap]::FromFile((Resolve-Path "crops/hybrid_draped_result.png"))
Write-Host "Hybrid image size: $($img.Width) x $($img.Height)"

# Check for near-white pixels inside the body drape area:
# X from 500 to 2000, Y from 1000 to 3400
# (where base model is white background)
$whitePixels = @()

for ($y = 1000; $y -lt 3400; $y += 20) {
    for ($x = 500; $x -lt 2000; $x += 20) {
        $c = $img.GetPixel($x, $y)
        # White background is (255, 255, 255)
        if ($c.R -gt 245 -and $c.G -gt 245 -and $c.B -gt 245) {
            # Check if surrounded by saree pixels (dark green or gold)
            $left = $img.GetPixel($x - 60, $y)
            $right = $img.GetPixel($x + 60, $y)
            $isLeftSaree = ($left.G -gt 40 -and $left.R -lt 200) -or ($left.R -gt 150 -and $left.G -gt 120)
            $isRightSaree = ($right.G -gt 40 -and $right.R -lt 200) -or ($right.R -gt 150 -and $right.G -gt 120)
            if ($isLeftSaree -and $isRightSaree) {
                $normX = [Math]::Round($x / $img.Width, 3)
                $normY = [Math]::Round($y / $img.Height, 3)
                Write-Host "WHITE GAP at X=$x ($normX), Y=$y ($normY) between saree pixels!"
            }
        }
    }
}
$img.Dispose()

