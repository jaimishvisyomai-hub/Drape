Add-Type -AssemblyName System.Drawing
$p = Join-Path (Get-Location) 'drape-lab/mask_CHAST_01.png'
$bmp = [System.Drawing.Bitmap]::FromFile($p)
$w = $bmp.Width
$h = $bmp.Height

for ($y = [int](0.365 * $h); $y -le [int](0.395 * $h); $y += 5) {
    $minX = $w; $maxX = -1
    for ($x = 0; $x -lt $w; $x++) {
        $c = $bmp.GetPixel($x, $y)
        if ($c.A -gt 20) {
            if ($x -lt $minX) { $minX = $x }
            if ($x -gt $maxX) { $maxX = $x }
        }
    }
    $normY = $y / $h
    if ($maxX -ge $minX) {
        Write-Host ('Y={0:N3} (px={1}): minX={2:N3} maxX={3:N3}' -f $normY, $y, ($minX/$w), ($maxX/$w))
    } else {
        Write-Host ('Y={0:N3} (px={1}): EMPTY' -f $normY, $y)
    }
}
$bmp.Dispose()

