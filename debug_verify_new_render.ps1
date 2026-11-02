Add-Type -AssemblyName System.Drawing

$img = [System.Drawing.Bitmap]::FromFile((Resolve-Path "crops/hybrid_draped_result.png"))
Write-Host "Hybrid image size: $($img.Width) x $($img.Height)"

# 1. Check for interior white gap along the pallu seam (XNorm = 0.45 to 0.75, YNorm = 0.30 to 0.90)
$totalGaps = 0
for ($yNorm = 0.30; $yNorm -le 0.92; $yNorm += 0.02) {
    $y = [int]($yNorm * $img.Height)
    $whiteGaps = 0
    for ($x = 1000; $x -lt 1800; $x++) {
        $c = $img.GetPixel($x, $y)
        if ($c.R -gt 240 -and $c.G -gt 240 -and $c.B -gt 240) {
            $leftIsSaree = ($img.GetPixel($x - 30, $y).G -gt 40 -and $img.GetPixel($x - 30, $y).R -lt 200)
            $rightIsSaree = ($img.GetPixel($x + 30, $y).G -gt 40 -and $img.GetPixel($x + 30, $y).R -lt 200)
            if ($leftIsSaree -and $rightIsSaree) {
                $whiteGaps++
            }
        }
    }
    if ($whiteGaps -gt 0) {
        $totalGaps += $whiteGaps
        Write-Host "WHITE GAP at YNorm=$yNorm (Y=$y): $whiteGaps pixels!"
    }
}
Write-Host "Total pallu seam interior white gaps: $totalGaps"

# 2. Check Red Lotus placement in lower pallu (YNorm = 0.72 to 0.85, XNorm = 0.55 to 0.75)
$redLotusCount = 0
for ($yNorm = 0.72; $yNorm -le 0.84; $yNorm += 0.01) {
    $y = [int]($yNorm * $img.Height)
    for ($x = [int](0.52 * $img.Width); $x -lt [int](0.72 * $img.Width); $x += 5) {
        $c = $img.GetPixel($x, $y)
        if ($c.R -gt 130 -and $c.G -lt 80 -and $c.B -lt 80) {
            $redLotusCount++
        }
    }
}
Write-Host "Red Lotus pixels in lower pallu: $redLotusCount"

# 3. Check Front Vertical Border (XNorm = 0.18 to 0.24, YNorm = 0.50 to 0.90)
$verticalBorderGoldCount = 0
for ($yNorm = 0.55; $yNorm -le 0.85; $yNorm += 0.02) {
    $y = [int]($yNorm * $img.Height)
    for ($x = [int](0.17 * $img.Width); $x -lt [int](0.24 * $img.Width); $x += 2) {
        $c = $img.GetPixel($x, $y)
        if ($c.R -gt 150 -and $c.G -gt 130 -and $c.B -lt 120) {
            $verticalBorderGoldCount++
        }
    }
}
Write-Host "Vertical Zari Border gold pixels: $verticalBorderGoldCount"

$img.Dispose()

