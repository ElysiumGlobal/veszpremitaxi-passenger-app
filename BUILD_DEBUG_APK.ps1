$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot
flutter --version
if ($LASTEXITCODE -ne 0) { throw "A flutter parancs nem található." }
flutter pub get
if ($LASTEXITCODE -ne 0) { throw "flutter pub get hiba" }
flutter analyze
if ($LASTEXITCODE -ne 0) { throw "flutter analyze hiba" }
flutter build apk --debug
if ($LASTEXITCODE -ne 0) { throw "flutter build apk hiba" }
Copy-Item "build/app/outputs/flutter-apk/app-debug.apk" "VeszpremiTaxi-Passenger-1.0.24-debug.apk" -Force
Write-Host "Kész: $PSScriptRoot\VeszpremiTaxi-Passenger-1.0.24-debug.apk"
