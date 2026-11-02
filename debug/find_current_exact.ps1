Add-Type -AssemblyName System.Drawing

$p = "C:/Users/CORE i7/.gemini/antigravity/brain/02f32bd2-18d1-4ceb-a44b-30d096678914/.user_uploaded/media_1793428446789_ef4e3b17.jpg"
$bmp = [System.Drawing.Bitmap]::FromFile((Resolve-Path $p).Path)

# Check row 200 (across model's shoulders)
Write-Host "Row 200 scan for Image 1:"
$minX = -1; $maxX = -1
for ($x = 350; $x -lt $bmp.Width; $x++) {
    $c = $bmp.GetPixel($x, 200)
    # The canvas is white or contains the model
    $isDark = ($c.R -lt 30 -and $c.G -lt 30 -and $c.B -lt 40)
    if (-not $isDark) {
        if ($minX -eq -1) { $minX = $x }
        $maxX = $x
    }
}
Write-Host "Canvas X=[$minX .. $maxX] (width=$($maxX-$minX))"

# Check col $minX + 5 to find top and bottom of canvas
$minY = -1; $maxY = -1
for ($y = 50; $y -lt $bmp.Height; $y++) {
    $c = $bmp.GetPixel($minX + 5, $y)
    $isDark = ($c.R -lt 30 -and $c.G -lt 30 -and $c.B -lt 40)
    if (-not $isDark) {
        if ($minY -eq -1) { $minY = $y }
        $maxY = $y
    }
}
Write-Host "Canvas Y=[$minY .. $maxY] (height=$($maxY-$minY))"

$rect = New-Object System.Drawing.Rectangle($minX, $minY, ($maxX - $minX), ($maxY - $minY))
$crop = $bmp.Clone($rect, $bmp.PixelFormat)
$crop.Save("crops/current_canvas_exact.png", [System.Drawing.Imaging.ImageFormat]::Png)
$crop.Dispose()
$bmp.Dispose()
Write-Host "Saved crops/current_canvas_exact.png"

