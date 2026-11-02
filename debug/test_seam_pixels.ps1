Add-Type -AssemblyName System.Drawing

$img = [System.Drawing.Bitmap]::FromFile('crops/hybrid_draped_result.png')
$base = [System.Drawing.Bitmap]::FromFile('drape-lab/base.jpg')
$mPallu1 = [System.Drawing.Bitmap]::FromFile('drape-lab/mask_PALLU_01.png')
$mPallu2 = [System.Drawing.Bitmap]::FromFile('drape-lab/mask_PALLU_02.png')

$w = $img.Width
$h = $img.Height

$testPts = @(
    @{ NormX = 0.4733; NormY = 0.4039 },
    @{ NormX = 0.485;  NormY = 0.4611 },
    @{ NormX = 0.5025; NormY = 0.5078 },
    @{ NormX = 0.9642; NormY = 0.7539 },
    @{ NormX = 0.6042; NormY = 0.7944 }
)

foreach ($pt in $testPts) {
    $px = [int]($pt.NormX * $w)
    $py = [int]($pt.NormY * $h)
    $cRes = $img.GetPixel($px, $py)
    $cBase = $base.GetPixel($px, $py)
    $mx = [int]($pt.NormX * 1200)
    $my = [int]($pt.NormY * 1800)
    $a1 = $mPallu1.GetPixel($mx, $my).A
    $a2 = $mPallu2.GetPixel($mx, $my).A
    $dist = [Math]::Abs($cRes.R - $cBase.R) + [Math]::Abs($cRes.G - $cBase.G) + [Math]::Abs($cRes.B - $cBase.B)
    Write-Host "Norm ($($pt.NormX), $($pt.NormY)) => P1_A: $a1 | P2_A: $a2 | Base: ($($cBase.R),$($cBase.G),$($cBase.B)) | Res: ($($cRes.R),$($cRes.G),$($cRes.B)) | ColorDist: $dist"
}

$img.Dispose()
$base.Dispose()
$mPallu1.Dispose()
$mPallu2.Dispose()

