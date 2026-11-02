Add-Type -AssemblyName System.Drawing

$img = [System.Drawing.Bitmap]::FromFile('crops/hybrid_draped_result.png')
$base = [System.Drawing.Bitmap]::FromFile('drape-lab/base.jpg')
$m1 = [System.Drawing.Bitmap]::FromFile('drape-lab/mask_CHAST_01.png')
$w = $img.Width
$h = $img.Height
$mw = $m1.Width
$mh = $m1.Height

$samples = @(
  @{ NormX = 0.36; NormY = 0.1833 },
  @{ NormX = 0.3717; NormY = 0.19 },
  @{ NormX = 0.4008; NormY = 0.1922 },
  @{ NormX = 0.3175; NormY = 0.1939 },
  @{ NormX = 0.2208; NormY = 0.2256 },
  @{ NormX = 0.17; NormY = 0.2494 }
)

foreach ($p in $samples) {
  $px = [int]($p.NormX * $w)
  $py = [int]($p.NormY * $h)
  $mx = [int]($p.NormX * $mw)
  $my = [int]($p.NormY * $mh)
  $cRes = $img.GetPixel($px, $py)
  $cBase = $base.GetPixel($px, $py)
  $cM = $m1.GetPixel($mx, $my)
  Write-Host "Norm ($($p.NormX), $($p.NormY)) - MaskA: $($cM.A) | Base: ($($cBase.R),$($cBase.G),$($cBase.B)) | Res: ($($cRes.R),$($cRes.G),$($cRes.B))"
}

$img.Dispose()
$base.Dispose()
$m1.Dispose()

