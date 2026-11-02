Add-Type -AssemblyName System.Drawing
$rawPath = Join-Path (Get-Location) "crops/raw_uploaded_saree.jpg"
$img = [System.Drawing.Bitmap]::FromFile($rawPath)
$w = $img.Width
$h = $img.Height
Write-Host "Image: $w x $h"

for ($yRatio = 0.35; $yRatio -le 0.98; $yRatio += 0.05) {
    $y = [int]($h * $yRatio)
    $redPixels = 0
    $goldPixels = 0
    $greenPixels = 0
    $sampleCount = 0
    for ($x = 0; $x -lt $w; $x += 4) {
        $sampleCount++
        $p = $img.GetPixel($x, $y)
        if ($p.R -gt 130 -and $p.G -lt 80 -and $p.B -lt 80) { 
            $redPixels++ 
        } elseif ($p.R -gt 130 -and $p.G -gt 110 -and $p.B -lt 95) { 
            $goldPixels++ 
        } elseif ($p.G -gt $p.R -and $p.G -gt $p.B) { 
            $greenPixels++ 
        }
    }
    $redPct = ($redPixels / $sampleCount) * 100
    $goldPct = ($goldPixels / $sampleCount) * 100
    $greenPct = ($greenPixels / $sampleCount) * 100
    Write-Host ("Y={0:F2} ({1}px): Red={2:F1}% Gold={3:F1}% Green={4:F1}%" -f $yRatio, $y, $redPct, $goldPct, $greenPct)
}
$img.Dispose()

