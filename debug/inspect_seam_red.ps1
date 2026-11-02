Add-Type -AssemblyName System.Drawing

$diff = [System.Drawing.Bitmap]::FromFile('crops/uncovered_regions_difference.png')
$m1 = [System.Drawing.Bitmap]::FromFile('drape-lab/mask_PALLU_01.png')
$m2 = [System.Drawing.Bitmap]::FromFile('drape-lab/mask_PALLU_02.png')
$w = $diff.Width
$h = $diff.Height

$samples = @()
for ($y = [int]($h * 0.35); $y -lt [int]($h * 0.85); $y += 20) {
    for ($x = [int]($w * 0.45); $x -lt [int]($w * 0.65); $x += 5) {
        $c = $diff.GetPixel($x, $y)
        if ($c.R -gt 200 -and $c.G -lt 50) {
            $a1 = $m1.GetPixel($x, $y).A
            $a2 = $m2.GetPixel($x, $y).A
            $samples += [PSCustomObject]@{
                X = $x
                Y = $y
                NormX = [Math]::Round($x / $w, 4)
                NormY = [Math]::Round($y / $h, 4)
                P1_A = $a1
                P2_A = $a2
            }
            break
        }
    }
}
$samples | Format-Table -AutoSize
$diff.Dispose()
$m1.Dispose()
$m2.Dispose()

