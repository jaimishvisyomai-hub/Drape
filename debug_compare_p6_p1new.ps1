Add-Type -AssemblyName System.Drawing

$p6 = [System.Drawing.Bitmap]::FromFile((Resolve-Path "drape-lab/mask_PATLI_06.png"))
$p8 = [System.Drawing.Bitmap]::FromFile((Resolve-Path "drape-lab/mask_patli_08.png"))
$p1new = [System.Drawing.Bitmap]::FromFile((Resolve-Path "drape-lab/mask_PATLI_01_NEW.png"))

Write-Host "P6: $($p6.Width) x $($p6.Height)"
for ($y = 900; $y -lt 1650; $y += 100) {
    $minX6 = -1; $maxX6 = -1
    $minX8 = -1; $maxX8 = -1
    $minX1n = -1; $maxX1n = -1
    for ($x = 0; $x -lt $p6.Width; $x++) {
        if ($p6.GetPixel($x, $y).A -gt 20) {
            if ($minX6 -eq -1) { $minX6 = $x }
            $maxX6 = $x
        }
        if ($p8.GetPixel($x, $y).A -gt 20) {
            if ($minX8 -eq -1) { $minX8 = $x }
            $maxX8 = $x
        }
        if ($p1new.GetPixel($x, $y).A -gt 20) {
            if ($minX1n -eq -1) { $minX1n = $x }
            $maxX1n = $x
        }
    }
    $yNorm = [Math]::Round($y / $p6.Height, 3)
    Write-Host "Y=$y ($yNorm): P6=[$minX6 .. $maxX6] ($([Math]::Round($minX6/$p6.Width,3)) .. $([Math]::Round($maxX6/$p6.Width,3))), P8=[$minX8 .. $maxX8], P1NEW=[$minX1n .. $maxX1n]"
}
$p6.Dispose()
$p8.Dispose()
$p1new.Dispose()

