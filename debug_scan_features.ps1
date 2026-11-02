Add-Type -AssemblyName System.Drawing
$imgPath = Resolve-Path "crops/raw_uploaded_saree.jpg"
$img = [System.Drawing.Bitmap]::FromFile($imgPath)

# Let's search for the red lotus: high R, low G, low B (R > 140, G < 80, B < 80)
# And search for yellow/gold (R > 180, G > 150, B < 120)
# And search for white/cream (R > 200, G > 200, B > 180) - swans
$redCount = @{}
$swanCount = @{}
$goldCount = @{}

for ($y = 0; $y -lt $img.Height; $y += 10) {
    $redInRow = 0
    $swanInRow = 0
    $goldInRow = 0
    for ($x = 0; $x -lt $img.Width; $x += 10) {
        $c = $img.GetPixel($x, $y)
        if ($c.R -gt 130 -and $c.G -lt 80 -and $c.B -lt 80) { $redInRow++ }
        if ($c.R -gt 210 -and $c.G -gt 210 -and $c.B -gt 190) { $swanInRow++ }
        if ($c.R -gt 170 -and $c.G -gt 140 -and $c.B -lt 110) { $goldInRow++ }
    }
    if ($redInRow -gt 3) {
        $v = [Math]::Round($y / $img.Height, 3)
        Write-Host "RED found at Y=$y (V=$v): $redInRow pixels"
    }
    if ($swanInRow -gt 3) {
        $v = [Math]::Round($y / $img.Height, 3)
        Write-Host "SWAN/CREAM found at Y=$y (V=$v): $swanInRow pixels"
    }
}
$img.Dispose()

