Add-Type -AssemblyName System.Drawing

function Inspect-Mask($relPath) {
    $fullPath = Join-Path (Get-Location) $relPath
    if (-not (Test-Path $fullPath)) {
        Write-Host "File not found: $fullPath"
        return
    }
    $bmp = New-Object System.Drawing.Bitmap($fullPath)
    $w = $bmp.Width
    $h = $bmp.Height
    $minX = $w
    $maxX = 0
    $minY = $h
    $maxY = 0
    for ($y = 0; $y -lt $h; $y += 5) {
        for ($x = 0; $x -lt $w; $x += 5) {
            $pixel = $bmp.GetPixel($x, $y)
            if ($pixel.A -gt 15) {
                if ($x -lt $minX) { $minX = $x }
                if ($x -gt $maxX) { $maxX = $x }
                if ($y -lt $minY) { $minY = $y }
                if ($y -gt $maxY) { $maxY = $y }
            }
        }
    }
    $bmp.Dispose()
    $minXNorm = [math]::Round($minX / $w, 4)
    $maxXNorm = [math]::Round($maxX / $w, 4)
    $minYNorm = [math]::Round($minY / $h, 4)
    $maxYNorm = [math]::Round($maxY / $h, 4)
    Write-Host "$relPath : Size ${w}x${h} | Alpha BBox: X: [$minX .. $maxX] ($minXNorm .. $maxXNorm), Y: [$minY .. $maxY] ($minYNorm .. $maxYNorm)"
}

Inspect-Mask "drape-lab/mask_PALLU_01.png"
Inspect-Mask "drape-lab/mask_PALLU_02.png"
