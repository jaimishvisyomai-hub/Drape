Add-Type -AssemblyName System.Drawing
$img = [System.Drawing.Bitmap]::FromFile((Join-Path (Get-Location) "drape-lab/mask_PALLU_02.png"))
$p0 = $img.GetPixel(0, 0)
Write-Host "Pixel (0,0): A=$($p0.A), R=$($p0.R), G=$($p0.G), B=$($p0.B)"
$pCenter = $img.GetPixel(600, 900)
Write-Host "Pixel (600,900): A=$($pCenter.A), R=$($pCenter.R), G=$($pCenter.G), B=$($pCenter.B)"
$img.Dispose()

