Add-Type -AssemblyName System.Drawing

$rawPath = Join-Path (Get-Location) "crops/raw_uploaded_saree.jpg"
$raw = [System.Drawing.Bitmap]::FromFile($rawPath)
$w = $raw.Width
$h = $raw.Height

$outBmp = New-Object System.Drawing.Bitmap($w, $h)
$g = [System.Drawing.Graphics]::FromImage($outBmp)
$g.DrawImage($raw, 0, 0, $w, $h)

# Load mapping.json
$mappingJson = Get-Content -Raw "drape-lab/mapping.json" | ConvertFrom-Json

$colors = @{
    'mask_CHAST_01.png' = [System.Drawing.Color]::FromArgb(255, 234, 179, 8);
    'mask_CHAST_02.png' = [System.Drawing.Color]::FromArgb(255, 250, 204, 21);
    'mask_CHAST_03.png' = [System.Drawing.Color]::FromArgb(255, 253, 224, 71);
    'mask_PALLU_01.png' = [System.Drawing.Color]::FromArgb(255, 236, 72, 153);
    'mask_PALLU_02.png' = [System.Drawing.Color]::FromArgb(255, 219, 39, 119);
    'mask_PATLI_01.png' = [System.Drawing.Color]::FromArgb(255, 59, 130, 246);
    'mask_PATLI_01_NEW.png' = [System.Drawing.Color]::FromArgb(255, 96, 165, 250);
    'mask_PATLI_02.png' = [System.Drawing.Color]::FromArgb(255, 37, 99, 235);
    'mask_PATLI_03.png' = [System.Drawing.Color]::FromArgb(255, 29, 78, 216);
    'mask_PATLI_04.png' = [System.Drawing.Color]::FromArgb(255, 30, 64, 175);
    'mask_PATLI_05.png' = [System.Drawing.Color]::FromArgb(255, 30, 58, 138);
    'mask_PATLI_06.png' = [System.Drawing.Color]::FromArgb(255, 16, 185, 129);
    'mask_PATLI_07.png' = [System.Drawing.Color]::FromArgb(255, 5, 150, 105);
    'mask_patli_08.png' = [System.Drawing.Color]::FromArgb(255, 4, 120, 87)
}

foreach ($prop in $mappingJson.PSObject.Properties) {
    $layerKey = $prop.Name
    $layer = $prop.Value
    if (-not $layer.src_pts) { continue }
    
    $rows = $layer.mesh_rows
    $cols = $layer.mesh_cols
    $pts = $layer.src_pts
    $color = $colors[$layerKey]
    if (-not $color) { $color = [System.Drawing.Color]::Cyan }
    $pen = New-Object System.Drawing.Pen($color, 2)
    
    # Draw horizontal rows
    for ($r = 0; $r -lt $rows; $r++) {
        for ($c = 0; $c -lt $cols - 1; $c++) {
            $p0 = $pts[$r * $cols + $c]
            $p1 = $pts[$r * $cols + $c + 1]
            $g.DrawLine($pen, [float]($p0[0] * $w), [float]($p0[1] * $h), [float]($p1[0] * $w), [float]($p1[1] * $h))
        }
    }
    # Draw vertical cols
    for ($c = 0; $c -lt $cols; $c++) {
        for ($r = 0; $r -lt $rows - 1; $r++) {
            $p0 = $pts[$r * $cols + $c]
            $p1 = $pts[($r + 1) * $cols + $c]
            $g.DrawLine($pen, [float]($p0[0] * $w), [float]($p0[1] * $h), [float]($p1[0] * $w), [float]($p1[1] * $h))
        }
    }
    $pen.Dispose()
}

$g.Dispose()
$raw.Dispose()

$diagPath = Join-Path (Get-Location) "crops/diagnostic_2_uv_wireframes.png"
$outBmp.Save($diagPath, [System.Drawing.Imaging.ImageFormat]::Png)
$outBmp.Dispose()

Copy-Item -Path $diagPath -Destination "c:\Users\CORE i7\.gemini\antigravity\brain\02f32bd2-18d1-4ceb-a44b-30d096678914\diagnostic_2_uv_wireframes.png" -Force
Write-Host "Diagnostic 2 generated successfully."

