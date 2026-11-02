Add-Type -AssemblyName System.Drawing

for ($yFrac = 0.50; $yFrac -le 0.90; $yFrac += 0.05) {
    $yPct = [int]($yFrac * 100)
    $slicePath = "crops/slice_y_${yPct}.jpg"
    $bmp = [System.Drawing.Bitmap]::FromFile((Resolve-Path $slicePath).Path)
    
    # Calculate average red, green, blue and gold/yellow pixels
    $totalR = 0; $totalG = 0; $totalB = 0; $goldPixels = 0; $redPixels = 0
    $sampleCount = 0
    for ($y = 0; $y -lt $bmp.Height; $y += 4) {
        for ($x = 160; $x -lt $bmp.Width - 50; $x += 4) { # Ignore side borders
            $c = $bmp.GetPixel($x, $y)
            $totalR += $c.R; $totalG += $c.G; $totalB += $c.B
            $sampleCount++
            # Gold / yellow: R>150, G>130, B<120
            if ($c.R -gt 150 -and $c.G -gt 130 -and $c.B -lt 120) { $goldPixels++ }
            # Red / crimson: R>140, G<80, B<80
            if ($c.R -gt 140 -and $c.G -lt 80 -and $c.B -lt 80) { $redPixels++ }
        }
    }
    $avgR = [Math]::Round($totalR / $sampleCount, 1)
    $avgG = [Math]::Round($totalG / $sampleCount, 1)
    $avgB = [Math]::Round($totalB / $sampleCount, 1)
    $goldPct = [Math]::Round(100.0 * $goldPixels / $sampleCount, 1)
    $redPct = [Math]::Round(100.0 * $redPixels / $sampleCount, 1)
    
    Write-Host "Slice Y=${yFrac}..$([Math]::Round($yFrac+0.05,2)): AvgRGB=[$avgR, $avgG, $avgB] | Gold=${goldPct}%, Red=${redPct}%"
    $bmp.Dispose()
}

