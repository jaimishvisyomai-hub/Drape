Add-Type -AssemblyName System.Drawing

$resPath = Join-Path (Get-Location) "crops/hybrid_draped_result.png"
$refPath = "C:/Users/CORE i7/.gemini/antigravity/brain/02f32bd2-18d1-4ceb-a44b-30d096678914/.user_uploaded/media_1793593006051_abaece7b.jpg"

$res = [System.Drawing.Bitmap]::FromFile($resPath)
$ref = [System.Drawing.Bitmap]::FromFile($refPath)

# Desired side-by-side height
$targetH = 1200
$wRes = [int]($res.Width * ($targetH / $res.Height))
$wRef = [int]($ref.Width * ($targetH / $ref.Height))
$totalW = $wRes + $wRef + 40
$totalH = $targetH + 80

$comp = New-Object System.Drawing.Bitmap($totalW, $totalH)
$g = [System.Drawing.Graphics]::FromImage($comp)
$g.Clear([System.Drawing.Color]::FromArgb(15, 23, 42))

$fontTitle = New-Object System.Drawing.Font("Arial", 20, [System.Drawing.FontStyle]::Bold)
$fontSub = New-Object System.Drawing.Font("Arial", 14, [System.Drawing.FontStyle]::Regular)

# Draw headers
$g.DrawString("CURRENT HYBRID DRAPE (CORRECTED)", $fontTitle, [System.Drawing.Brushes]::White, 30, 20)
$g.DrawString("SAREEVIZ TARGET REFERENCE", $fontTitle, [System.Drawing.Brushes]::White, [float]($wRes + 50), 20)

# Draw images
$g.DrawImage($res, 20, 60, $wRes, $targetH)
$g.DrawImage($ref, $wRes + 40, 60, $wRef, $targetH)

$fontTitle.Dispose()
$fontSub.Dispose()
$g.Dispose()
$res.Dispose()
$ref.Dispose()

$d6Path = Join-Path (Get-Location) "crops/diagnostic_6_final_comparison.png"
$comp.Save($d6Path, [System.Drawing.Imaging.ImageFormat]::Png)
$comp.Dispose()

Copy-Item -Path $d6Path -Destination "c:\Users\CORE i7\.gemini\antigravity\brain\02f32bd2-18d1-4ceb-a44b-30d096678914\diagnostic_6_final_comparison.png" -Force
Write-Host "Diagnostic 6 generated successfully."

