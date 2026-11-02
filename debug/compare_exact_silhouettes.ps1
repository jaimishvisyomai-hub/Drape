Add-Type -AssemblyName System.Drawing

function Trace-Card($path, $label) {
    $bmp = [System.Drawing.Bitmap]::FromFile((Resolve-Path $path).Path)
    $w = $bmp.Width
    $h = $bmp.Height
    Write-Host "`n=== Silhouette of $label (${w}x${h}) ==="
    Write-Host "Norm Y | Min X (Left Edge) | Max X (Right Edge) | Width"
    Write-Host "-------+--------------------+---------------------+------"

    for ($yStep = 15; $yStep -le 95; $yStep += 5) {
        $y = [int]($yStep * $h / 100)
        $minX = -1; $maxX = -1
        for ($x = 0; $x -lt $w; $x++) {
            $c = $bmp.GetPixel($x, $y)
            # Not white background (R<240 or G<240 or B<240)
            if ($c.R -lt 238 -or $c.G -lt 238 -or $c.B -lt 238) {
                if ($minX -eq -1) { $minX = $x }
                $maxX = $x
            }
        }
        $normY = [Math]::Round($yStep / 100.0, 2)
        $normMinX = if ($minX -ge 0) { [Math]::Round($minX / $w, 3) } else { 0 }
        $normMaxX = if ($maxX -ge 0) { [Math]::Round($maxX / $w, 3) } else { 0 }
        $normW = [Math]::Round($normMaxX - $normMinX, 3)
        Write-Host (" {0,5:F2} | {1,18:F3} | {2,19:F3} | {3,6:F3}" -f $normY, $normMinX, $normMaxX, $normW)
    }
    $bmp.Dispose()
}

Trace-Card "crops/current_exact_card.png" "CURRENT HYBRID OUTPUT"
Trace-Card "crops/sareeviz_exact_card.png" "SAREEVIZ TARGET REFERENCE"

