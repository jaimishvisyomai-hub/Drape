Add-Type -AssemblyName System.Drawing
$p = Join-Path (Get-Location) 'drape-lab/mask_PALLU_01.png'
$bmp = [System.Drawing.Bitmap]::FromFile($p)
$w = $bmp.Width
$h = $bmp.Height

for ($r = 0; $r -lt 10; $r++) {
    $y = [int]((0.30 + $r * 0.065) * $h)
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
        Write-Host ('Y={0:N3}: minX={1:N3} maxX={2:N3}' -f ($y/$h), ($minX/$w), ($maxX/$w))
    }
}
$bmp.Dispose()

