Add-Type -AssemblyName System.Drawing

$img = [System.Drawing.Bitmap]::FromFile((Resolve-Path "crops/raw_uploaded_saree.jpg"))

Write-Host "Inspecting Y=1250 (V=0.781) across U:"
for ($x = 20; $x -lt $img.Width; $x += 20) {
    $u = [Math]::Round($x / $img.Width, 3)
    $c = $img.GetPixel($x, 1250)
    $type = "."
    if ($c.R -gt 130 -and $c.G -lt 80 -and $c.B -lt 80) { $type = "RED_LOTUS" }
    elseif ($c.R -gt 160 -and $c.G -gt 130 -and $c.B -lt 110) { $type = "GOLD" }
    elseif ($c.G -gt $c.R -and $c.G -gt $c.B) { $type = "GREEN" }

    Write-Host "X=$x (U=$u): [$($c.R),$($c.G),$($c.B)] -> $type"
}
$img.Dispose()

