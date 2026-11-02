$chrome = "C:\Program Files\Google\Chrome\Application\chrome.exe"
$url = "http://localhost:3000"

Write-Host "Launching Headless Chrome to render http://localhost:3000..."
$process = Start-Process -FilePath $chrome -ArgumentList @(
    "--headless=new",
    "--disable-gpu",
    "--enable-webgl",
    "--virtual-time-budget=12000",
    "--run-all-compositor-stages-before-draw",
    $url
) -PassThru -NoNewWindow

Start-Sleep -Seconds 10
if (-not $process.HasExited) {
    Stop-Process -Id $process.Id -Force
}
Write-Host "Headless render pass completed."

