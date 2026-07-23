$ErrorActionPreference = "Stop"
$RequiredFlutter = "3.41.9"
$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path

$FlutterCommand = Get-Command flutter -ErrorAction SilentlyContinue
if (-not $FlutterCommand) { throw "Flutter is not available on PATH. Required: Flutter $RequiredFlutter." }

$FlutterLine = (& flutter --version | Select-Object -First 1)
if ($FlutterLine -notmatch [regex]::Escape("Flutter $RequiredFlutter")) {
    throw "Wrong Flutter version. Required $RequiredFlutter; found: $FlutterLine"
}

$JavaLine = (& java -version 2>&1 | Select-Object -First 1)
if ($JavaLine -notmatch '"17\.') {
    Write-Warning "JDK 17 is the tested version; found: $JavaLine"
}

$AndroidSdk = $env:ANDROID_SDK_ROOT
if (-not $AndroidSdk) { $AndroidSdk = $env:ANDROID_HOME }
if (-not $AndroidSdk) { throw "Set ANDROID_SDK_ROOT (or ANDROID_HOME) to the Android SDK directory." }
if (-not (Test-Path $AndroidSdk -PathType Container)) { throw "Android SDK directory does not exist: $AndroidSdk" }

$FlutterBin = (Get-Command flutter).Source
$FlutterSdk = (Resolve-Path (Join-Path (Split-Path $FlutterBin -Parent) "..")).Path

function To-GradlePath([string]$PathValue) {
    return ($PathValue -replace '\\', '/') -replace ':', '\:'
}

$LocalProperties = @(
    "sdk.dir=$(To-GradlePath $AndroidSdk)"
    "flutter.sdk=$(To-GradlePath $FlutterSdk)"
    "flutter.buildMode=debug"
    "flutter.versionName=1.0.1"
    "flutter.versionCode=10"
    "google.maps.api.key=$($env:GOOGLE_MAPS_API_KEY)"
) -join "`n"

Set-Content -Path (Join-Path $ProjectRoot "android/local.properties") -Value ($LocalProperties + "`n") -Encoding UTF8

$DotEnv = @(
    "GOOGLE_MAPS_API_KEY_Android=$($env:GOOGLE_MAPS_API_KEY)"
    "GOOGLE_MAPS_API_KEY_Ios="
) -join "`n"
Set-Content -Path (Join-Path $ProjectRoot "assets/.env") -Value ($DotEnv + "`n") -Encoding UTF8

Push-Location $ProjectRoot
try {
    Write-Host "Flutter: $FlutterLine"
    Write-Host "Java: $JavaLine"
    Write-Host "Android SDK: $AndroidSdk"
    Write-Host "Build command: flutter build apk --debug"

    & flutter pub get
    if ($LASTEXITCODE -ne 0) { throw "flutter pub get failed with exit code $LASTEXITCODE" }

    & flutter build apk --debug
    if ($LASTEXITCODE -ne 0) { throw "flutter build apk --debug failed with exit code $LASTEXITCODE" }

    $SourceApk = Join-Path $ProjectRoot "build/app/outputs/flutter-apk/app-debug.apk"
    if (-not (Test-Path $SourceApk -PathType Leaf)) { throw "APK not found: $SourceApk" }

    $OutputDir = Join-Path $ProjectRoot "deliverables"
    New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null
    $OutputApk = Join-Path $OutputDir "VeszpremiTaxi-utas-debug.apk"
    Copy-Item -Force $SourceApk $OutputApk
    $Hash = Get-FileHash -Algorithm SHA256 $OutputApk
    "$($Hash.Hash.ToLower())  VeszpremiTaxi-utas-debug.apk" | Set-Content "$OutputApk.sha256" -Encoding ASCII
    Write-Host "APK: $OutputApk"
    Write-Host "SHA256: $($Hash.Hash.ToLower())"
}
finally {
    Pop-Location
}
