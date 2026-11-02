Add-Type -AssemblyName System.Drawing

$imgTgt = [System.Drawing.Bitmap]::FromFile("C:\Users\CORE i7\.gemini\antigravity\brain\02f32bd2-18d1-4ceb-a44b-30d096678914\.user_uploaded\media_1793593006051_abaece7b.jpg")
$imgCur = [System.Drawing.Bitmap]::FromFile("C:\Users\CORE i7\.gemini\antigravity\brain\02f32bd2-18d1-4ceb-a44b-30d096678914\.user_uploaded\media_1793593009182_92517453.jpg")
$imgSaree = [System.Drawing.Bitmap]::FromFile("C:\Users\CORE i7\.gemini\antigravity\brain\02f32bd2-18d1-4ceb-a44b-30d096678914\.user_uploaded\media_1793593037029_5ead20a4.jpg")

Write-Host "Target (SareeViz): $($imgTgt.Width) x $($imgTgt.Height)"
Write-Host "Current Render:    $($imgCur.Width) x $($imgCur.Height)"
Write-Host "Raw Saree:         $($imgSaree.Width) x $($imgSaree.Height)"

$imgTgt.Dispose()
$imgCur.Dispose()
$imgSaree.Dispose()

