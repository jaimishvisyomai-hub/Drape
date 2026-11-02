Add-Type -AssemblyName System.Drawing

$diff = [System.Drawing.Bitmap]::FromFile('crops/uncovered_regions_difference.png')
$w = $diff.Width
$h = $diff.Height
$redCount = 0
for ($y = 0; $y -lt $h; $y++) {
    for ($x = 0; $x -lt $w; $x++) {
        $c = $diff.GetPixel($x, $y)
        if ($c.R -gt 200 -and $c.G -lt 50) { $redCount++ }
    }
}
Write-Host "Exact red uncovered pixels at 1200x1800: $redCount out of $($w*$h)"
$diff.Dispose()

