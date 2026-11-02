Add-Type -AssemblyName System.Drawing
$sareePath = Join-Path (Get-Location) 'crops/raw_uploaded_saree.jpg'
$saree = [System.Drawing.Bitmap]::FromFile($sareePath)
Write-Host ('Raw saree size: {0} x {1}' -f $saree.Width, $saree.Height)

Write-Host '--- Sampling X at Y = 200 (normalized V = 0.125) ---'
for ($u = 0.0; $u -le 1.0; $u += 0.05) {
    $x = [int]($u * ($saree.Width - 1))
    $c = $saree.GetPixel($x, 200)
    Write-Host ('U={0:N2} (X={1}): R={2} G={3} B={4}' -f $u, $x, $c.R, $c.G, $c.B)
}
$saree.Dispose()

