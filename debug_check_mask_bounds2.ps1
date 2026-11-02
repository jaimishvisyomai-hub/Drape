Add-Type -AssemblyName System.Drawing

function Get-MaskBounds($name) {
    $path = "drape-lab/$name"
    if (-not (Test-Path $path)) {
        $path = "assets/masks/$name"
    }
    if (-not (Test-Path $path)) {
        Write-Host "NOT FOUND: $name"
        return
    }
    $img = [System.Drawing.Bitmap]::FromFile((Resolve-Path $path))
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
    $x0 = [Math]::Round($minX/$img.Width, 3)
    $x1 = [Math]::Round($maxX/$img.Width, 3)
    $y0 = [Math]::Round($minY/$img.Height, 3)
    $y1 = [Math]::Round($maxY/$img.Height, 3)
    Write-Host "$name : count=$count, X=[$minX .. $maxX] ($x0 .. $x1), Y=[$minY .. $maxY] ($y0 .. $y1)"
    $img.Dispose()
}

Get-MaskBounds "mask_PALLU_01.png"
Get-MaskBounds "mask_PALLU_02.png"
Get-MaskBounds "mask_CHAST_01.png"
Get-MaskBounds "mask_CHAST_02.png"
Get-MaskBounds "mask_CHAST_03.png"
Get-MaskBounds "mask_PATLI_01_NEW.png"
Get-MaskBounds "mask_PATLI_07.png"

