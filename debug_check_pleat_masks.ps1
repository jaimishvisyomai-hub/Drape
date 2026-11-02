Add-Type -AssemblyName System.Drawing

$foldKeys = @(
    "mask_PATLI_01.png", "mask_PATLI_01_NEW.png", "mask_PATLI_02.png",
    "mask_PATLI_03.png", "mask_PATLI_04.png", "mask_PATLI_05.png",
    "mask_PATLI_06.png", "mask_PATLI_07.png", "mask_patli_08.png"
)

foreach ($name in $foldKeys) {
    $path = "drape-lab/$name"
    if (-not (Test-Path $path)) { $path = "assets/masks/$name" }
    $img = [System.Drawing.Bitmap]::FromFile((Resolve-Path $path))
    $minX = $img.Width; $maxX = 0; $minY = $img.Height; $maxY = 0; $cnt = 0
    for ($y = 0; $y -lt $img.Height; $y += 5) {
        for ($x = 0; $x -lt $img.Width; $x += 5) {
            if ($img.GetPixel($x, $y).A -gt 15) {
                if ($x -lt $minX) { $minX = $x }
                if ($x -gt $maxX) { $maxX = $x }
                if ($y -lt $minY) { $minY = $y }
                if ($y -gt $maxY) { $maxY = $y }
                $cnt++
            }
        }
    }
    Write-Host "$name : X=[$([Math]::Round($minX/$img.Width,3)) .. $([Math]::Round($maxX/$img.Width,3))], Y=[$([Math]::Round($minY/$img.Height,3)) .. $([Math]::Round($maxY/$img.Height,3))]"
    $img.Dispose()
}

