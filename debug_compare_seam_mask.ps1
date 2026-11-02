Add-Type -AssemblyName System.Drawing

$m2 = [System.Drawing.Bitmap]::FromFile((Resolve-Path "drape-lab/mask_PALLU_02.png"))

# seamX array from drape_hybrid.js:
# Row 0: 0.455, Row 1: 0.475, Row 2: 0.496, Row 3: 0.517, Row 4: 0.538,
# Row 5: 0.558, Row 6: 0.580, Row 7: 0.603, Row 8: 0.627, Row 9: 0.688

# Check at the Y coordinate of each row
# In drape-lab/mapping.json, let's see what Y coordinates PALLU_02 has:
$mapping = Get-Content "drape-lab/mapping.json" | ConvertFrom-Json
$p2Pts = $mapping.'mask_PALLU_02.png'.dst_pts

for ($r = 0; $r -lt 10; $r++) {
    $pt0 = $p2Pts[$r * 2]
    $normX = $pt0[0]
    $normY = $pt0[1]
    $pixelY = [int]($normY * $m2.Height)
    
    # find minX in m2 at pixelY
    $maskMinX = -1
    for ($x = 0; $x -lt $m2.Width; $x++) {
        if ($m2.GetPixel($x, $pixelY).A -gt 20) {
            $maskMinX = $x
            break
        }
    }
    $maskMinXNorm = if ($maskMinX -ne -1) { [Math]::Round($maskMinX / $m2.Width, 3) } else { -1 }
    
    Write-Host "Row $r (Y=$normY): seamX=$normX vs mask_PALLU_02 minX=$maskMinXNorm (pixelX: mesh=$([int]($normX*$m2.Width)) vs mask=$maskMinX)"
}
$m2.Dispose()

