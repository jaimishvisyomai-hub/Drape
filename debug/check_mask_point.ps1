Add-Type -AssemblyName System.Drawing

$allMasks = Get-ChildItem -Path drape-lab -Filter mask_*.png
foreach ($mf in $allMasks) {
    $bmp = [System.Drawing.Bitmap]::FromFile($mf.FullName)
    $a = $bmp.GetPixel(550, 690).A
    if ($a -gt 25) {
        Write-Host "$($mf.Name) covers (550, 690) with alpha $a"
    }
    $bmp.Dispose()
}

