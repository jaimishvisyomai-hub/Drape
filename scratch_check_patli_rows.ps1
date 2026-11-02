Add-Type -AssemblyName System.Drawing

function Inspect-MaskRows($filename) {
    $p = Join-Path (Get-Location) ("drape-lab/" + $filename)
    $bmp = [System.Drawing.Bitmap]::FromFile($p)
    $w = $bmp.Width
    $h = $bmp.Height
    Write-Host "=== $filename ($w x $h) ==="
    
    # Check 10 vertical sample lines
    for ($i = 0; $i -le 10; $i++) {
        $normY = 0.45 + $i * 0.05
        $y = [int]($normY * $h)
        if ($y -ge $h) { break }
        $minX = $w; $maxX = -1
        for ($x = 0; $x -lt $w; $x++) {
            $c = $bmp.GetPixel($x, $y)
            if ($c.A -gt 20) {
                if ($x -lt $minX) { $minX = $x }
                if ($x -gt $maxX) { $maxX = $x }
            }
        }
        if ($maxX -ge $minX) {
            Write-Host ('Y={0:N2} (px={1}): minX={2:N3} maxX={3:N3} (width={4:N3})' -f $normY, $y, ($minX/$w), ($maxX/$w), (($maxX-$minX)/$w))
        } else {
            Write-Host ('Y={0:N2} (px={1}): EMPTY' -f $normY, $y)
        }
    }
    $bmp.Dispose()
}

Inspect-MaskRows 'mask_PATLI_06.png'
Inspect-MaskRows 'mask_patli_08.png'

