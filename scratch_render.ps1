$chrome = "C:\Program Files\Google\Chrome\Application\chrome.exe"
$proc = Start-Process -FilePath $chrome -ArgumentList "--headless=new", "--disable-gpu", "http://localhost:3000" -PassThru
Start-Sleep -Seconds 5
Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue
Write-Host "Chrome finished. Checking crops/hybrid_draped_result.png..."
Get-Item "crops/hybrid_draped_result.png" | Select-Object LastWriteTime, Length

