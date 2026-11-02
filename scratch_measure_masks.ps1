Add-Type -AssemblyName System.Drawing

function Measure-MaskAlpha($path, $name) {
    $img = [System.Drawing.Bitmap]::FromFile((Join-Path (Get-Location) $path))
    $w = $img.Width
    $h = $img.Height
    Write-Host "`n$name ($w x $h):"

    for ($i = 0; $i -lt 10; $i++) {
        $yRatio = 0.38 + ($i / 9.0) * (0.90 - 0.38)
        $y = [int]($h * $yRatio)
        
        $minX = -1
        $maxX = -1
        for ($x = 0; $x -lt $w; $x++) {
            $p = $img.GetPixel($x, $y)
            if ($p.A -gt 128) {
                if ($minX -lt 0) { $minX = $x }
                $maxX = $x
            }
        }
        $normMin = if ($minX -ge 0) { ($minX / $w).ToString("F3") } else { "none" }
        $normMax = if ($maxX -ge 0) { ($maxX / $w).ToString("F3") } else { "none" }
        Write-Host ("Row {0}: Y={1:F3} -> MinX={2}, MaxX={3}" -f $i, $yRatio, $normMin, $normMax)
    }
    $img.Dispose()
}

Measure-MaskAlpha "drape-lab/mask_PALLU_01.png" "mask_PALLU_01"
Measure-MaskAlpha "drape-lab/mask_PALLU_02.png" "mask_PALLU_02"
