Add-Type -AssemblyName System.Drawing

function Inspect-Pallu($path) {
    $fullPath = Join-Path (Get-Location) $path
    $bmp = New-Object System.Drawing.Bitmap($fullPath)
    Write-Host "=== $path ($($bmp.Width)x$($bmp.Height)) ==="
    $ys = @(0.55, 0.65, 0.75, 0.85)
    $xs = @(0.55, 0.65, 0.75, 0.85, 0.92)
    foreach ($yFrac in $ys) {
        $y = [int]($yFrac * $bmp.Height)
        $rowStr = "Y=${yFrac} : "
        foreach ($xFrac in $xs) {
            $x = [int]($xFrac * $bmp.Width)
            if ($x -lt $bmp.Width -and $y -lt $bmp.Height) {
                $c = $bmp.GetPixel($x, $y)
                $rowStr += "X=${xFrac}:[${c.R},${c.G},${c.B}] "
            }
        }
        Write-Host $rowStr
    }
    $bmp.Dispose()
}

Inspect-Pallu "crops/current_card.png"
Inspect-Pallu "crops/target_card.png"
