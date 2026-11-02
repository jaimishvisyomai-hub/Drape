Add-Type -AssemblyName System.Drawing

$drapeDir = (Resolve-Path "drape-lab").Path
$mappingJson = Get-Content "drape-lab/mapping.json" | ConvertFrom-Json
$layerKeys = $mappingJson.PSObject.Properties.Name

$masks = @{}
foreach ($k in $layerKeys) {
    $p = Join-Path $drapeDir $k
    if (Test-Path $p) {
        $masks[$k] = [System.Drawing.Bitmap]::FromFile($p)
    }
}

$sampleW = 1200
$sampleH = 1800

# Check Y = 0.90, 0.91, 0.92, 0.93 across X from 0.02 to 0.25
Write-Host "Union of ALL Masks in Skirt Hem Region:"
for ($yFrac = 0.88; $yFrac -le 0.93; $yFrac += 0.01) {
    $py = [int]($yFrac * $sampleH)
    $rowStr = "Y=$([Math]::Round($yFrac,2)): "
    for ($xFrac = 0.02; $xFrac -le 0.24; $xFrac += 0.02) {
        $px = [int]($xFrac * $sampleW)
        $maxA = 0
        foreach ($k in $masks.Keys) {
            $a = $masks[$k].GetPixel($px, $py).A
            if ($a -gt $maxA) { $maxA = $a }
        }
        $rowStr += "X=$([Math]::Round($xFrac,2)):A=$maxA "
    }
    Write-Host $rowStr
}

foreach ($k in $masks.Keys) {
    $masks[$k].Dispose()
}

