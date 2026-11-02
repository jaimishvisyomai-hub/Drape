Add-Type -AssemblyName System.Drawing

function Describe-Slice($sliceNum) {
    $img = [System.Drawing.Bitmap]::FromFile((Resolve-Path "crops/debug_slice_$sliceNum.png"))
    Write-Host "=== SLICE $sliceNum ==="
    # Find dominant horizontal bands
    for ($y = 0; $y -lt $img.Height; $y += 10) {
        $goldCount = 0
        $redCount = 0
        $darkGreenCount = 0
        for ($x = 200; $x -lt ($img.Width - 100); $x += 10) {
            $c = $img.GetPixel($x, $y)
            if ($c.R -gt 150 -and $c.G -gt 130 -and $c.B -lt 110) { $goldCount++ }
            elseif ($c.R -gt 130 -and $c.G -lt 80 -and $c.B -lt 80) { $redCount++ }
            elseif ($c.G -gt $c.R -and $c.G -gt $c.B -and $c.G -lt 90) { $darkGreenCount++ }
        }
        $absY = $sliceNum * 200 + $y
        $v = [Math]::Round($absY / 1600, 3)
        if ($goldCount -gt 25) {
            Write-Host "Gold Band at absY=$absY (V=$v)"
        }
        if ($redCount -gt 10) {
            Write-Host "Red Motif at absY=$absY (V=$v)"
        }
    }
    $img.Dispose()
}

for ($i = 4; $i -lt 8; $i++) {
    Describe-Slice $i
}

