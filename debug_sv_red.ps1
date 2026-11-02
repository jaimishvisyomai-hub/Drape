Add-Type -AssemblyName System.Drawing
$sv = [System.Drawing.Bitmap]::FromFile((Resolve-Path "crops/sareeviz_exact_card.png"))
Write-Host "Sareeviz size: $($sv.Width) x $($sv.Height)"

for ($y = 0; $y -lt $sv.Height; $y += 20) {
    $reds = 0
    for ($x = 0; $x -lt $sv.Width; $x += 10) {
        $c = $sv.GetPixel($x, $y)
        if ($c.R -gt 130 -and $c.G -lt 80 -and $c.B -lt 80) { $reds++ }
    }
    if ($reds -gt 5) {
        Write-Host "SareeViz RED at Y=$($y) : $($reds) pixels"
    }
}
$sv.Dispose()
