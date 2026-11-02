Add-Type -AssemblyName System.Drawing

$p = (Resolve-Path "crops/sareeviz_target_card.png").Path
$bmp = [System.Drawing.Bitmap]::FromFile($p)
$w = $bmp.Width
$h = $bmp.Height

Write-Host "Tracing SareeViz Target Silhouette ($w x $h):"
# Find model/saree content bounds per row
for ($yFrac = 0.20; $yFrac -le 0.95; $yFrac += 0.05) {
    $y = [int]($yFrac * $h)
    $minX = -1; $maxX = -1
    for ($x = 0; $x -lt $w; $x++) {
        $c = $bmp.GetPixel($x, $y)
        # Content is non-white
        $isContent = ($c.R -lt 235 -or $c.G -lt 235 -or $c.B -lt 235) -and ($c.R -gt 25 -or $c.G -gt 25 -or $c.B -gt 35)
        if ($isContent) {
            if ($minX -eq -1) { $minX = $x }
            $maxX = $x
        }
    }
    $normMinX = if ($minX -ge 0) { [Math]::Round($minX / $w, 3) } else { 0 }
    $normMaxX = if ($maxX -ge 0) { [Math]::Round($maxX / $w, 3) } else { 0 }
    Write-Host "Y=$([Math]::Round($yFrac, 2)): MinX=$normMinX, MaxX=$normMaxX (width=$([Math]::Round($normMaxX - $normMinX, 3)))"
}

$bmp.Dispose()

