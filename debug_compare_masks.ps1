$f1 = [System.IO.File]::ReadAllBytes("assets/masks/mask_PALLU_01.png")
$f2 = [System.IO.File]::ReadAllBytes("drape-lab/mask_PALLU_01.png")
Write-Host "PALLU_01 byte match: $($f1.Length -eq $f2.Length)"

$f3 = [System.IO.File]::ReadAllBytes("assets/masks/mask_PALLU_02.png")
$f4 = [System.IO.File]::ReadAllBytes("drape-lab/mask_PALLU_02.png")
Write-Host "PALLU_02 byte match: $($f3.Length -eq $f4.Length)"

