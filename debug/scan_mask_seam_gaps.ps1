Add-Type -AssemblyName System.Drawing

$m1 = [System.Drawing.Bitmap]::FromFile('drape-lab/mask_PALLU_01.png')
$m2 = [System.Drawing.Bitmap]::FromFile('drape-lab/mask_PALLU_02.png')
$w = $m1.Width
$h = $m1.Height

for ($y = 0; $y -lt $h; $y += 10) {
    $m1Max = 0
    $m2Min = $w
    for ($x = 0; $x -lt $w; $x += 2) {
        if ($m1.GetPixel($x, $y).A -gt 25) { if ($x -gt $m1Max) { $m1Max = $x } }
        if ($m2.GetPixel($x, $y).A -gt 25) { if ($x -lt $m2Min) { $m2Min = $x } }
    }
    if ($m1Max -gt 0 -and $m2Min -lt $w) {
        $diff = $m1Max - $m2Min
        if ($diff -lt 0) {
            Write-Host "Gap at Y=$([Math]::Round($y/$h, 4)) ($y): P1_Max=$([Math]::Round($m1Max/$w, 4)) P2_Min=$([Math]::Round($m2Min/$w, 4)) diff=$diff px"
        }
    }
}
$m1.Dispose()
$m2.Dispose()

