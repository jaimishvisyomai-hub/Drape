Add-Type -AssemblyName System.Drawing

$maskNames = @(
    "mask_CHAST_01.png",
    "mask_CHAST_02.png",
    "mask_CHAST_03.png",
    "mask_PALLU_01.png",
    "mask_PALLU_02.png"
)

$res = @{}

foreach ($name in $maskNames) {
    $path = Join-Path "drape-lab" $name
    $bmp = [System.Drawing.Bitmap]::FromFile($path)
    $w = $bmp.Width
    $h = $bmp.Height
    $rect = New-Object System.Drawing.Rectangle(0, 0, $w, $h)
    $bd = $bmp.LockBits($rect, [System.Drawing.Imaging.ImageLockMode]::ReadOnly, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $bytes = New-Object byte[] ($w * $h * 4)
    [System.Runtime.InteropServices.Marshal]::Copy($bd.Scan0, $bytes, 0, $bytes.Length)
    $bmp.UnlockBits($bd)
    $bmp.Dispose()

    $minX = $w; $maxX = 0; $minY = $h; $maxY = 0;
    $count = 0
    for ($y = 0; $y -lt $h; $y++) {
        for ($x = 0; $x -lt $w; $x++) {
            $idx = ($y * $w + $x) * 4
            $alpha = $bytes[$idx + 3]
            if ($alpha -gt 25) {
                $count++
                if ($x -lt $minX) { $minX = $x }
                if ($x -gt $maxX) { $maxX = $x }
                if ($y -lt $minY) { $minY = $y }
                if ($y -gt $maxY) { $maxY = $y }
            }
        }
    }

    $res[$name] = [PSCustomObject]@{
        Width = $w
        Height = $h
        AlphaPixels = $count
        MinX = $minX
        MaxX = $maxX
        MinY = $minY
        MaxY = $maxY
        NormMinX = [Math]::Round($minX / $w, 4)
        NormMaxX = [Math]::Round($maxX / $w, 4)
        NormMinY = [Math]::Round($minY / $h, 4)
        NormMaxY = [Math]::Round($maxY / $h, 4)
    }
}

$res.GetEnumerator() | ForEach-Object {
    Write-Host "`n$($_.Key):"
    $_.Value | Format-List
}

