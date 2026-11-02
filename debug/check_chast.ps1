Add-Type -AssemblyName System.Drawing
function Inspect-BBox($p) {
    $bmp = New-Object System.Drawing.Bitmap((Resolve-Path $p).Path)
    $w = $bmp.Width
    $h = $bmp.Height
    $minX = $w
    $maxX = 0
    $minY = $h
    $maxY = 0
    for ($y = 0; $y -lt $h; $y += 4) {
        for ($x = 0; $x -lt $w; $x += 4) {
            $a = $bmp.GetPixel($x, $y).A
            if ($a -gt 20) {
                if ($x -lt $minX) { $minX = $x }
                if ($x -gt $maxX) { $maxX = $x }
                if ($y -lt $minY) { $minY = $y }
                if ($y -gt $maxY) { $maxY = $y }
            }
        }
    }
    $bmp.Dispose()
    Write-Host ("{0} : X=[{1:F4}..{2:F4}], Y=[{3:F4}..{4:F4}]" -f $p, ($minX / $w), ($maxX / $w), ($minY / $h), ($maxY / $h))
}
Inspect-BBox "drape-lab/mask_CHAST_01.png"
Inspect-BBox "drape-lab/mask_CHAST_02.png"
Inspect-BBox "drape-lab/mask_CHAST_03.png"

