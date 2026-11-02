Add-Type -AssemblyName System.Drawing
$hybrid = [System.Drawing.Bitmap]::FromFile((Resolve-Path "crops/hybrid_draped_result.png"))
Write-Host "Hybrid size: $($hybrid.Width) x $($hybrid.Height)"

# In hybrid result, let's sample colors in the lower pallu:
# The canvas is 2400 x 3600 (base model dimensions)
# Let's check normalized Y from 0.70 to 0.90 (Y from 2500 to 3200)
# X from 1200 to 1800
for ($yNorm = 0.70; $yNorm -le 0.90; $yNorm += 0.02) {
    $y = [int]($yNorm * $hybrid.Height)
    $redPixels = 0
    $whiteSwanPixels = 0
    for ($xNorm = 0.50; $xNorm -le 0.80; $xNorm += 0.01) {
        $x = [int]($xNorm * $hybrid.Width)
        $c = $hybrid.GetPixel($x, $y)
        if ($c.R -gt 130 -and $c.G -lt 80 -and $c.B -lt 80) { $redPixels++ }
        if ($c.R -gt 210 -and $c.G -gt 210 -and $c.B -gt 190) { $whiteSwanPixels++ }
    }
    Write-Host "YNorm=$yNorm (Y=$y): Red=$redPixels, Swans=$whiteSwanPixels"
}
$hybrid.Dispose()

