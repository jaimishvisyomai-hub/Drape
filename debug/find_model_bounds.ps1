Add-Type -AssemblyName System.Drawing

function Analyze-Model($path, $label) {
    $bmp = [System.Drawing.Bitmap]::FromFile((Resolve-Path $path).Path)
    $w = $bmp.Width
    $h = $bmp.Height
    
    # We want to find the bounding box of the model inside the white card
    # In both screenshots, the model is on a white background: R>245, G>245, B>245
    # The model has skin (R>150, G>100, B>60), saree (R<100, G<120, B<100 or red/gold motifs)
    # The UI is dark: R<40, G<40, B<50
    $minX = $w; $maxX = 0; $minY = $h; $maxY = 0
    for ($y = 0; $y -lt $h; $y++) {
        for ($x = 0; $x -lt $w; $x++) {
            $c = $bmp.GetPixel($x, $y)
            $isDarkUI = ($c.R -lt 40 -and $c.G -lt 40 -and $c.B -lt 55)
            $isWhiteBg = ($c.R -gt 238 -and $c.G -gt 238 -and $c.B -gt 238)
            $isGreyBg = ($c.R -gt 210 -and $c.G -gt 210 -and $c.B -gt 210 -and [Math]::Abs($c.R - $c.G) -lt 5)
            if (-not $isDarkUI -and -not $isWhiteBg -and -not $isGreyBg) {
                # This is model / saree content!
                if ($x -gt 250 -and $y -gt 35) { # Ignore left sidebar and top navbar
                    if ($x -lt $minX) { $minX = $x }
                    if ($x -gt $maxX) { $maxX = $x }
                    if ($y -lt $minY) { $minY = $y }
                    if ($y -gt $maxY) { $maxY = $y }
                }
            }
        }
    }
    Write-Host "$label Model BBox: X=[$minX .. $maxX] (w=$($maxX-$minX)), Y=[$minY .. $maxY] (h=$($maxY-$minY))"
    $rect = New-Object System.Drawing.Rectangle($minX, $minY, ($maxX - $minX), ($maxY - $minY))
    $crop = $bmp.Clone($rect, $bmp.PixelFormat)
    $crop.Save("crops/${label}_model_crop.png", [System.Drawing.Imaging.ImageFormat]::Png)
    $crop.Dispose()
    $bmp.Dispose()
}

Analyze-Model "C:/Users/CORE i7/.gemini/antigravity/brain/02f32bd2-18d1-4ceb-a44b-30d096678914/.user_uploaded/media_1793428446789_ef4e3b17.jpg" "current"
Analyze-Model "C:/Users/CORE i7/.gemini/antigravity/brain/02f32bd2-18d1-4ceb-a44b-30d096678914/.user_uploaded/media_1793428452712_e5976dfa.jpg" "sareeviz"

