Add-Type -AssemblyName System.Drawing

$m2 = [System.Drawing.Bitmap]::FromFile((Resolve-Path "drape-lab/mask_PALLU_02.png"))

# Check minX around Y=1585 in m2
for ($y = 1575; $y -le 1595; $y += 2) {
    $minX = -1
    for ($x = 0; $x -lt $m2.Width; $x++) {
        if ($m2.GetPixel($x, $y).A -gt 20) {
            $minX = $x
            break
        }
    }
    Write-Host "Y=$y : M2 minX=$minX ($([Math]::Round($minX/$m2.Width,3)))"
}
$m2.Dispose()

