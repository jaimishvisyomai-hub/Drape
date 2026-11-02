Add-Type -AssemblyName System.Drawing
$img = [System.Drawing.Bitmap]::FromFile((Join-Path (Get-Location) "drape-lab/mask_PATLI_07.png"))
$w = $img.Width
$h = $img.Height
for ($yRatio = 0.88; $yRatio -le 0.94; $yRatio += 0.01) {
    $y = [int]($h * $yRatio)
    $minX = $w; $maxX = 0; $cnt = 0
    for ($x = 0; $x -lt $w; $x++) {
        $p = $img.GetPixel($x, $y)
        if ($p.A -gt 50) {
            $cnt++
            if ($x -lt $minX) { $minX = $x }
            if ($x -gt $maxX) { $maxX = $x }
        }
    }
    Write-Host ("Y={0:F2}: Alpha pixels={1}, X=[{2:F3} .. {3:F3}]" -f $yRatio, $cnt, ($minX/$w), ($maxX/$w))
}
$img.Dispose()

