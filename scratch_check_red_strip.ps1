Add-Type -AssemblyName System.Drawing
$img = [System.Drawing.Bitmap]::FromFile((Join-Path (Get-Location) 'crops/hybrid_draped_result.png'))
for ($x = 1200; $x -le 2200; $x += 100) {
    $c = $img.GetPixel($x, 2600)
    Write-Host ('X={0}: R={1} G={2} B={3}' -f $x, $c.R, $c.G, $c.B)
}
$img.Dispose()

