Add-Type -AssemblyName System.Drawing

function Measure-PalluInner($path, $name) {
    $img = [System.Drawing.Bitmap]::FromFile((Join-Path (Get-Location) $path))
    $w = $img.Width
    $h = $img.Height
    Write-Host "`n$name ($w x $h):"

    for ($i = 0; $i -lt 10; $i++) {
        $yRatio = 0.38 + ($i / 9.0) * (0.90 - 0.38)
        $y = [int]($h * $yRatio)
        
        # Scan from center-left across to find fabric
        $leftX = -1
        for ($x = [int]($w * 0.20); $x -lt [int]($w * 0.75); $x++) {
            $p = $img.GetPixel($x, $y)
            # check if dark green fabric
            if ($p.G -gt 40 -and $p.G -lt 120 -and $p.R -lt 100 -and $p.B -lt 100) {
                $leftX = $x
                break
            }
        }
        $normX = if ($leftX -ge 0) { $leftX / $w } else { -1 }
        Write-Host ("Row {0}: Y={1:F3} -> Inner Fabric X={2:F3}" -f $i, $yRatio, $normX)
    }
    $img.Dispose()
}

Measure-PalluInner "crops/sareeviz_exact_card.png" "SareeViz Target Reference"
Measure-PalluInner "crops/current_exact_card.png" "Current App Output"

