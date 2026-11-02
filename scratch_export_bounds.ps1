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
$result = @{}

foreach ($k in $keys) {
    $img = [System.Drawing.Bitmap]::FromFile((Join-Path (Get-Location) "drape-lab/$k"))
    $w = $img.Width
    $h = $img.Height
    $layer = $mapping.$k
    $rows = $layer.mesh_rows
    $cols = $layer.mesh_cols
    
    $rowBounds = @()
    for ($r = 0; $r -lt $rows; $r++) {
        $origPt = $layer.dst_pts[$r * $cols]
        $yNorm = $origPt[1]
        $yPx = [int]($yNorm * $h)
        if ($yPx -ge $h) { $yPx = $h - 1 }
        
        $minX = $w; $maxX = 0
        for ($x = 0; $x -lt $w; $x++) {
            $p = $img.GetPixel($x, $yPx)
            if ($p.A -gt 25) {
                if ($x -lt $minX) { $minX = $x }
                if ($x -gt $maxX) { $maxX = $x }
            }
        }
        $maskMin = if ($minX -lt $w) { [math]::Round(($minX / $w), 4) } else { [math]::Round($origPt[0], 4) }
        $maskMax = if ($maxX -gt 0) { [math]::Round(($maxX / $w), 4) } else { [math]::Round($origPt[0] + 0.02, 4) }
        $rowBounds += @{ r = $r; y = [math]::Round($yNorm, 4); minX = $maskMin; maxX = $maskMax }
    }
    $result[$k] = $rowBounds
    $img.Dispose()
}

$result | ConvertTo-Json -Depth 4 | Set-Content "scratch_pleat_mask_bounds.json"
Write-Host "Saved scratch_pleat_mask_bounds.json"

