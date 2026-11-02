Add-Type -AssemblyName System.Drawing

$cur = [System.Drawing.Bitmap]::FromFile("C:\Users\CORE i7\.gemini\antigravity\brain\02f32bd2-18d1-4ceb-a44b-30d096678914\.user_uploaded\media_1793441720341_35b8af94.jpg")
$tgt = [System.Drawing.Bitmap]::FromFile("C:\Users\CORE i7\.gemini\antigravity\brain\02f32bd2-18d1-4ceb-a44b-30d096678914\.user_uploaded\media_1793441760113_87a2f0bd.jpg")

Write-Host "Current: $($cur.Width) x $($cur.Height)"
Write-Host "Target:  $($tgt.Width) x $($tgt.Height)"

$cur.Dispose()
$tgt.Dispose()

