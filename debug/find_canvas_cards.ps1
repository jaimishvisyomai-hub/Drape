Add-Type -AssemblyName System.Drawing

function Find-CanvasCard($path, $label) {
    $bmp = [System.Drawing.Bitmap]::FromFile((Resolve-Path $path).Path)
    $w = $bmp.Width
    $h = $bmp.Height
    
    # Sample horizontal lines across middle y=300 to find the card's left and right border
    $cardMinX = -1; $cardMaxX = -1
    for ($x = 250; $x -lt $w; $x++) {
        $c = $bmp.GetPixel($x, 300)
        # The card is white canvas (R>240, G>240, B>240) or inside the model
        if ($c.R -gt 50 -and $c.G -gt 50 -and $c.B -gt 50) {
            if ($cardMinX -eq -1) { $cardMinX = $x }
            $cardMaxX = $x
        }
    }
    
    # Sample vertical lines across x = ($cardMinX + 10) to find top and bottom border
    $cardMinY = -1; $cardMaxY = -1
    for ($y = 40; $y -lt $h; $y++) {
        $c = $bmp.GetPixel($cardMinX + 5, $y)
        if ($c.R -gt 240 -and $c.G -gt 240 -and $c.B -gt 240) {
            if ($cardMinY -eq -1) { $cardMinY = $y }
            $cardMaxY = $y
        }
    }
    
    Write-Host "$label Card: X=[$cardMinX .. $cardMaxX] (w=$($cardMaxX-$cardMinX)), Y=[$cardMinY .. $cardMaxY] (h=$($cardMaxY-$cardMinY))"
    
    $rect = New-Object System.Drawing.Rectangle($cardMinX, $cardMinY, ($cardMaxX - $cardMinX), ($cardMaxY - $cardMinY))
    $crop = $bmp.Clone($rect, $bmp.PixelFormat)
    $crop.Save("crops/${label}_full_card.png", [System.Drawing.Imaging.ImageFormat]::Png)
    $crop.Dispose()
    $bmp.Dispose()
}

Find-CanvasCard "C:/Users/CORE i7/.gemini/antigravity/brain/02f32bd2-18d1-4ceb-a44b-30d096678914/.user_uploaded/media_1793428446789_ef4e3b17.jpg" "current"
Find-CanvasCard "C:/Users/CORE i7/.gemini/antigravity/brain/02f32bd2-18d1-4ceb-a44b-30d096678914/.user_uploaded/media_1793428452712_e5976dfa.jpg" "sareeviz"

