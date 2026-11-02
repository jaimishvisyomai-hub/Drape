Add-Type -AssemblyName System.Drawing

$img = [System.Drawing.Bitmap]::FromFile((Resolve-Path "crops/hybrid_draped_result.png"))

# Inspect column X = 500 (XNorm = 0.208) from Y = 1800 to 3300
Write-Host "Inspecting X=500 in hybrid_draped_result.png:"
for ($y = 1800; $y -lt 3300; $y += 100) {
    $c = $img.GetPixel(500, $y)
    $yNorm = [Math]::Round($y / $img.Height, 3)
    Write-Host "Y=$y ($yNorm): [$($c.R),$($c.G),$($c.B)]"
}
$img.Dispose()

