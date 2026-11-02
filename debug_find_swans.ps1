Add-Type -AssemblyName System.Drawing
$img = [System.Drawing.Bitmap]::FromFile((Resolve-Path "crops/raw_uploaded_saree.jpg"))

# Let's inspect where the swans are located horizontally and vertically
# Swans have white/cream necks and heads, facing each other
# Let's check between Y=1200 and Y=1400
for ($y = 1200; $y -lt 1400; $y += 10) {
    $rowStr = ""
    for ($x = 350; $x -lt 650; $x += 20) {
        $c = $img.GetPixel($x, $y)
        if ($c.R -gt 200 -and $c.G -gt 190 -and $c.B -gt 150) { $rowStr += "W" }
        elseif ($c.R -gt 150 -and $c.G -lt 80 -and $c.B -lt 80) { $rowStr += "R" }
        elseif ($c.R -gt 180 -and $c.G -gt 140) { $rowStr += "Y" }
        else { $rowStr += "." }
    }
    $v = [Math]::Round($y / 1600, 3)
    Write-Host "Y=$y (V=$v): $rowStr"
}
$img.Dispose()

