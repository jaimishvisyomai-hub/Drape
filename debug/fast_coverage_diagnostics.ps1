Add-Type -AssemblyName System.Drawing

$cropsDir = (Resolve-Path "crops").Path
$drapeDir = (Resolve-Path "drape-lab").Path
$artifactDir = "C:\Users\CORE i7\.gemini\antigravity\brain\02f32bd2-18d1-4ceb-a44b-30d096678914"

# Load 1200x1800 scaled versions for fast pixel scanning
$w = 1200
$h = 1800

Write-Host "Loading base, result, and mask assets ($w x $h)..."
$rawBase = [System.Drawing.Bitmap]::FromFile((Join-Path $drapeDir "base.jpg"))
$base32 = New-Object System.Drawing.Bitmap($w, $h, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$gb = [System.Drawing.Graphics]::FromImage($base32)
$gb.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::Bilinear
$gb.DrawImage($rawBase, 0, 0, $w, $h)
$gb.Dispose()
$rawBase.Dispose()

$rawRes = [System.Drawing.Bitmap]::FromFile((Join-Path $cropsDir "hybrid_draped_result.png"))
$res32 = New-Object System.Drawing.Bitmap($w, $h, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$gr = [System.Drawing.Graphics]::FromImage($res32)
$gr.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::Bilinear
$gr.DrawImage($rawRes, 0, 0, $w, $h)
$gr.Dispose()
$rawRes.Dispose()

$maskNames = @(
    "mask_PATLI_07.png", "mask_patli_08.png", "mask_PATLI_06.png",
    "mask_PATLI_05.png", "mask_PATLI_04.png", "mask_PATLI_03.png",
    "mask_PATLI_02.png", "mask_PATLI_01.png", "mask_PATLI_01_NEW.png",
    "mask_CHAST_03.png", "mask_CHAST_02.png", "mask_CHAST_01.png",
    "mask_PALLU_01.png", "mask_PALLU_02.png"
)

$unionBmp = New-Object System.Drawing.Bitmap($w, $h, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$gu = [System.Drawing.Graphics]::FromImage($unionBmp)
$gu.Clear([System.Drawing.Color]::Transparent)

$maskByteArrays = @{}
$rect = New-Object System.Drawing.Rectangle(0, 0, $w, $h)

foreach ($name in $maskNames) {
    $mRaw = [System.Drawing.Bitmap]::FromFile((Join-Path $drapeDir $name))
    $m32 = New-Object System.Drawing.Bitmap($w, $h, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $gm = [System.Drawing.Graphics]::FromImage($m32)
    $gm.DrawImage($mRaw, 0, 0, $w, $h)
    $gm.Dispose()
    $mRaw.Dispose()

    $gu.DrawImage($m32, 0, 0, $w, $h)

    $bd = $m32.LockBits($rect, [System.Drawing.Imaging.ImageLockMode]::ReadOnly, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $bytes = New-Object byte[] ($w * $h * 4)
    [System.Runtime.InteropServices.Marshal]::Copy($bd.Scan0, $bytes, 0, $bytes.Length)
    $m32.UnlockBits($bd)
    $m32.Dispose()

    $maskByteArrays[$name] = $bytes
}
$gu.Dispose()

# Lock bits
$uBd = $unionBmp.LockBits($rect, [System.Drawing.Imaging.ImageLockMode]::ReadOnly, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$uBytes = New-Object byte[] ($w * $h * 4)
[System.Runtime.InteropServices.Marshal]::Copy($uBd.Scan0, $uBytes, 0, $uBytes.Length)
$unionBmp.UnlockBits($uBd)

$bBd = $base32.LockBits($rect, [System.Drawing.Imaging.ImageLockMode]::ReadOnly, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$bBytes = New-Object byte[] ($w * $h * 4)
[System.Runtime.InteropServices.Marshal]::Copy($bBd.Scan0, $bBytes, 0, $bBytes.Length)
$base32.UnlockBits($bBd)

$rBd = $res32.LockBits($rect, [System.Drawing.Imaging.ImageLockMode]::ReadOnly, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$rBytes = New-Object byte[] ($w * $h * 4)
[System.Runtime.InteropServices.Marshal]::Copy($rBd.Scan0, $rBytes, 0, $rBytes.Length)
$res32.UnlockBits($rBd)

$diffBytes = New-Object byte[] ($w * $h * 4)
$meshBytes = New-Object byte[] ($w * $h * 4)

$totalMaskPixels = 0
$coveredPixels = 0
$uncoveredPixels = 0
$uncoveredByMask = @{}
foreach ($name in $maskNames) { $uncoveredByMask[$name] = 0 }
$samples = @()

Write-Host "Evaluating silhouette pixels across 1200 x 1800..."
$len = $w * $h * 4

for ($i = 0; $i -lt $len; $i += 4) {
    $uA = $uBytes[$i + 3]
    if ($uA -gt 25) {
        $totalMaskPixels++

        $bB = $bBytes[$i]
        $bG = $bBytes[$i + 1]
        $bR = $bBytes[$i + 2]

        $rB = $rBytes[$i]
        $rG = $rBytes[$i + 1]
        $rR = $rBytes[$i + 2]

        $dist = [Math]::Abs([int]$bB - [int]$rB) + [Math]::Abs([int]$bG - [int]$rG) + [Math]::Abs([int]$bR - [int]$rR)

        if ($dist -gt 20) {
            $coveredPixels++
            # Cyan mesh coverage
            $meshBytes[$i] = 255
            $meshBytes[$i + 1] = 200
            $meshBytes[$i + 2] = 0
            $meshBytes[$i + 3] = 255

            # Covered = Dim Green
            $diffBytes[$i] = 50
            $diffBytes[$i + 1] = 160
            $diffBytes[$i + 2] = 20
            $diffBytes[$i + 3] = 255
        } else {
            $uncoveredPixels++
            # Uncovered defect = Bright Red
            $diffBytes[$i] = 0
            $diffBytes[$i + 1] = 0
            $diffBytes[$i + 2] = 255
            $diffBytes[$i + 3] = 255

            $primary = "unknown"
            foreach ($name in $maskNames) {
                if ($maskByteArrays[$name][$i + 3] -gt 25) {
                    $uncoveredByMask[$name]++
                    $primary = $name
                }
            }

            if ($samples.Count -lt 20 -and ($uncoveredPixels % 200 -eq 0)) {
                $pxIdx = $i / 4
                $py = [Math]::Floor($pxIdx / $w)
                $px = $pxIdx % $w
                $samples += [PSCustomObject]@{
                    X = $px
                    Y = $py
                    NormX = [Math]::Round($px / $w, 4)
                    NormY = [Math]::Round($py / $h, 4)
                    Mask = $primary
                    Base = "rgb($bR,$bG,$bB)"
                    Res  = "rgb($rR,$rG,$rB)"
                }
            }
        }
    } else {
        # Outside saree silhouette: Dim grayscale base
        $bB = $bBytes[$i]
        $bG = $bBytes[$i + 1]
        $bR = $bBytes[$i + 2]
        $lum = [Math]::Round(0.299 * $bR + 0.587 * $bG + 0.114 * $bB)
        $dim = [byte][Math]::Round($lum * 0.35)
        $diffBytes[$i] = $dim
        $diffBytes[$i + 1] = $dim
        $diffBytes[$i + 2] = $dim
        $diffBytes[$i + 3] = 255
    }
}

Write-Host "Total Intended Mask Pixels: $totalMaskPixels"
Write-Host "Covered Fabric Pixels: $coveredPixels ($([Math]::Round(($coveredPixels / $totalMaskPixels) * 100, 2))%)"
Write-Host "UNCOVERED Defect Pixels: $uncoveredPixels ($([Math]::Round(($uncoveredPixels / $totalMaskPixels) * 100, 2))%)"

Write-Host "`nUncovered Breakdown By Mask:"
foreach ($name in $maskNames) {
    if ($uncoveredByMask[$name] -gt 0) {
        Write-Host " - $name : $($uncoveredByMask[$name]) pixels"
    }
}

# Create Diff Bitmap
$diffBmp = New-Object System.Drawing.Bitmap($w, $h, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$dBd = $diffBmp.LockBits($rect, [System.Drawing.Imaging.ImageLockMode]::WriteOnly, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
[System.Runtime.InteropServices.Marshal]::Copy($diffBytes, 0, $dBd.Scan0, $diffBytes.Length)
$diffBmp.UnlockBits($dBd)

$diffPath = Join-Path $cropsDir "uncovered_regions_difference.png"
$diffBmp.Save($diffPath, [System.Drawing.Imaging.ImageFormat]::Png)
$diffBmp.Save((Join-Path $artifactDir "uncovered_regions_difference.png"), [System.Drawing.Imaging.ImageFormat]::Png)

# Create Mesh Bitmap
$meshBmp = New-Object System.Drawing.Bitmap($w, $h, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$mBd = $meshBmp.LockBits($rect, [System.Drawing.Imaging.ImageLockMode]::WriteOnly, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
[System.Runtime.InteropServices.Marshal]::Copy($meshBytes, 0, $mBd.Scan0, $meshBytes.Length)
$meshBmp.UnlockBits($mBd)

$meshPath = Join-Path $cropsDir "rasterized_mesh_coverage.png"
$meshBmp.Save($meshPath, [System.Drawing.Imaging.ImageFormat]::Png)
$meshBmp.Save((Join-Path $artifactDir "rasterized_mesh_coverage.png"), [System.Drawing.Imaging.ImageFormat]::Png)

# Create 5-panel Diagnostic Matrix
Write-Host "Creating 5-panel Diagnostic Matrix..."
$pw = 480
$ph = 720
$matrix = New-Object System.Drawing.Bitmap(($pw * 5), ($ph + 80), [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$gM = [System.Drawing.Graphics]::FromImage($matrix)
$gM.Clear([System.Drawing.Color]::FromArgb(17, 19, 24))

$font = New-Object System.Drawing.Font("Arial", 14, [System.Drawing.FontStyle]::Bold)
$brush = [System.Drawing.Brushes]::White

# Panel A: Union Mask
$gM.DrawString("A: Intended Silhouette Mask", $font, $brush, 15, 25)
$gM.DrawImage($unionBmp, 0, 70, $pw, $ph)

# Panel B: Mesh Coverage
$gM.DrawString("B: Mesh Coverage (No Underlay)", $font, $brush, ($pw + 15), 25)
$gM.DrawImage($meshBmp, $pw, 70, $pw, $ph)

# Panel C: Texture Alpha (Over black)
$gM.DrawString("C: Drape Fabric (Black Underlay)", $font, $brush, ($pw * 2 + 15), 25)
$alphaBmp = New-Object System.Drawing.Bitmap($pw, $ph)
$gA = [System.Drawing.Graphics]::FromImage($alphaBmp)
$gA.Clear([System.Drawing.Color]::Black)
$gA.DrawImage($res32, 0, 0, $pw, $ph)
$gM.DrawImage($alphaBmp, ($pw * 2), 70, $pw, $ph)
$gA.Dispose()
$alphaBmp.Dispose()

# Panel D: Difference Map
$gM.DrawString("D: Difference (Red=Gap, Green=Covered)", $font, $brush, ($pw * 3 + 15), 25)
$gM.DrawImage($diffBmp, ($pw * 3), 70, $pw, $ph)

# Panel E: Final Composite
$gM.DrawString("E: Final Clean Composite", $font, $brush, ($pw * 4 + 15), 25)
$gM.DrawImage($res32, ($pw * 4), 70, $pw, $ph)

$gM.Dispose()

$matrixPath = Join-Path $cropsDir "hybrid_coverage_diagnostics_5panel.png"
$matrix.Save($matrixPath, [System.Drawing.Imaging.ImageFormat]::Png)
$matrix.Save((Join-Path $artifactDir "hybrid_coverage_diagnostics_5panel.png"), [System.Drawing.Imaging.ImageFormat]::Png)
$matrix.Dispose()

Write-Host "Diagnostic matrix saved successfully!"

$samples | Format-Table -AutoSize
