Add-Type -AssemblyName System.Drawing

function Get-MaskBounds($filename) {
    $p = Join-Path (Get-Location) ("drape-lab/" + $filename)
    $bmp = [System.Drawing.Bitmap]::FromFile($p)
    $w = $bmp.Width
    $h = $bmp.Height
    $minX = $w; $maxX = 0; $minY = $h; $maxY = 0
    $nonZero = 0
    for ($y = 0; $y -lt $h; $y += 2) {
        for ($x = 0; $x -lt $w; $x += 2) {
            $c = $bmp.GetPixel($x, $y)
            if ($c.A -gt 10) {
                $nonZero++
                if ($x -lt $minX) { $minX = $x }
                if ($x -gt $maxX) { $maxX = $x }
                if ($y -lt $minY) { $minY = $y }
                if ($y -gt $maxY) { $maxY = $y }
            }
        }
    }
    $c00 = $bmp.GetPixel(0, 0)
    $bmp.Dispose()
    return @{ name = $filename; minX = $minX/$w; maxX = $maxX/$w; minY = $minY/$h; maxY = $maxY/$h; c00 = "$($c00.R),$($c00.G),$($c00.B),$($c00.A)"; nonZero = $nonZero }
}

$masks = @('mask_CHAST_01.png', 'mask_CHAST_02.png', 'mask_CHAST_03.png', 'mask_PATLI_06.png', 'mask_patli_08.png')
foreach ($m in $masks) {
    $b = Get-MaskBounds $m
    Write-Host ('{0} : X=[{1:N3}..{2:N3}], Y=[{3:N3}..{4:N3}] c00=({5}) nonZero={6}' -f $b.name, $b.minX, $b.maxX, $b.minY, $b.maxY, $b.c00, $b.nonZero)
}
