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

foreach ($k in $keys) {
    $img = [System.Drawing.Bitmap]::FromFile((Join-Path (Get-Location) "drape-lab/$k"))
    $w = $img.Width
    $h = $img.Height
    $minX = $w; $maxX = 0
    for ($y = [int]($h * 0.90); $y -lt [int]($h * 0.92); $y += 2) {
        for ($x = 0; $x -lt $w; $x += 2) {
            $p = $img.GetPixel($x, $y)
            if ($p.A -gt 50) {
                if ($x -lt $minX) { $minX = $x }
                if ($x -gt $maxX) { $maxX = $x }
            }
        }
    }
    Write-Host ("{0} at hem (Y~0.91): X=[{1:F3} .. {2:F3}]" -f $k, ($minX/$w), ($maxX/$w))
    $img.Dispose()
}

