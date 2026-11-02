Add-Type -AssemblyName System.Drawing

$p = (Resolve-Path "C:/Users/CORE i7/.gemini/antigravity/brain/02f32bd2-18d1-4ceb-a44b-30d096678914/.user_uploaded/media_1793428446789_ef4e3b17.jpg").Path
$bmp = [System.Drawing.Bitmap]::FromFile($p)

# Sample along Y=250 from X=490 to X=850
for ($x = 490; $x -le 850; $x += 10) {
    $c = $bmp.GetPixel($x, 250)
    Write-Host "X=$x : R=$($c.R), G=$($c.G), B=$($c.B)"
}

$bmp.Dispose()

