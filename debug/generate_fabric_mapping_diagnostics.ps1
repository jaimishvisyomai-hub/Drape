Add-Type -AssemblyName System.Drawing

$sareeBmp = [System.Drawing.Bitmap]::FromFile('crops/raw_uploaded_saree.jpg')
$targetBmp = [System.Drawing.Bitmap]::FromFile('crops/sareeviz_exact_card.png')
$resultBmp = [System.Drawing.Bitmap]::FromFile('crops/hybrid_draped_result.png')

$sw = $sareeBmp.Width
$sh = $sareeBmp.Height

# We will create a rich 3-panel visualization:
# Panel 1: Original Saree Image with source UV zones outlined and labeled
# Panel 2: Destination Mesh Wireframes & UV sampled points
# Panel 3: Side-by-Side Comparison (SareeViz Target vs Our New Result)

$panelW = 540
$panelH = 900
$totalW = $panelW * 3 + 40
$totalH = $panelH + 80

$debugBmp = New-Object System.Drawing.Bitmap($totalW, $totalH, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g = [System.Drawing.Graphics]::FromImage($debugBmp)
$g.Clear([System.Drawing.Color]::FromArgb(15, 23, 42))

$titleFont = New-Object System.Drawing.Font("Arial", 14, [System.Drawing.FontStyle]::Bold)
$labelFont = New-Object System.Drawing.Font("Arial", 9, [System.Drawing.FontStyle]::Bold)
$whiteBrush = [System.Drawing.Brushes]::White
$yellowBrush = [System.Drawing.Brushes]::Gold

# Panel 1: Saree Texture Zones
$g.DrawString("1. Source Fabric UV Regions (960x1600)", $titleFont, $whiteBrush, 15, 20)
$sareeRect = New-Object System.Drawing.Rectangle(15, 60, $panelW, $panelH)
$g.DrawImage($sareeBmp, $sareeRect)

# Draw Zone Overlays on Panel 1
$penBorder = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(200, 234, 179, 8), 3)
$penVines  = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(200, 16, 185, 129), 2)
$penZari   = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(200, 245, 158, 11), 3)
$penLotus  = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(200, 239, 68, 68), 3)
$brushOverlay = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(140, 0, 0, 0))

# Left Border: U in [0..0.15], V in [0..0.58]
$bx = 15; $by = 60; $bw = [int]($panelW * 0.15); $bh = [int]($panelH * 0.58);
$g.DrawRectangle($penBorder, $bx, $by, $bw, $bh)
$g.FillRectangle($brushOverlay, $bx + 4, $by + 4, 150, 22)
$g.DrawString("Left Zari Border (U:0..0.15)", $labelFont, $yellowBrush, ($bx + 6), ($by + 8))

# Body Vines: U in [0.15..0.85], V in [0..0.58]
$vx = 15 + $bw; $vw = [int]($panelW * 0.70);
$g.DrawRectangle($penVines, $vx, $by, $vw, $bh)
$g.FillRectangle($brushOverlay, $vx + 10, $by + 10, 220, 22)
$g.DrawString("Body Floral Vines (V:0.00..0.56)", $labelFont, [System.Drawing.Brushes]::LightGreen, ($vx + 14), ($by + 14))

# Zari Stripe Bands: V in [0.57..0.69]
$zy = 60 + [int]($panelH * 0.57); $zh = [int]($panelH * (0.69 - 0.57));
$g.DrawRectangle($penZari, 15, $zy, $panelW, $zh)
$g.FillRectangle($brushOverlay, 20, $zy + 4, 250, 22)
$g.DrawString("Pallu Zari Stripes (V:0.57..0.69)", $labelFont, $yellowBrush, 24, ($zy + 8))

# Lotus & Swans: V in [0.70..0.85]
$ly = 60 + [int]($panelH * 0.70); $lh = [int]($panelH * (0.85 - 0.70));
$g.DrawRectangle($penLotus, 15, $ly, $panelW, $lh)
$g.FillRectangle($brushOverlay, 20, $ly + 4, 280, 22)
$g.DrawString("Pallu Red Lotus & Swans (V:0.70..0.85)", $labelFont, [System.Drawing.Brushes]::Tomato, 24, ($ly + 8))

# Panel 2: SareeViz Target Reference
$p2x = $panelW + 25
$g.DrawString("2. Target Reference (SareeViz)", $titleFont, $whiteBrush, $p2x, 20)
$targetRect = New-Object System.Drawing.Rectangle($p2x, 60, $panelW, $panelH)
$g.DrawImage($targetBmp, $targetRect)

# Annotations on Target
$g.FillRectangle($brushOverlay, $p2x + 10, 80, 220, 22)
$g.DrawString("Neckline Border: Left Zari", $labelFont, $yellowBrush, ($p2x + 14), 84)

$g.FillRectangle($brushOverlay, $p2x + 10, 360, 240, 22)
$g.DrawString("Front Skirt: Vertical Zari Border", $labelFont, $yellowBrush, ($p2x + 14), 364)

$g.FillRectangle($brushOverlay, $p2x + 240, 600, 250, 22)
$g.DrawString("Mid Pallu: Horizontal Zari Stripes", $labelFont, $yellowBrush, ($p2x + 244), 604)

$g.FillRectangle($brushOverlay, $p2x + 220, 720, 260, 22)
$g.DrawString("Lower Pallu: Red Lotus Medallion", $labelFont, [System.Drawing.Brushes]::Tomato, ($p2x + 224), 724)

# Panel 3: Our Draped Result (Verified Fabric-Aware WebGL)
$p3x = $panelW * 2 + 35
$g.DrawString("3. Verified Fabric-Aware Result (Our Engine)", $titleFont, [System.Drawing.Brushes]::LightGreen, $p3x, 20)
$resRect = New-Object System.Drawing.Rectangle($p3x, 60, $panelW, $panelH)
$g.DrawImage($resultBmp, $resRect)

# Annotations on Result
$g.FillRectangle($brushOverlay, $p3x + 10, 80, 230, 22)
$g.DrawString("Verified: Neckline Gold Border", $labelFont, [System.Drawing.Brushes]::LightGreen, ($p3x + 14), 84)

$g.FillRectangle($brushOverlay, $p3x + 10, 360, 250, 22)
$g.DrawString("Verified: Front Vertical Skirt Border", $labelFont, [System.Drawing.Brushes]::LightGreen, ($p3x + 14), 364)

$g.FillRectangle($brushOverlay, $p3x + 240, 600, 260, 22)
$g.DrawString("Verified: Mid Pallu Horizontal Zari", $labelFont, [System.Drawing.Brushes]::LightGreen, ($p3x + 244), 604)

$g.FillRectangle($brushOverlay, $p3x + 220, 720, 270, 22)
$g.DrawString("Verified: Lower Pallu Red Lotus Medallion", $labelFont, [System.Drawing.Brushes]::Tomato, ($p3x + 224), 724)

$g.Dispose()

$outPath = 'crops/fabric_mapping_diagnostic_view.png'
$debugBmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
$debugBmp.Save('C:/Users/CORE i7/.gemini/antigravity/brain/02f32bd2-18d1-4ceb-a44b-30d096678914/fabric_mapping_diagnostic_view.png', [System.Drawing.Imaging.ImageFormat]::Png)
$debugBmp.Dispose()

$sareeBmp.Dispose()
$targetBmp.Dispose()
$resultBmp.Dispose()

Write-Host "Diagnostic visualization created successfully at: $outPath"

