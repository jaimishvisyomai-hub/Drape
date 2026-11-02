Add-Type -AssemblyName System.Drawing

$mPallu2 = [System.Drawing.Bitmap]::FromFile('drape-lab/mask_PALLU_02.png')
$w = $mPallu2.Width
$h = $mPallu2.Height

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
    $minX = $w
    for ($x = 0; $x -lt $w; $x++) {
        if ($mPallu2.GetPixel($x, $y).A -gt 25) {
            if ($x -lt $minX) { $minX = $x }
        }
    }
    Write-Host "Row $($lvl.Row) (Y=$($lvl.Y)) -> mask_PALLU_02 MinX = $([Math]::Round($minX/$w, 4))"
}
$mPallu2.Dispose()

