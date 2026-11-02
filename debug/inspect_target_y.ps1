Add-Type -AssemblyName System.Drawing

$target = [System.Drawing.Bitmap]::FromFile('C:/Users/CORE i7/.gemini/antigravity/brain/02f32bd2-18d1-4ceb-a44b-30d096678914/.user_uploaded/media_1793440789961_79d5ba07.jpg')
$w = $target.Width
$h = $target.Height
Write-Host "Target size: $w x $h"

for ($normY = 0.20; $normY -le 0.95; $normY += 0.05) {
    $y = [int]($normY * $h)
    $c = $target.GetPixel([int]($w * 0.55), $y)
    Write-Host "Target Y=$([Math]::Round($normY,2)) ($y px) -> ($($c.R), $($c.G), $($c.B))"
}
$target.Dispose()

