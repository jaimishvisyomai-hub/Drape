Add-Type -AssemblyName System.Drawing

$rawPath = Join-Path (Get-Location) "crops/raw_uploaded_saree.jpg"
$raw = [System.Drawing.Bitmap]::FromFile($rawPath)
$w = $raw.Width
$h = $raw.Height

$outBmp = New-Object System.Drawing.Bitmap($w, $h)
$g = [System.Drawing.Graphics]::FromImage($outBmp)
$g.DrawImage($raw, 0, 0, $w, $h)

# Colors and zones
$zones = @(
    @{ Name = "Zone 1: Silver Jacquard Border"; Color = [System.Drawing.Color]::FromArgb(220, 230, 230, 250); Rect = New-Object System.Drawing.Rectangle(0, 0, 135, $h) },
    @{ Name = "Zone 2: Right Gold Border"; Color = [System.Drawing.Color]::FromArgb(220, 218, 165, 32); Rect = New-Object System.Drawing.Rectangle(910, 0, 50, $h) },
    @{ Name = "Zone 3: Saree Body (Floral Vines & Birds)"; Color = [System.Drawing.Color]::FromArgb(220, 34, 197, 94); Rect = New-Object System.Drawing.Rectangle(140, 0, 770, 860) },
    @{ Name = "Zone 4: Upper Horizontal Zari Stripes"; Color = [System.Drawing.Color]::FromArgb(220, 234, 179, 8); Rect = New-Object System.Drawing.Rectangle(0, 860, $w, 220) },
    @{ Name = "Zone 5: Central Medallion (Twin Swans & Lotus)"; Color = [System.Drawing.Color]::FromArgb(220, 236, 72, 153); Rect = New-Object System.Drawing.Rectangle(155, 1100, 690, 295) },
    @{ Name = "Zone 6: Lower Horizontal Zari Stripes"; Color = [System.Drawing.Color]::FromArgb(220, 245, 158, 11); Rect = New-Object System.Drawing.Rectangle(0, 1410, $w, 150) },
    @{ Name = "Zone 7: Bottom Gold Fringe Hem"; Color = [System.Drawing.Color]::FromArgb(220, 202, 138, 4); Rect = New-Object System.Drawing.Rectangle(0, 1560, $w, 40) }
)

$font = New-Object System.Drawing.Font("Arial", 14, [System.Drawing.FontStyle]::Bold)
$bgBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(190, 0, 0, 0))
$whiteBrush = New-Object System.Drawing.Brushes::White

foreach ($z in $zones) {
    $pen = New-Object System.Drawing.Pen($z.Color, 4)
    $g.DrawRectangle($pen, $z.Rect)
    $pen.Dispose()

    # Draw label box
    $text = $z.Name
    $size = $g.MeasureString($text, $font)
    $lx = [Math]::Max(10, $z.Rect.X + 10)
    $ly = [Math]::Max(10, $z.Rect.Y + 10)
    if ($ly + $size.Height -gt $h) { $ly = $h - $size.Height - 10 }
    
    $g.FillRectangle($bgBrush, $lx, $ly, $size.Width + 8, $size.Height + 4)
    $g.DrawString($text, $font, [System.Drawing.Brushes]::Yellow, [float]($lx + 4), [float]($ly + 2))
}

$font.Dispose()
$bgBrush.Dispose()
$g.Dispose()
$raw.Dispose()

$diagPath = Join-Path (Get-Location) "crops/diagnostic_1_source_saree_annotated.png"
$outBmp.Save($diagPath, [System.Drawing.Imaging.ImageFormat]::Png)
$outBmp.Dispose()

Write-Host "Diagnostic 1 generated at $diagPath"

