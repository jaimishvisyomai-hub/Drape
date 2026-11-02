Add-Type -AssemblyName System.Drawing
$saree = [System.Drawing.Bitmap]::FromFile((Join-Path (Get-Location) 'crops/raw_uploaded_saree.jpg'))
Write-Host '--- Sampling U in [0.00 .. 0.18] along row Y=1580 (bottom hem) ---'
for ($u = 0.0; $u -le 0.18; $u += 0.015) {
    $x = [int]($u * ($saree.Width - 1))
    $c = $saree.GetPixel($x, 1580)
    Write-Host ('U={0:N3} (X={1}): R={2} G={3} B={4}' -f $u, $x, $c.R, $c.G, $c.B)
}
$saree.Dispose()

