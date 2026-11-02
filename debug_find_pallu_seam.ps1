Add-Type -AssemblyName System.Drawing

$img = [System.Drawing.Bitmap]::FromFile((Resolve-Path "crops/hybrid_draped_result.png"))

# Check between XNorm = 0.45 and 0.75, YNorm = 0.50 to 0.90
# for the line/seam between PALLU_01 and PALLU_02
for ($yNorm = 0.50; $yNorm -le 0.90; $yNorm += 0.05) {
    $y = [int]($yNorm * $img.Height)
    $whitePoints = @()
    for ($x = 1000; $x -lt 1800; $x++) {
        $c = $img.GetPixel($x, $y)
        # Check if near white or white background
        if ($c.R -gt 230 -and $c.G -gt 230 -and $c.B -gt 230) {
            $xNorm = [Math]::Round($x / $img.Width, 3)
            $whitePoints += "$x ($xNorm)"
        }
    }
    Write-Host "YNorm=$yNorm (Y=$y): White points count=$($whitePoints.Count)"
    if ($whitePoints.Count -gt 0 -and $whitePoints.Count -lt 50) {
        Write-Host "   -> $($whitePoints -join ', ')"
    }
}
$img.Dispose()

