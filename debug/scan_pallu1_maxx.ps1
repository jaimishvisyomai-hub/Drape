Add-Type -AssemblyName System.Drawing

$mPallu1 = [System.Drawing.Bitmap]::FromFile('drape-lab/mask_PALLU_01.png')
$w = $mPallu1.Width
$h = $mPallu1.Height

$yLevels = @(
    @{ Row=0; Y=0.315 },
    @{ Row=1; Y=0.400 },
    @{ Row=2; Y=0.469 },
    @{ Row=3; Y=0.536 },
    @{ Row=4; Y=0.603 },
    @{ Row=5; Y=0.669 },
    @{ Row=6; Y=0.737 },
    @{ Row=7; Y=0.804 },
    @{ Row=8; Y=0.867 },
    @{ Row=9; Y=0.932 }
)

foreach ($lvl in $yLevels) {
    $y = [int]($lvl.Y * $h)
    $maxX = 0
    for ($x = 0; $x -lt $w; $x++) {
        if ($mPallu1.GetPixel($x, $y).A -gt 25) {
            if ($x -gt $maxX) { $maxX = $x }
        }
    }
    Write-Host "Row $($lvl.Row) (Y=$($lvl.Y)) -> mask_PALLU_01 MaxX = $([Math]::Round($maxX/$w, 4))"
}
$mPallu1.Dispose()

