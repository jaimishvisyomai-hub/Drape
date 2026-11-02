Add-Type -AssemblyName System.Drawing

$m1 = [System.Drawing.Bitmap]::FromFile('drape-lab/mask_CHAST_01.png')
$w = $m1.Width
$h = $m1.Height

for ($i = 0; $i -lt 6; $i++) {
    $t = $i / 5.0
    $normY = 0.179 + (0.387 - 0.179) * $t
    $y = [int]($normY * $h)
    $minX = $w
    $maxX = 0
    $count = 0
    for ($dy = -2; $dy -le 2; $dy++) {
        $cy = [Math]::Max(0, [Math]::Min($h - 1, $y + $dy))
        for ($x = 0; $x -lt $w; $x++) {
            if ($m1.GetPixel($x, $cy).A -gt 25) {
                $count++
                if ($x -lt $minX) { $minX = $x }
                if ($x -gt $maxX) { $maxX = $x }
            }
        }
    }
    Write-Host "Row $i (Y=$([Math]::Round($normY, 4))): X = $([Math]::Round($minX/$w, 4)) .. $([Math]::Round($maxX/$w, 4)) (count=$count)"
}
$m1.Dispose()

