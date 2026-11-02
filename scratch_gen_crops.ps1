Add-Type -AssemblyName System.Drawing

$fullPath = Join-Path (Get-Location) "crops/hybrid_draped_result.png"
$full = [System.Drawing.Bitmap]::FromFile($fullPath)
$W = $full.Width
$H = $full.Height

# Diagnostic 3: Chest only (X ~ 0.10..0.52, Y ~ 0.16..0.48)
$rChest = New-Object System.Drawing.Rectangle([int](0.10 * $W), [int](0.16 * $H), [int](0.44 * $W), [int](0.32 * $H))
$cropChest = $full.Clone($rChest, $full.PixelFormat)
$d3Path = Join-Path (Get-Location) "crops/diagnostic_3_chest_only.png"
$cropChest.Save($d3Path, [System.Drawing.Imaging.ImageFormat]::Png)
$cropChest.Dispose()
Copy-Item -Path $d3Path -Destination "c:\Users\CORE i7\.gemini\antigravity\brain\02f32bd2-18d1-4ceb-a44b-30d096678914\diagnostic_3_chest_only.png" -Force
Write-Host "Diagnostic 3 saved."

# Diagnostic 4: Pleats only (X ~ 0.00..0.28, Y ~ 0.46..0.96)
$rPleats = New-Object System.Drawing.Rectangle([int](0.00 * $W), [int](0.46 * $H), [int](0.30 * $W), [int](0.50 * $H))
$cropPleats = $full.Clone($rPleats, $full.PixelFormat)
$d4Path = Join-Path (Get-Location) "crops/diagnostic_4_pleats_only.png"
$cropPleats.Save($d4Path, [System.Drawing.Imaging.ImageFormat]::Png)
$cropPleats.Dispose()
Copy-Item -Path $d4Path -Destination "c:\Users\CORE i7\.gemini\antigravity\brain\02f32bd2-18d1-4ceb-a44b-30d096678914\diagnostic_4_pleats_only.png" -Force
Write-Host "Diagnostic 4 saved."

# Diagnostic 5: Pallu only (X ~ 0.20..1.00, Y ~ 0.28..0.98)
$rPallu = New-Object System.Drawing.Rectangle([int](0.20 * $W), [int](0.28 * $H), [int](0.80 * $W), [int](0.70 * $H))
$cropPallu = $full.Clone($rPallu, $full.PixelFormat)
$d5Path = Join-Path (Get-Location) "crops/diagnostic_5_pallu_only.png"
$cropPallu.Save($d5Path, [System.Drawing.Imaging.ImageFormat]::Png)
$cropPallu.Dispose()
Copy-Item -Path $d5Path -Destination "c:\Users\CORE i7\.gemini\antigravity\brain\02f32bd2-18d1-4ceb-a44b-30d096678914\diagnostic_5_pallu_only.png" -Force
Write-Host "Diagnostic 5 saved."

$full.Dispose()

