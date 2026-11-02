Add-Type -AssemblyName System.Drawing

$target = [System.Drawing.Bitmap]::FromFile('C:/Users/CORE i7/.gemini/antigravity/brain/02f32bd2-18d1-4ceb-a44b-30d096678914/.user_uploaded/media_1793440789961_79d5ba07.jpg')
$w = $target.Width
$h = $target.Height

Write-Host "--- Bottom Hem in SareeViz Target (Y=0.91) ---"
for ($normX = 0.20; $normX -le 0.45; $normX += 0.05) {
    $x = [int]($normX * $w)
    $y = [int](0.91 * $h)
    $c = $target.GetPixel($x, $y)
    Write-Host "Hem X=$([Math]::Round($normX,2)) ($x px) -> ($($c.R), $($c.G), $($c.B))"
}

Write-Host "`n--- Above Bottom Hem (Y=0.84) ---"
for ($normX = 0.20; $normX -le 0.45; $normX += 0.05) {
    $x = [int]($normX * $w)
    $y = [int](0.84 * $h)
    $c = $target.GetPixel($x, $y)
    Write-Host "X=$([Math]::Round($normX,2)) ($x px) -> ($($c.R), $($c.G), $($c.B))"
}

Write-Host "`n--- Mid Pleats (Y=0.70) ---"
for ($normX = 0.20; $normX -le 0.45; $normX += 0.05) {
    $x = [int]($normX * $w)
    $y = [int](0.70 * $h)
    $c = $target.GetPixel($x, $y)
    Write-Host "X=$([Math]::Round($normX,2)) ($x px) -> ($($c.R), $($c.G), $($c.B))"
}
$target.Dispose()

