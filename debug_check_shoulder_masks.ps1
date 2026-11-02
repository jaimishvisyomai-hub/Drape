Add-Type -AssemblyName System.Drawing

# Let's inspect which mask has pixels at XNorm = 0.35 to 0.50, YNorm = 0.25 to 0.35
$masks = @("mask_CHAST_01.png", "mask_CHAST_02.png", "mask_CHAST_03.png", "mask_PALLU_01.png", "mask_PALLU_02.png")

foreach ($name in $masks) {
    $path = "drape-lab/$name"
    if (-not (Test-Path $path)) { $path = "assets/masks/$name" }
    $img = [System.Drawing.Bitmap]::FromFile((Resolve-Path $path))
    
    # Check pixels in region
    $count = 0
    for ($y = [int](0.25 * $img.Height); $y -lt [int](0.35 * $img.Height); $y += 2) {
        for ($x = [int](0.35 * $img.Width); $x -lt [int](0.55 * $img.Width); $x += 2) {
            if ($img.GetPixel($x, $y).A -gt 20) { $count++ }
        }
    }
    Write-Host "$name in [X:0.35..0.55, Y:0.25..0.35] has $count pixels"
    $img.Dispose()
}

