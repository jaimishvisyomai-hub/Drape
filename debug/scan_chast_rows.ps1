Add-Type -AssemblyName System.Drawing

$m1 = [System.Drawing.Bitmap]::FromFile('drape-lab/mask_CHAST_01.png')
$w = $m1.Width
$h = $m1.Height

$testRows = @(0.18, 0.19, 0.20, 0.22, 0.25, 0.28, 0.31, 0.34, 0.37, 0.385)
foreach ($normY in $testRows) {
    $y = [int]($normY * $h)
    $minX = $w
    $maxX = 0
    $count = 0
    for ($x = 0; $x -lt $w; $x++) {
        if ($m1.GetPixel($x, $y).A -gt 25) {
            $count++
            if ($x -lt $minX) { $minX = $x }
            if ($x -gt $maxX) { $maxX = $x }
        }
    }
    if ($count -gt 0) {
        Write-Host "Y=$normY ($y) -> X: $([Math]::Round($minX/$w, 4)) .. $([Math]::Round($maxX/$w, 4)) (count=$count)"
    } else {
        Write-Host "Y=$normY ($y) -> No pixels"
    }
}
$m1.Dispose()

