Add-Type -AssemblyName System.Drawing
$img = [System.Drawing.Bitmap]::FromFile((Join-Path (Get-Location) 'crops/raw_uploaded_saree.jpg'))
Write-Host ('Raw saree size: {0} x {1}' -f $img.Width, $img.Height)

# Central medallion is around X ~ 155 to 845, Y ~ 1100 to 1395
# Sample the lotus flower center color at X=480 (U=0.50), Y=1250 (V=0.781)
$c = $img.GetPixel(480, 1250)
Write-Host ('Pixel at (480, 1250): R={0} G={1} B={2}' -f $c.R, $c.G, $c.B)
$img.Dispose()

