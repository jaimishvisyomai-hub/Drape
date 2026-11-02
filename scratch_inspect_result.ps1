Add-Type -AssemblyName System.Drawing

$resPath = Join-Path (Get-Location) "crops/hybrid_draped_result.png"
$img = [System.Drawing.Bitmap]::FromFile($resPath)
$w = $img.Width
$h = $img.Height
Write-Host "Result image size: $w x $h"

# 1. Inspect Pallu Right Boundary (X values across rows)
Write-Host "`n--- Pallu Right Silhouette Curve ---"
for ($i = 0; $i -lt 10; $i++) {
    $yRatio = 0.38 + ($i / 9.0) * (0.90 - 0.38)
    $y = [int]($h * $yRatio)
    $rightX = 0
    for ($x = $w - 1; $x -ge [int]($w * 0.40); $x--) {
        $p = $img.GetPixel($x, $y)
        # Background is white (R>245, G>245, B>245)
        if (!($p.R -gt 240 -and $p.G -gt 240 -and $p.B -gt 240)) {
            $rightX = $x
            break
        }
    }
    $normX = $rightX / $w
    Write-Host ("Row {0}: Y={1:F3} -> Rightmost Fabric X={2:F3} ({3}px)" -f $i, $yRatio, $normX, $rightX)
}

# 2. Inspect Pleat Region for White Slits (scan across X in [0.03..0.22] at Y=0.91)
Write-Host "`n--- Pleat Hem White Slits Scan (Y=0.91) ---"
$yScan = [int]($h * 0.91)
$whiteSlitPixels = 0
$totalPleatPixels = 0
for ($x = [int]($w * 0.03); $x -lt [int]($w * 0.22); $x++) {
    $totalPleatPixels++
    $p = $img.GetPixel($x, $yScan)
    # Check if pixel is white model/background peek (R>220, G>220, B>220)
    if ($p.R -gt 220 -and $p.G -gt 220 -and $p.B -gt 220) {
        $whiteSlitPixels++
        Write-Host ("  WHITE SLIT DETECTED at X={0:F3} ({1}px): R={2} G={3} B={4}" -f ($x/$w), $x, $p.R, $p.G, $p.B)
    }
}
Write-Host ("Total scanned pleat pixels: {0}, White slit pixels: {1}" -f $totalPleatPixels, $whiteSlitPixels)

# 3. Inspect Motifs in Pallu: Lower Pallu (Y=0.75..0.82)
Write-Host "`n--- Lower Pallu Color Distribution (Red Lotus Medallion Check) ---"
$redCount = 0; $goldCount = 0; $greenCount = 0; $sampleCount = 0
for ($y = [int]($h * 0.75); $y -lt [int]($h * 0.83); $y += 3) {
    for ($x = [int]($w * 0.50); $x -lt [int]($w * 0.85); $x += 3) {
        $sampleCount++
        $p = $img.GetPixel($x, $y)
        if ($p.R -gt 130 -and $p.G -lt 90 -and $p.B -lt 90) { $redCount++ }
        elseif ($p.R -gt 130 -and $p.G -gt 110 -and $p.B -lt 95) { $goldCount++ }
        elseif ($p.G -gt $p.R -and $p.G -gt $p.B) { $greenCount++ }
    }
}
Write-Host ("Lower Pallu: Red={0:F1}%, Gold={1:F1}%, Green={2:F1}%" -f ($redCount/$sampleCount*100), ($goldCount/$sampleCount*100), ($greenCount/$sampleCount*100))

$img.Dispose()

