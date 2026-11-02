Add-Type -AssemblyName System.Drawing
$img = [System.Drawing.Bitmap]::FromFile((Resolve-Path "crops/raw_uploaded_saree.jpg"))
Write-Host "crops/raw_uploaded_saree.jpg: $($img.Width) x $($img.Height)"
$img.Dispose()

