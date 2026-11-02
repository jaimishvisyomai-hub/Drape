Add-Type -AssemblyName System.Drawing

$m1 = [System.Drawing.Bitmap]::FromFile((Resolve-Path "drape-lab/mask_PALLU_01.png"))
$m2 = [System.Drawing.Bitmap]::FromFile((Resolve-Path "drape-lab/mask_PALLU_02.png"))

$seamY = @(0.315, 0.395, 0.465, 0.533, 0.600, 0.668, 0.736, 0.803, 0.868, 0.930)
$seamX = @(0.455, 0.475, 0.496, 0.517, 0.538, 0.558, 0.580, 0.603, 0.627, 0.688)

function Get-SeamXAtY($normY) {
    if ($normY -le $seamY[0]) { return $seamX[0] }
    if ($normY -ge $seamY[-1]) { return $seamX[-1] }
    for ($i = 0; $i -lt $seamY.Count - 1; $i++) {
        if ($normY -ge $seamY[$i] -and $normY -le $seamY[$i+1]) {
            $t = ($normY - $seamY[$i]) / ($seamY[$i+1] - $seamY[$i])
            return $seamX[$i] + ($seamX[$i+1] - $seamX[$i]) * $t
        }
    }
    return $seamX[0]
}

$gaps = 0
for ($y = 570; $y -lt 1675; $y += 5) {
    $normY = $y / $m1.Height
    $targetSeamX = [int]((Get-SeamXAtY $normY) * $m1.Width)
    
    # Original M1
    $minX1 = -1; $maxX1 = -1
    for ($x = 0; $x -lt $m1.Width; $x++) {
        if ($m1.GetPixel($x, $y).A -gt 20) {
            if ($minX1 -eq -1) { $minX1 = $x }
            $maxX1 = $x
        }
    }
    # Original M2
    $minX2 = -1; $maxX2 = -1
    for ($x = 0; $x -lt $m2.Width; $x++) {
        if ($m2.GetPixel($x, $y).A -gt 20) {
            if ($minX2 -eq -1) { $minX2 = $x }
            $maxX2 = $x
        }
    }
    
    # Seam alignment with 2px bleed:
    if ($maxX1 -ne -1) {
        $maxX1 = [Math]::Max($maxX1, $targetSeamX + 2)
    }
    if ($minX2 -ne -1) {
        $minX2 = [Math]::Min($minX2, $targetSeamX - 2)
    }
    
    if ($maxX1 -ne -1 -and $minX2 -ne -1) {
        if ($minX2 -gt $maxX1) {
            $gaps++
            Write-Host "Gap at Y=$($y) : M1 max=$($maxX1) vs M2 min=$($minX2)"
        }
    }
}

Write-Host "Total gaps with seam alignment: $gaps"
$m1.Dispose()
$m2.Dispose()
