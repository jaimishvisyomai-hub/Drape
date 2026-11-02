Add-Type -AssemblyName System.Drawing

$keys = @(
    "mask_PATLI_01_NEW.png",
    "mask_PATLI_01.png",
    "mask_PATLI_02.png",
    "mask_PATLI_03.png",
    "mask_PATLI_04.png",
    "mask_PATLI_05.png",
    "mask_PATLI_06.png"
)

$mappingPath = "drape-lab/mapping.json"
$mapping = Get-Content $mappingPath | ConvertFrom-Json

foreach ($k in $keys) {
    $img = [System.Drawing.Bitmap]::FromFile((Join-Path (Get-Location) "drape-lab/$k"))
    $w = $img.Width
    $h = $img.Height
    $layer = $mapping.$k
    $rows = $layer.mesh_rows
    $cols = $layer.mesh_cols
    
    Write-Host "`n=== $k (rows=$rows, cols=$cols) ==="
    for ($r = 0; $r -lt $rows; $r++) {
        $origPt = $layer.dst_pts[$r * $cols]
        $yNorm = $origPt[1]
        $yPx = [int]($yNorm * $h)
        if ($yPx -ge $h) { $yPx = $h - 1 }
        
        $minX = $w; $maxX = 0
        for ($x = 0; $x -lt $w; $x++) {
            $p = $img.GetPixel($x, $yPx)
            if ($p.A -gt 30) {
                if ($x -lt $minX) { $minX = $x }
                if ($x -gt $maxX) { $maxX = $x }
            }
        }
        $maskMin = if ($minX -lt $w) { ($minX / $w) } else { $origPt[0] }
        $maskMax = if ($maxX -gt 0) { ($maxX / $w) } else { $origPt[0] + 0.02 }
        Write-Host ("Row {0}: Y={1:F3} | Mesh X: {2:F3} -> {3:F3} | Mask X: {4:F3} -> {5:F3}" -f $r, $yNorm, $layer.dst_pts[$r*$cols][0], $layer.dst_pts[$r*$cols+$cols-1][0], $maskMin, $maskMax)
    }
    $img.Dispose()
}

