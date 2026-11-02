Add-Type -AssemblyName System.Drawing

function Scan-MaskLevels($maskName, $numRows) {
    $path = Join-Path "drape-lab" $maskName
    $bmp = [System.Drawing.Bitmap]::FromFile($path)
    $w = $bmp.Width
    $h = $bmp.Height

    # Find total Y bounds
    $minY = $h; $maxY = 0
    for ($y = 0; $y -lt $h; $y += 5) {
        for ($x = 0; $x -lt $w; $x += 5) {
            if ($bmp.GetPixel($x, $y).A -gt 25) {
                if ($y -lt $minY) { $minY = $y }
                if ($y -gt $maxY) { $maxY = $y }
            }
        }
    }

    Write-Host "`n==== $maskName (Y: $minY..$maxY | $([Math]::Round($minY/$h,4))..$([Math]::Round($maxY/$h,4))) ===="

    for ($i = 0; $i -lt $numRows; $i++) {
        $t = $i / ($numRows - 1.0)
        $curY = [int]($minY + ($maxY - $minY) * $t)
        $minX = $w; $maxX = 0; $count = 0
        for ($dy = -2; $dy -le 2; $dy++) {
            $cy = [Math]::Max(0, [Math]::Min($h - 1, $curY + $dy))
            for ($x = 0; $x -lt $w; $x++) {
                if ($bmp.GetPixel($x, $cy).A -gt 25) {
                    $count++
                    if ($x -lt $minX) { $minX = $x }
                    if ($x -gt $maxX) { $maxX = $x }
                }
            }
        }
        if ($count -gt 0) {
            Write-Host "Row $i (t=$([Math]::Round($t,2)), Y=$([Math]::Round($curY/$h,4))): X = $([Math]::Round($minX/$w,4)) .. $([Math]::Round($maxX/$w,4))"
        } else {
            Write-Host "Row $i (t=$([Math]::Round($t,2)), Y=$([Math]::Round($curY/$h,4))): No pixels"
        }
    }
    $bmp.Dispose()
}

Scan-MaskLevels "mask_CHAST_02.png" 6
Scan-MaskLevels "mask_CHAST_03.png" 6

