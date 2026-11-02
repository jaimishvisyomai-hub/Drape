Add-Type -AssemblyName System.Drawing

function Analyze-Silhouette($path) {
    $resolved = (Resolve-Path $path).Path
    $bmp = New-Object System.Drawing.Bitmap($resolved)
    $w = $bmp.Width
    $h = $bmp.Height
    Write-Host "Image: $path (${w}x${h})"
    
    for ($yStep = 20; $yStep -le 95; $yStep += 5) {
        $y = [int]($yStep * $h / 100)
        $rightmostFabricX = -1
        $fabricColor = ""
        for ($x = $w - 1; $x -ge 0; $x--) {
            $p = $bmp.GetPixel($x, $y)
            # Not white background (R, G, B all > 235 is white background)
            $isNotWhite = ($p.R -lt 230 -or $p.G -lt 230 -or $p.B -lt 230)
            if ($isNotWhite) {
                $rightmostFabricX = $x
                $fabricColor = "R=$($p.R),G=$($p.G),B=$($p.B)"
                break
            }
        }
        $normX = if ($rightmostFabricX -ge 0) { [math]::Round($rightmostFabricX / $w, 3) } else { 0 }
        Write-Host "  Y=$($yStep)%: Rightmost at X=$normX ($fabricColor)"
    }
    $bmp.Dispose()
}

Write-Host "--- CURRENT CARD ---"
Analyze-Silhouette "crops/current_card.png"

Write-Host "`n--- TARGET CARD (SareeViz) ---"
Analyze-Silhouette "crops/target_card.png"
