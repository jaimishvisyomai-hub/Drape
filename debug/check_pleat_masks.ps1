Add-Type -AssemblyName System.Drawing

$drapeDir = (Resolve-Path "drape-lab").Path
$pleatKeys = @(
    "mask_PATLI_07.png",
    "mask_PATLI_06.png",
    "mask_PATLI_05.png",
    "mask_PATLI_04.png",
    "mask_PATLI_03.png",
    "mask_PATLI_02.png",
    "mask_PATLI_01.png",
    "mask_PATLI_01_NEW.png",
    "mask_patli_08.png"
)

Write-Host "Inspecting Pleat Masks:"
foreach ($k in $pleatKeys) {
    $p = Join-Path $drapeDir $k
    $bmp = [System.Drawing.Bitmap]::FromFile($p)
    $minX = $bmp.Width; $maxX = 0; $minY = $bmp.Height; $maxY = 0
    for ($y = 0; $y -lt $bmp.Height; $y += 5) {
        for ($x = 0; $x -lt $bmp.Width; $x += 5) {
            if ($bmp.GetPixel($x, $y).A -gt 20) {
                if ($x -lt $minX) { $minX = $x }
                if ($x -gt $maxX) { $maxX = $x }
                if ($y -lt $minY) { $minY = $y }
                if ($y -gt $maxY) { $maxY = $y }
            }
        }
    }
    $normX0 = [Math]::Round($minX / $bmp.Width, 3)
    $normX1 = [Math]::Round($maxX / $bmp.Width, 3)
    $normY0 = [Math]::Round($minY / $bmp.Height, 3)
    $normY1 = [Math]::Round($maxY / $bmp.Height, 3)
    Write-Host ("{0,-24} : X=[{1:F3} .. {2:F3}], Y=[{3:F3} .. {4:F3}]" -f $k, $normX0, $normX1, $normY0, $normY1)
    $bmp.Dispose()
}

