Add-Type -AssemblyName System.Drawing

function Find-Card($p, $name) {
    $bmp = [System.Drawing.Bitmap]::FromFile((Resolve-Path $p).Path)
    $w = $bmp.Width
    $h = $bmp.Height
    
    # In both screenshots, the central canvas is a white rectangle inside a dark UI background (R<30, G<30, B<40)
    $minX = $w; $maxX = 0; $minY = $h; $maxY = 0
    for ($y = 0; $y -lt $h; $y += 2) {
        for ($x = 0; $x -lt $w; $x += 2) {
            $c = $bmp.GetPixel($x, $y)
            # Canvas has white or near-white background or model
            if ($c.R -gt 230 -and $c.G -gt 230 -and $c.B -gt 230) {
                # Check if it's in the right half (model preview area, x > 300)
                if ($x -gt 300) {
                    if ($x -lt $minX) { $minX = $x }
                    if ($x -gt $maxX) { $maxX = $x }
                    if ($y -lt $minY) { $minY = $y }
                    if ($y -gt $maxY) { $maxY = $y }
                }
            }
        }
    }
    Write-Host "$name Card BBox: X=[$minX .. $maxX] (w=$($maxX-$minX)), Y=[$minY .. $maxY] (h=$($maxY-$minY))"
    
    # Save cropped card
    $rect = New-Object System.Drawing.Rectangle($minX, $minY, ($maxX - $minX), ($maxY - $minY))
    $crop = $bmp.Clone($rect, $bmp.PixelFormat)
    $outPath = "crops/${name}_card.png"
    $crop.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $crop.Dispose()
    $bmp.Dispose()
    Write-Host "Saved: $outPath"
}

Find-Card "C:/Users/CORE i7/.gemini/antigravity/brain/02f32bd2-18d1-4ceb-a44b-30d096678914/.user_uploaded/media_1793428446789_ef4e3b17.jpg" "current_app"
Find-Card "C:/Users/CORE i7/.gemini/antigravity/brain/02f32bd2-18d1-4ceb-a44b-30d096678914/.user_uploaded/media_1793428452712_e5976dfa.jpg" "sareeviz_target"

