Add-Type -AssemblyName System.Drawing

$p1 = "C:/Users/CORE i7/.gemini/antigravity/brain/02f32bd2-18d1-4ceb-a44b-30d096678914/.user_uploaded/media_1793428446789_ef4e3b17.jpg"
$p2 = "C:/Users/CORE i7/.gemini/antigravity/brain/02f32bd2-18d1-4ceb-a44b-30d096678914/.user_uploaded/media_1793428452712_e5976dfa.jpg"

$img1 = [System.Drawing.Bitmap]::FromFile((Resolve-Path $p1).Path)
$img2 = [System.Drawing.Bitmap]::FromFile((Resolve-Path $p2).Path)

Write-Host "Image 1 (Current Output App UI): $($img1.Width) x $($img1.Height)"
Write-Host "Image 2 (SareeViz Target UI): $($img2.Width) x $($img2.Height)"

$img1.Dispose()
$img2.Dispose()

