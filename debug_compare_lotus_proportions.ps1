Add-Type -AssemblyName System.Drawing

$sv = [System.Drawing.Bitmap]::FromFile("C:\Users\CORE i7\.gemini\antigravity\brain\02f32bd2-18d1-4ceb-a44b-30d096678914\.user_uploaded\media_1793593006051_abaece7b.jpg")
$cur = [System.Drawing.Bitmap]::FromFile("C:\Users\CORE i7\.gemini\antigravity\brain\02f32bd2-18d1-4ceb-a44b-30d096678914\.user_uploaded\media_1793593009182_92517453.jpg")
$saree = [System.Drawing.Bitmap]::FromFile((Resolve-Path "crops/raw_uploaded_saree.jpg"))

Write-Host "=== MEASUREMENTS ==="
Write-Host "SareeViz: $($sv.Width) x $($sv.Height)"
Write-Host "Current:  $($cur.Width) x $($cur.Height)"
Write-Host "Saree:    $($saree.Width) x $($saree.Height)"

# 1. Measure lotus motif in SareeViz
# Search for the red petals of the lotus in SareeViz
$svMinX = 999; $svMaxX = 0; $svMinY = 999; $svMaxY = 0
for ($y = 0; $y -lt $sv.Height; $y++) {
    for ($x = 0; $x -lt $sv.Width; $x++) {
        $c = $sv.GetPixel($x, $y)
        # Red lotus petals: high R, low G, low B
        if ($c.R -gt 130 -and $c.G -lt 80 -and $c.B -lt 80) {
            # Check if in pallu region (X > 150, Y > 300)
            if ($x -gt 150 -and $y -gt 300) {
                if ($x -lt $svMinX) { $svMinX = $x }
                if ($x -gt $svMaxX) { $svMaxX = $x }
                if ($y -lt $svMinY) { $svMinY = $y }
                if ($y -gt $svMaxY) { $svMaxY = $y }
            }
        }
    }
}
$svLotusW = $svMaxX - $svMinX
$svLotusH = $svMaxY - $svMinY
Write-Host "`nSareeViz Red Lotus bounds: X=[$svMinX .. $svMaxX] (width=$svLotusW), Y=[$svMinY .. $svMaxY] (height=$svLotusH)"
Write-Host "SareeViz Lotus normalized: X=[$([Math]::Round($svMinX/$sv.Width, 3)) .. $([Math]::Round($svMaxX/$sv.Width, 3))], Y=[$([Math]::Round($svMinY/$sv.Height, 3)) .. $([Math]::Round($svMaxY/$sv.Height, 3))]"
Write-Host "SareeViz Lotus aspect ratio: $([Math]::Round($svLotusW/$svLotusH, 2))"

# Measure pallu total width at that height in SareeViz
# At Y = ($svMinY + $svMaxY)/2
$midY = [int](($svMinY + $svMaxY)/2)
$palMinX = 999; $palMaxX = 0
for ($x = 100; $x -lt $sv.Width; $x++) {
    $c = $sv.GetPixel($x, $midY)
    if ($c.R -lt 240 -or $c.G -lt 240 -or $c.B -lt 240) {
        if ($x -lt $palMinX) { $palMinX = $x }
        if ($x -gt $palMaxX) { $palMaxX = $x }
    }
}
$palW = $palMaxX - $palMinX
Write-Host "SareeViz Pallu width at lotus midY ($midY): $palW px (X=[$palMinX .. $palMaxX])"
Write-Host "SareeViz Lotus width / Pallu width: $([Math]::Round($svLotusW / $palW * 100, 1))%"

# 2. Measure lotus motif in Current Render
$curMinX = 999; $curMaxX = 0; $curMinY = 999; $curMaxY = 0
for ($y = 0; $y -lt $cur.Height; $y++) {
    for ($x = 0; $x -lt $cur.Width; $x++) {
        $c = $cur.GetPixel($x, $y)
        if ($c.R -gt 130 -and $c.G -lt 80 -and $c.B -lt 80) {
            if ($x -gt 150 -and $y -gt 300) {
                if ($x -lt $curMinX) { $curMinX = $x }
                if ($x -gt $curMaxX) { $curMaxX = $x }
                if ($y -lt $curMinY) { $curMinY = $y }
                if ($y -gt $curMaxY) { $curMaxY = $y }
            }
        }
    }
}
$curLotusW = $curMaxX - $curMinX
$curLotusH = $curMaxY - $curMinY
Write-Host "`nCurrent Render Red Lotus bounds: X=[$curMinX .. $curMaxX] (width=$curLotusW), Y=[$curMinY .. $curMaxY] (height=$curLotusH)"
Write-Host "Current Render Lotus normalized: X=[$([Math]::Round($curMinX/$cur.Width, 3)) .. $([Math]::Round($curMaxX/$cur.Width, 3))], Y=[$([Math]::Round($curMinY/$cur.Height, 3)) .. $([Math]::Round($curMaxY/$cur.Height, 3))]"
Write-Host "Current Render Lotus aspect ratio: $([Math]::Round($curLotusW/$curLotusH, 2))"

$midCurY = [int](($curMinY + $curMaxY)/2)
$curPalMinX = 999; $curPalMaxX = 0
for ($x = 100; $x -lt $cur.Width; $x++) {
    $c = $cur.GetPixel($x, $midCurY)
    if ($c.R -lt 240 -or $c.G -lt 240 -or $c.B -lt 240) {
        if ($x -lt $curPalMinX) { $curPalMinX = $x }
        if ($x -gt $curPalMaxX) { $curPalMaxX = $x }
    }
}
$curPalW = $curPalMaxX - $curPalMinX
Write-Host "Current Render Pallu width at lotus midY ($midCurY): $curPalW px (X=[$curPalMinX .. $curPalMaxX])"
Write-Host "Current Render Lotus width / Pallu width: $([Math]::Round($curLotusW / $curPalW * 100, 1))%"

$sv.Dispose()
$cur.Dispose()
$saree.Dispose()

