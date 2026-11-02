Add-Type -AssemblyName System.Drawing

function Scan-MaskLevels($maskName, $rows) {
    $path = Join-Path "drape-lab" $maskName
    $bmp = [System.Drawing.Bitmap]::FromFile($path)
    $w = $bmp.Width
    $h = $bmp.Height
    Write-Host "`n==== $maskName ($rows rows) ===="
    for ($i = 0; $i -lt $rows; $i++) {
        $t = $i / ($rows - 1.0)
        # Search Y level
        # We find min and max across all alpha pixels first
        $minY = $h; $maxY = 0;
        # We can just sample along the proportion
    }
}

