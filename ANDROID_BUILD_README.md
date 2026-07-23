# Veszprémi Taxi utasapp – Android build

## Rögzített környezet

- Flutter: `3.41.9`
- Dart: `3.11.5`
- Android Gradle Plugin: `8.9.1`
- Gradle: `8.12`
- Kotlin: `2.1.0`
- JDK: `17`
- compileSdk / targetSdk: `36`
- minSdk: `24`
- application ID: `hu.veszpremitaxi.passenger`

## Debug APK

Linux/macOS:

```bash
export ANDROID_SDK_ROOT=/absolute/path/to/Android/Sdk
export GOOGLE_MAPS_API_KEY='your-key' # optional for build, required for a working map
./scripts/build_android_debug.sh
```

Windows PowerShell:

```powershell
$env:ANDROID_SDK_ROOT = "$env:LOCALAPPDATA/Android/Sdk"
$env:GOOGLE_MAPS_API_KEY = "your-key" # optional for build, required for a working map
./scripts/build_android_debug.ps1
```

The exact build command executed by both scripts is:

```bash
flutter build apk --debug
```

Expected output:

```text
build/app/outputs/flutter-apk/app-debug.apk
```

The scripts copy the result to:

```text
deliverables/VeszpremiTaxi-utas-debug.apk
```

## Current deliberate limitations

- Firebase remains disabled in `lib/utils/build_config.dart`.
- OTP uses the Laravel endpoints already configured in the app.
- The current release signing configuration is only for internal testing. Google Play publishing needs a dedicated upload keystore.
- A Google Maps API key is not included in this package. The build scripts write `GOOGLE_MAPS_API_KEY` into both Android manifest configuration and `assets/.env`. Without it, the APK can build and launch, but the map will not render correctly.
