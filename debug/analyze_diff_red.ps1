Add-Type -AssemblyName System.Drawing

$diff = [System.Drawing.Bitmap]::FromFile('crops/uncovered_regions_difference.png')
$w = $diff.Width
$h = $diff.Height

$palluSeamRed = 0
$palluApexRed = 0
$chestRed = 0
$otherRed = 0

for ($y = 0; $y -lt $h; $y += 5) {
    for ($x = 0; $x -lt $w; $x += 5) {
        $c = $diff.GetPixel($x, $y)
        if ($c.R -gt 200 -and $c.G -lt 50 -and $c.B -lt 50) {
            $normX = $x / $w
            $normY = $y / $h
            if ($normY -lt 0.38) {
                $chestRed++
            } elseif ($normX -gt 0.90) {
                $palluApexRed++
            } elseif ($normX -gt 0.40 -and $normX -lt 0.65) {
                $palluSeamRed++
            } else {
                $otherRed++
            }
        }
    }
}
Write-Host "Red Defect Breakdown (sampled 5px):"
Write-Host " - Upper Chest/Shoulder (Y lt 0.38): $chestRed"
Write-Host " - Pallu Seam (0.40 to 0.65): $palluSeamRed"
Write-Host " - Pallu Outer Apex (X gt 0.90): $palluApexRed"
Write-Host " - Other: $otherRed"
$diff.Dispose()

