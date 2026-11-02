Add-Type -AssemblyName System.Drawing
$bmp = [System.Drawing.Bitmap]::FromFile((Resolve-Path "crops/hybrid_draped_result.png").Path)
Write-Host "Image size:" $bmp.Width "x" $bmp.Height

$testPoints = @(
    @{ Name="Green Saree Left"; X=0.45; Y=0.75 },
    @{ Name="Pallu Region (was gap)"; X=0.75; Y=0.75 },
    @{ Name="Pallu Outer Edge"; X=0.92; Y=0.75 },
    @{ Name="Pure Background"; X=0.98; Y=0.75 },
    @{ Name="Lower Pallu Drape"; X=0.75; Y=0.85 }
)

foreach ($tp in $testPoints) {
    $px = [int]($bmp.Width * $tp.X)
    $py = [int]($bmp.Height * $tp.Y)
    $c = $bmp.GetPixel($px, $py)
    Write-Host ("{0,-24} at ({1:0.00},{2:0.00}) -> R:{3} G:{4} B:{5} A:{6}" -f $tp.Name, $tp.X, $tp.Y, $c.R, $c.G, $c.B, $c.A)
}
$bmp.Dispose()

