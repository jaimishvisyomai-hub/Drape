Add-Type -AssemblyName System.Drawing

$img = [System.Drawing.Bitmap]::FromFile((Resolve-Path "crops/raw_uploaded_saree.jpg"))

# At Y=1175 (V=0.734), let's inspect across all X from 0 to 960!
Write-Host "Inspecting Y=1175 across U:"
for ($x = 50; $x -lt $img.Width; $x += 30) {
    $u = [Math]::Round($x / $img.Width, 3)
    $c = $img.GetPixel($x, 1175)
    $type = "."
    if ($c.R -gt 200 -and $c.G -gt 190 -and $c.B -gt 150) { $type = "SWAN" }
    elseif ($c.R -gt 150 -and $c.G -lt 80 -and $c.B -lt 80) { $type = "RED" }
    elseif ($c.R -gt 160 -and $c.G -gt 130 -and $c.B -lt 110) { $type = "GOLD" }
    elseif ($c.G -gt $c.R -and $c.G -gt $c.B) { $type = "GREEN" }

    Write-Host "X=$x (U=$u): [$($c.R),$($c.G),$($c.B)] -> $type"
}
$img.Dispose()

