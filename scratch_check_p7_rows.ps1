Add-Type -AssemblyName System.Drawing
$p = Join-Path (Get-Location) 'drape-lab/mask_PATLI_07.png'
$bmp = [System.Drawing.Bitmap]::FromFile($p)
$w = $bmp.Width
$h = $bmp.Height

for ($r = 0; $r -le 6; $r++) {
    $normY = 0.50 + $r * 0.07
    $y = [int]($normY * $h)
    if ($y -ge $h) { break }
    $minX = $w; $maxX = -1
    for ($x = 0; $x -lt $w; $x++) {
        $c = $bmp.GetPixel($x, $y)
        if ($c.A -gt 20) {
            if ($x -lt $minX) { $minX = $x }
            if ($x -gt $maxX) { $maxX = $x }
        }
    }
    if ($maxX -ge $minX) {
        Write-Host ('Y={0:N2}: minX={1:N3} maxX={2:N3}' -f $normY, ($minX/$w), ($maxX/$w))
    }
}
$bmp.Dispose()

