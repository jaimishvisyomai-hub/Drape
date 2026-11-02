Add-Type -AssemblyName System.Drawing

$img = [System.Drawing.Bitmap]::FromFile('crops/hybrid_draped_result.png')
$base = [System.Drawing.Bitmap]::FromFile('drape-lab/base.jpg')
$mask2 = [System.Drawing.Bitmap]::FromFile('drape-lab/mask_PALLU_02.png')

$w = $img.Width
$h = $img.Height
Write-Host "Result Size: $w x $h"

$testPoints = @(
    @{ Name = 'Shoulder';       NormX = 0.40; NormY = 0.32 },
    @{ Name = 'Pallu_Mid';       NormX = 0.70; NormY = 0.65 },
    @{ Name = 'Pallu_Outer_92'; NormX = 0.92; NormY = 0.78 },
    @{ Name = 'Pallu_Outer_94'; NormX = 0.94; NormY = 0.78 },
    @{ Name = 'Pallu_Outer_95'; NormX = 0.95; NormY = 0.78 },
    @{ Name = 'Pallu_Outer_96'; NormX = 0.96; NormY = 0.78 },
    @{ Name = 'Pallu_Outer_97'; NormX = 0.97; NormY = 0.78 }
)

foreach ($pt in $testPoints) {
    $px = [int]($pt.NormX * $w)
    $py = [int]($pt.NormY * $h)
    $cRes = $img.GetPixel($px, $py)
    $cBase = $base.GetPixel($px, $py)
    $cM2 = $mask2.GetPixel($px, $py)
    Write-Host "$($pt.Name) ($px, $py) [X=$($pt.NormX), Y=$($pt.NormY)] => Mask_PALLU_02 Alpha: $($cM2.A) | Base: ($($cBase.R),$($cBase.G),$($cBase.B)) | Res: ($($cRes.R),$($cRes.G),$($cRes.B))"
}

$img.Dispose()
$base.Dispose()
$mask2.Dispose()

