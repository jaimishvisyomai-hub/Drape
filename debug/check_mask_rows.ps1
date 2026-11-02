Add-Type -AssemblyName System.Drawing

$maskPath = (Resolve-Path "drape-lab/mask_PALLU_02.png").Path
$bmp = New-Object System.Drawing.Bitmap($maskPath)
$w = $bmp.Width
$h = $bmp.Height

# Rows from mapping.json
$rowsY = @(0.300, 0.396, 0.450, 0.503, 0.557, 0.611, 0.660, 0.720, 0.785, 0.925)

Write-Host "mask_PALLU_02.png size: ${w}x${h}"
Write-Host "Row | Target Y | Mask Min X | Mask Max X | Col 0 Dst | Col 1 Dst"
Write-Host "----+----------+------------+------------+-----------+----------"

$mappingJson = Get-Content "drape-lab/mapping.json" | ConvertFrom-Json
$p2Dst = $mappingJson.'mask_PALLU_02.png'.dst_pts

for ($r = 0; $r -lt 10; $r++) {
    $yVal = $rowsY[$r]
    $py = [int]($yVal * $h)
    $minX = -1
    $maxX = -1
    for ($x = 0; $x -lt $w; $x++) {
        $alpha = $bmp.GetPixel($x, $py).A
        if ($alpha -gt 20) {
            if ($minX -eq -1) { $minX = $x }
            $maxX = $x
        }
    }
    $minXNorm = if ($minX -ge 0) { [math]::Round($minX / $w, 4) } else { 0 }
    $maxXNorm = if ($maxX -ge 0) { [math]::Round($maxX / $w, 4) } else { 0 }
    $col0 = [math]::Round($p2Dst[$r*2][0], 4)
    $col1 = [math]::Round($p2Dst[$r*2+1][0], 4)
    Write-Host ("{0,2}  | {1,8:F3} | {2,10:F4} | {3,10:F4} | {4,9:F4} | {5,9:F4}" -f $r, $yVal, $minXNorm, $maxXNorm, $col0, $col1)
}

$bmp.Dispose()

