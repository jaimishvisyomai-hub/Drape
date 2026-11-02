Add-Type -AssemblyName System.Drawing

$mapping = Get-Content "drape-lab/mapping.json" | ConvertFrom-Json

$masks = @("mask_PALLU_01.png", "mask_PALLU_02.png", "mask_CHAST_01.png")

foreach ($m in $masks) {
    $img = [System.Drawing.Bitmap]::FromFile((Join-Path (Get-Location) "drape-lab/$m"))
    $w = $img.Width
    $h = $img.Height
    
    $minY = $h; $maxY = 0; $minX = $w; $maxX = 0
    for ($y = 0; $y -lt $h; $y += 2) {
        for ($x = 0; $x -lt $w; $x += 2) {
            $p = $img.GetPixel($x, $y)
            if ($p.A -gt 25) {
                if ($y -lt $minY) { $minY = $y }
                if ($y -gt $maxY) { $maxY = $y }
                if ($x -lt $minX) { $minX = $x }
                if ($x -gt $maxX) { $maxX = $x }
            }
        }
    }
    
    $layer = $mapping.$m
    $meshMinY = 1.0; $meshMaxY = 0.0
    foreach ($pt in $layer.dst_pts) {
        if ($pt[1] -lt $meshMinY) { $meshMinY = $pt[1] }
        if ($pt[1] -gt $meshMaxY) { $meshMaxY = $pt[1] }
    }
    
    Write-Host "`n=== $m ==="
    Write-Host ("Mask Pixel Bounds: X=[{0:F3} .. {1:F3}], Y=[{2:F3} .. {3:F3}] ({4}px .. {5}px)" -f ($minX/$w), ($maxX/$w), ($minY/$h), ($maxY/$h), $minY, $maxY)
    Write-Host ("Mesh Dest Bounds:  Y=[{0:F3} .. {1:F3}]" -f $meshMinY, $meshMaxY)
    $img.Dispose()
}

