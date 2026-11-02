Add-Type -AssemblyName System.Drawing

function Check-Mask($path, $name) {
    $img = [System.Drawing.Bitmap]::FromFile((Join-Path (Get-Location) $path))
    $w = $img.Width
    $h = $img.Height
    Write-Host "`n$name ($w x $h):"
    
    # Check bounds of alpha > 50
    $minX = $w; $maxX = 0; $minY = $h; $maxY = 0; $count = 0
    for ($y = 0; $y -lt $h; $y += 5) {
        for ($x = 0; $x -lt $w; $x += 5) {
            $p = $img.GetPixel($x, $y)
            if ($p.A -gt 50) {
                $count++
                if ($x -lt $minX) { $minX = $x }
                if ($x -gt $maxX) { $maxX = $x }
                if ($y -lt $minY) { $minY = $y }
                if ($y -gt $maxY) { $maxY = $y }
            }
        }
    }
    Write-Host ("Alpha pixels count ~ {0}, X=[{1:F3} .. {2:F3}], Y=[{3:F3} .. {4:F3}]" -f ($count*25), ($minX/$w), ($maxX/$w), ($minY/$h), ($maxY/$h))
    $img.Dispose()
}

Check-Mask "drape-lab/mask_PATLI_01_NEW.png" "mask_PATLI_01_NEW"
Check-Mask "drape-lab/mask_PATLI_01.png" "mask_PATLI_01"
Check-Mask "drape-lab/mask_PATLI_06.png" "mask_PATLI_06"
Check-Mask "drape-lab/mask_PATLI_07.png" "mask_PATLI_07"

