Add-Type -AssemblyName System.Drawing

$saree = [System.Drawing.Bitmap]::FromFile('crops/raw_uploaded_saree.jpg')
$w = $saree.Width
$h = $saree.Height
Write-Host "Saree dimensions: $w x $h"

for ($y = 0; $y -lt $h; $y += 32) {
    $normY = [Math]::Round($y / $h, 4)
    # Average across X = 400..560
    $rTot = 0; $gTot = 0; $bTot = 0; $cnt = 0
    for ($x = [int]($w * 0.4); $x -lt [int]($w * 0.6); $x += 10) {
        $c = $saree.GetPixel($x, $y)
        $rTot += $c.R; $gTot += $c.G; $bTot += $c.B; $cnt++
    }
    $avgR = [int]($rTot / $cnt); $avgG = [int]($gTot / $cnt); $avgB = [int]($bTot / $cnt)
    
    $tag = "Body (Dark Green)"
    if ($avgR -gt 130 -and $avgG -gt 105 -and $avgB -lt 95) { $tag = "GOLD ZARI BAND" }
    elseif ($avgR -gt 120 -and $avgG -lt 85 -and $avgB -lt 80) { $tag = "RED LOTUS / ORNATE" }
    elseif ($avgR -gt 100 -and $avgG -gt 100 -and $avgB -gt 85) { $tag = "SWANS / BRIGHT MOTIF" }

    Write-Host "V=$normY ($y px) -> ($avgR, $avgG, $avgB) : $tag"
}
$saree.Dispose()

