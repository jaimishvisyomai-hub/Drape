Add-Type -AssemblyName System.Drawing

function Get-MaskBounds($name) {
    $img = [System.Drawing.Bitmap]::FromFile((Resolve-Path "drape-lab/masks/$name"))
    $minX = $img.Width; $maxX = 0; $minY = $img.Height; $maxY = 0; $count = 0
    for ($y = 0; $y -lt $img.Height; $y += 5) {
        for ($x = 0; $x -lt $img.Width; $x += 5) {
            $c = $img.GetPixel($x, $y)
            if ($c.A -gt 10) {
                if ($x -lt $minX) { $minX = $x }
                if ($x -gt $maxX) { $maxX = $x }
                if ($y -lt $minY) { $minY = $y }
                if ($y -gt $maxY) { $maxY = $y }
                $count++
            }
        }
    }
    Write-Host "$name : count=$count, X=[$minX .. $maxX] ($([Math]::Round($minX/$img.Width,3)) .. $([Math]::Round($maxX/$img.Width,3))), Y=[$minY .. $maxY] ($([Math]::Round($minY/$img.Height,3)) .. $([Math]::Round($maxY/$img.Height,3)))"
    $img.Dispose()
}

Get-MaskBounds "mask_PALLU_01.png"
Get-MaskBounds "mask_PALLU_02.png"
Get-MaskBounds "mask_CHAST_01.png"
Get-MaskBounds "mask_CHAST_02.png"
Get-MaskBounds "mask_CHAST_03.png"
Get-MaskBounds "mask_PATLI_01_NEW.png"
Get-MaskBounds "mask_PATLI_07.png"

