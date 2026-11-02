Add-Type -AssemblyName System.Drawing

$m1 = [System.Drawing.Bitmap]::FromFile('drape-lab/mask_CHAST_01.png')
$w = $m1.Width
$h = $m1.Height

$testLevels = @(0.179, 0.22, 0.26, 0.30, 0.34, 0.387)
foreach ($lvl in $testLevels) {
    $y = [int]($lvl * $h)
    $minX = $w
    $maxX = 0
    $count = 0
    for ($dy = -2; $dy -le 2; $dy++) {
        $cy = $y + $dy
        if ($cy -ge 0 -and $cy -lt $h) {
            for ($x = 0; $x -lt $w; $x++) {
                if ($m1.GetPixel($x, $cy).A -gt 25) {
                    $count++
                    if ($x -lt $minX) { $minX = $x }
                    if ($x -gt $maxX) { $maxX = $x }
                }
            }
        }
    }
    Write-Host "Level Y=$lvl ($y) -> X: $([Math]::Round($minX/$w, 4)) .. $([Math]::Round($maxX/$w, 4))"
}
$m1.Dispose()

