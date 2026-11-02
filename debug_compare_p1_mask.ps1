Add-Type -AssemblyName System.Drawing

$m1 = [System.Drawing.Bitmap]::FromFile((Resolve-Path "drape-lab/mask_PALLU_01.png"))
$mapping = Get-Content "drape-lab/mapping.json" | ConvertFrom-Json
$p1Pts = $mapping.'mask_PALLU_01.png'.dst_pts

for ($r = 0; $r -lt 10; $r++) {
    $pt1 = $p1Pts[$r * 2 + 1] # Col 1
    $normX = $pt1[0]
    $normY = $pt1[1]
    $pixelY = [int]($normY * $m1.Height)
    
    # find maxX in m1 at pixelY
    $maskMaxX = -1
    for ($x = $m1.Width - 1; $x -ge 0; $x--) {
        if ($m1.GetPixel($x, $pixelY).A -gt 20) {
            $maskMaxX = $x
            break
        }
    }
    $maskMaxXNorm = if ($maskMaxX -ne -1) { [Math]::Round($maskMaxX / $m1.Width, 3) } else { -1 }
    
    Write-Host "Row $r (Y=$normY): P1 col1=$normX vs mask_PALLU_01 maxX=$maskMaxXNorm (pixelX: mesh=$([int]($normX*$m1.Width)) vs mask=$maskMaxX)"
}
$m1.Dispose()

