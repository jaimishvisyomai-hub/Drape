Add-Type -AssemblyName System.Drawing
function Get-Dimensions($filePath) {
    $img = [System.Drawing.Bitmap]::FromFile($filePath)
    $w = $img.Width
    $h = $img.Height
    $img.Dispose()
    return "$w x $h"
}
Write-Host 'media 1 (Current Output):' (Get-Dimensions 'C:\Users\CORE i7\.gemini\antigravity\brain\02f32bd2-18d1-4ceb-a44b-30d096678914\.user_uploaded\media_1793595614500_32ba2d80.jpg')
Write-Host 'media 2 (Target SareeViz):' (Get-Dimensions 'C:\Users\CORE i7\.gemini\antigravity\brain\02f32bd2-18d1-4ceb-a44b-30d096678914\.user_uploaded\media_1793595637172_bc78bab3.jpg')

