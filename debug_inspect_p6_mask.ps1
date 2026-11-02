Add-Type -AssemblyName System.Drawing

$img = [System.Drawing.Bitmap]::FromFile((Resolve-Path "drape-lab/mask_PATLI_06.png"))
Write-Host "mask_PATLI_06.png: $($img.Width) x $($img.Height)"

# Find bounding box and sample rows
$minX = $img.Width; $maxX = 0; $minY = $img.Height; $maxY = 0
for ($y = 0; $y -lt $img.Height; $y += 5) {
    $rowMin = -1; $rowMax = -1
    for ($x = 0; $x -lt $img.Width; $x += 5) {
        if ($img.GetPixel($x, $y).A -gt 20) {
            if ($rowMin -eq -1) { $rowMin = $x }
            $rowMax = $x
            if ($x -lt $minX) { $minX = $x }
            if ($x -gt $maxX) { $maxX = $x }
            if ($y -lt $minY) { $minY = $y }
            if ($y -gt $maxY) { $maxY = $y }
        }
    }
    if ($rowMin -ne -1 -and ($y % 100 -eq 0)) {
        Write-Host "Y=$y ($([Math]::Round($y/$img.Height, 3))): X=[$rowMin .. $rowMax] ($([Math]::Round($rowMin/$img.Width, 3)) .. $([Math]::Round($rowMax/$img.Width, 3)))"
    }
}
Write-Host "Overall bounds: X=[$minX .. $maxX] ($([Math]::Round($minX/$img.Width, 3)) .. $([Math]::Round($maxX/$img.Width, 3))), Y=[$minY .. $maxY] ($([Math]::Round($minY/$img.Height, 3)) .. $([Math]::Round($maxY/$img.Height, 3)))"
$img.Dispose()

