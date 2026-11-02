Add-Type -AssemblyName System.Drawing

$cropsDir = (Resolve-Path "crops").Path
$drapeDir = (Resolve-Path "drape-lab").Path

Write-Host "Loading base, result, and mask assets..."
$baseBmp = [System.Drawing.Bitmap]::FromFile((Join-Path $drapeDir "base.jpg"))
$resBmp  = [System.Drawing.Bitmap]::FromFile((Join-Path $cropsDir "hybrid_draped_result.png"))

$w = $resBmp.Width
$h = $resBmp.Height
Write-Host "Image dimensions: $w x $h"

# List of all 14 garment masks
$maskNames = @(
    "mask_PATLI_07.png",
    "mask_patli_08.png",
    "mask_PATLI_06.png",
    "mask_PATLI_05.png",
    "mask_PATLI_04.png",
    "mask_PATLI_03.png",
    "mask_PATLI_02.png",
    "mask_PATLI_01.png",
    "mask_PATLI_01_NEW.png",
    "mask_CHAST_03.png",
    "mask_CHAST_02.png",
    "mask_CHAST_01.png",
    "mask_PALLU_01.png",
    "mask_PALLU_02.png"
)

$masks = @{}
foreach ($name in $maskNames) {
    $masks[$name] = [System.Drawing.Bitmap]::FromFile((Join-Path $drapeDir $name))
}

# Scan across model canvas to find any pixel covered by ANY mask but still showing base model
$uncoveredRegions = @{}
$totalMaskPixels = 0
$totalCoveredFabricPixels = 0
$totalUncoveredPixels = 0

# Sample every 4th pixel for high speed and thorough spatial coverage
$step = 4

Write-Host "Scanning intended silhouette for uncovered pixels..."
for ($y = 0; $y -lt $h; $y += $step) {
    for ($x = 0; $x -lt $w; $x += $step) {
        
        # Check which mask(s) cover this pixel
        $coveringMasks = @()
        foreach ($name in $maskNames) {
            $mBmp = $masks[$name]
            # scale coordinates to mask dimensions (masks are 1200x1800, base is 2400x3600)
            $mx = [int]($x * $mBmp.Width / $w)
            $my = [int]($y * $mBmp.Height / $h)
            if ($mx -ge 0 -and $mx -lt $mBmp.Width -and $my -ge 0 -and $my -lt $mBmp.Height) {
                $mPixel = $mBmp.GetPixel($mx, $my)
                if ($mPixel.A -gt 35) {
                    $coveringMasks += $name
                }
            }
        }
        
        if ($coveringMasks.Count -gt 0) {
            $totalMaskPixels++
            
            # Compare result pixel with base model pixel
            $resP = $resBmp.GetPixel($x, $y)
            $baseP = $baseBmp.GetPixel($x, $y)
            
            # Distance between result pixel and base model pixel
            $diff = [Math]::Abs($resP.R - $baseP.R) + [Math]::Abs($resP.G - $baseP.G) + [Math]::Abs($resP.B - $baseP.B)
            
            # In base model, white saree has R>200, G>200, B>200
            $isBaseWhiteSaree = ($baseP.R -gt 210 -and $baseP.G -gt 210 -and $baseP.B -gt 210)
            $isResultWhiteSaree = ($resP.R -gt 200 -and $resP.G -gt 200 -and $resP.B -gt 200)
            
            # If result pixel is identical to base model or matches base white saree while mask expects fabric
            if ($diff -lt 12 -or ($isBaseWhiteSaree -and $isResultWhiteSaree -and $diff -lt 35)) {
                $totalUncoveredPixels++
                $primaryMask = $coveringMasks[$coveringMasks.Count - 1] # top-most mask
                
                if (-not $uncoveredRegions.ContainsKey($primaryMask)) {
                    $uncoveredRegions[$primaryMask] = @{
                        Count = 0
                        MinX = $x; MaxX = $x
                        MinY = $y; MaxY = $y
                        Samples = @()
                    }
                }
                
                $reg = $uncoveredRegions[$primaryMask]
                $reg.Count++
                if ($x -lt $reg.MinX) { $reg.MinX = $x }
                if ($x -gt $reg.MaxX) { $reg.MaxX = $x }
                if ($y -lt $reg.MinY) { $reg.MinY = $y }
                if ($y -gt $reg.MaxY) { $reg.MaxY = $y }
                if ($reg.Samples.Count -lt 5) {
                    $reg.Samples += @{ X = $x; Y = $y; NormX = [Math]::Round($x/$w, 4); NormY = [Math]::Round($y/$h, 4) }
                }
            } else {
                $totalCoveredFabricPixels++
            }
        }
    }
}

Write-Host "`n========================================================"
Write-Host "   UNCOVERED PIXELS AUDIT REPORT (NO ARTIFICIAL FILL)    "
Write-Host "========================================================"
Write-Host ("Total Mask Silhouette Pixels Sampled: {0}" -f $totalMaskPixels)
Write-Host ("Total Covered by Real Fabric Texture: {0} ({1:F2}%)" -f $totalCoveredFabricPixels, ($totalCoveredFabricPixels/$totalMaskPixels*100))
Write-Host ("Total UNCOVERED Defect Pixels:        {0} ({1:F2}%)" -f $totalUncoveredPixels, ($totalUncoveredPixels/$totalMaskPixels*100))

Write-Host "`nBreakdown of Uncovered Regions by Garment Mask:"
foreach ($key in $uncoveredRegions.Keys) {
    $info = $uncoveredRegions[$key]
    Write-Host ("`nMask: {0}" -f $key)
    Write-Host ("  Uncovered Pixels: ~{0} (Sampled: {1})" -f ($info.Count * 16), $info.Count)
    Write-Host ("  Pixel Bounding Box: X=[{0} .. {1}] ({2:F3} .. {3:F3}), Y=[{4} .. {5}] ({6:F3} .. {7:F3})" -f $info.MinX, $info.MaxX, ($info.MinX/$w), ($info.MaxX/$w), $info.MinY, $info.MaxY, ($info.MinY/$h), ($info.MaxY/$h))
    Write-Host "  Sample Coordinates:"
    foreach ($s in $info.Samples) {
        Write-Host ("    ({0}, {1}) -> Norm: [{2:F3}, {3:F3}]" -f $s.X, $s.Y, $s.NormX, $s.NormY)
    }
}

# Dispose bitmaps
$baseBmp.Dispose()
$resBmp.Dispose()
foreach ($name in $maskNames) {
    $masks[$name].Dispose()
}

