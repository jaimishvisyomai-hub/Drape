Add-Type -AssemblyName System.Drawing

$img = [System.Drawing.Bitmap]::FromFile('crops/hybrid_draped_result.png')
$base = [System.Drawing.Bitmap]::FromFile('drape-lab/base.jpg')
$m1 = [System.Drawing.Bitmap]::FromFile('drape-lab/mask_CHAST_01.png')
$w = $img.Width
$h = $img.Height
$mw = $m1.Width
$mh = $m1.Height

$pts = @(
  @{ X=0.45; Y=0.20 },
  @{ X=0.42; Y=0.20 },
  @{ X=0.35; Y=0.25 },
  @{ X=0.20; Y=0.30 }
)

foreach ($p in $pts) {
  $px = [int]($p.X * $w)
  $py = [int]($p.Y * $h)
  $mx = [int]($p.X * $mw)
  $my = [int]($p.Y * $mh)
  $cRes = $img.GetPixel($px, $py)
  $cBase = $base.GetPixel($px, $py)
  $cM = $m1.GetPixel($mx, $my)
  Write-Host "Point ($($p.X), $($p.Y)) - Mask Alpha: $($cM.A) | Base: ($($cBase.R),$($cBase.G),$($cBase.B)) | Res Color: ($($cRes.R),$($cRes.G),$($cRes.B))"
}

$img.Dispose()
$base.Dispose()
$m1.Dispose()

