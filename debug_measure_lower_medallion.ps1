Add-Type -AssemblyName System.Drawing

$sv = [System.Drawing.Bitmap]::FromFile("C:\Users\CORE i7\.gemini\antigravity\brain\02f32bd2-18d1-4ceb-a44b-30d096678914\.user_uploaded\media_1793593006051_abaece7b.jpg")
$cur = [System.Drawing.Bitmap]::FromFile("C:\Users\CORE i7\.gemini\antigravity\brain\02f32bd2-18d1-4ceb-a44b-30d096678914\.user_uploaded\media_1793593009182_92517453.jpg")

Write-Host "--- Scanning SareeViz Lower Pallu Medallion ---"
# In SareeViz (586 x 886), lower pallu is Y from 550 to 800, X from 250 to 550
$svMedMinX = 999; $svMedMaxX = 0; $svMedMinY = 999; $svMedMaxY = 0
for ($y = 550; $y -lt 800; $y++) {
    for ($x = 250; $x -lt 550; $x++) {
        $c = $sv.GetPixel($x, $y)
        # Red petal
        if ($c.R -gt 130 -and $c.G -lt 80 -and $c.B -lt 80) {
            if ($x -lt $svMedMinX) { $svMedMinX = $x }
            if ($x -gt $svMedMaxX) { $svMedMaxX = $x }
            if ($y -lt $svMedMinY) { $svMedMinY = $y }
            if ($y -gt $svMedMaxY) { $svMedMaxY = $y }
        }
    }
}
Write-Host "SareeViz Medallion: X=[$svMedMinX .. $svMedMaxX] (width=$($svMedMaxX - $svMedMinX), norm: $([Math]::Round($svMedMinX/$sv.Width,3)) .. $([Math]::Round($svMedMaxX/$sv.Width,3))), Y=[$svMedMinY .. $svMedMaxY] (height=$($svMedMaxY - $svMedMinY), norm: $([Math]::Round($svMedMinY/$sv.Height,3)) .. $([Math]::Round($svMedMaxY/$sv.Height,3)))"

Write-Host "`n--- Scanning Current Render Lower Pallu Medallion ---"
$curMedMinX = 999; $curMedMaxX = 0; $curMedMinY = 999; $curMedMaxY = 0
for ($y = 500; $y -lt 750; $y++) {
    for ($x = 200; $x -lt 500; $x++) {
        $c = $cur.GetPixel($x, $y)
        if ($c.R -gt 130 -and $c.G -lt 80 -and $c.B -lt 80) {
            if ($x -lt $curMedMinX) { $curMedMinX = $x }
            if ($x -gt $curMedMaxX) { $curMedMaxX = $x }
            if ($y -lt $curMedMinY) { $curMedMinY = $y }
            if ($y -gt $curMedMaxY) { $curMedMaxY = $y }
        }
    }
}
Write-Host "Current Medallion: X=[$curMedMinX .. $curMedMaxX] (width=$($curMedMaxX - $curMedMinX), norm: $([Math]::Round($curMedMinX/$cur.Width,3)) .. $([Math]::Round($curMedMaxX/$cur.Width,3))), Y=[$curMedMinY .. $curMedMaxY] (height=$($curMedMaxY - $curMedMinY), norm: $([Math]::Round($curMedMinY/$cur.Height,3)) .. $([Math]::Round($curMedMaxY/$cur.Height,3)))"

$sv.Dispose()
$cur.Dispose()

