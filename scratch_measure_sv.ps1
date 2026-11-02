Add-Type -AssemblyName System.Drawing
$svImg = [System.Drawing.Bitmap]::FromFile((Join-Path (Get-Location) "crops/sareeviz_exact_card.png"))
$w = $svImg.Width
$h = $svImg.Height
Write-Host "SareeViz Card Size: $w x $h"

# Find rightmost boundary of the pallu at 10 vertical rows from Y=0.38 to Y=0.92
for ($i = 0; $i -lt 10; $i++) {
    $yRatio = 0.38 + ($i / 9.0) * (0.90 - 0.38)
    $y = [int]($h * $yRatio)
    
    # Scan from right edge (X=W-1 down to 0) to find the first non-background pixel
    $rightX = 0
    for ($x = $w - 1; $x -ge 0; $x--) {
        $p = $svImg.GetPixel($x, $y)
        # Background in SareeViz card is dark/black or white? Let's check:
        # If card is white/black, check distance from background color
        # In sareeviz_exact_card.png, background is white (R>245, G>245, B>245) or transparent?
        if (!($p.R -gt 240 -and $p.G -gt 240 -and $p.B -gt 240) -and !($p.R -lt 25 -and $p.G -lt 25 -and $p.B -lt 25) -and $p.A -gt 30) {
            $rightX = $x
            break
        }
    }
    $normX = $rightX / $w
    Write-Host ("Row {0}: Y={1:F3} ({2}px) -> Rightmost X={3:F3} ({4}px)" -f $i, $yRatio, $y, $normX, $rightX)
}
$svImg.Dispose()

