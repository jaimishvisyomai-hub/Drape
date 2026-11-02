Add-Type -AssemblyName System.Drawing

function Measure-Card($path, $name) {
    $img = [System.Drawing.Bitmap]::FromFile((Join-Path (Get-Location) $path))
    $w = $img.Width
    $h = $img.Height
    Write-Host "`n$name ($w x $h):"

    for ($i = 0; $i -lt 10; $i++) {
        $yRatio = 0.38 + ($i / 9.0) * (0.90 - 0.38)
        $y = [int]($h * $yRatio)
        
        $rightX = 0
        for ($x = $w - 1; $x -ge 0; $x--) {
            $p = $img.GetPixel($x, $y)
            if (!($p.R -gt 240 -and $p.G -gt 240 -and $p.B -gt 240) -and !($p.R -lt 25 -and $p.G -lt 25 -and $p.B -lt 25) -and $p.A -gt 30) {
                $rightX = $x
                break
            }
        }
        $normX = $rightX / $w
        Write-Host ("Row {0}: Y={1:F3} -> Rightmost X={2:F3}" -f $i, $yRatio, $normX)
    }
    $img.Dispose()
}

Measure-Card "crops/sareeviz_exact_card.png" "SareeViz Target Reference"
Measure-Card "crops/current_exact_card.png" "Current App Output"

