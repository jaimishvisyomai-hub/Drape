$paths = @(
  'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe',
  'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\msedge.exe',
  'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe',
  'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\msedge.exe'
)
foreach ($p in $paths) {
  if (Test-Path $p) {
    $exe = (Get-ItemProperty $p).'(default)'
    Write-Host "FOUND: $exe"
  }
}

