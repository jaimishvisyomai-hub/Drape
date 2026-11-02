$chrome = "C:\Program Files\Google\Chrome\Application\chrome.exe"
$url = "http://localhost:3000"

Write-Host "Triggering fresh high-res render..."
Start-Process -FilePath $chrome -ArgumentList @("--headless", "--virtual-time-budget=5000", $url) -NoNewWindow -Wait

Write-Host "Regenerating debug pipeline image..."
& powershell -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot "generate_debug_render.ps1")

Write-Host "Regenerating comparison matrix card..."
& powershell -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot "generate_comparison_card.ps1")

Write-Host "Syncing to artifacts directory..."
$artDir = "C:\Users\CORE i7\.gemini\antigravity\brain\02f32bd2-18d1-4ceb-a44b-30d096678914"
Copy-Item "crops/pallu_debug_pipeline.png" -Destination (Join-Path $artDir "pallu_debug_pipeline.png") -Force
Copy-Item "crops/hybrid_draped_result.png" -Destination (Join-Path $artDir "hybrid_draped_result.png") -Force
Copy-Item "crops/before_after_target_comparison.png" -Destination (Join-Path $artDir "before_after_target_comparison.png") -Force

Write-Host "All renders and artifacts synchronized successfully!"

