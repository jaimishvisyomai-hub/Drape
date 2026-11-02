Add-Type -AssemblyName System.Drawing

$sv = [System.Drawing.Bitmap]::FromFile('crops/sareeviz_exact_card.png')
$w = $sv.Width
$h = $sv.Height
Write-Host "SareeViz size: $w x $h"

# Crop regions to visual inspect
# 1. Shoulder wrap
# 2. Chest
# 3. Pallu mid
# 4. Pallu lotus
# 5. Front pleats
$sv.Dispose()

