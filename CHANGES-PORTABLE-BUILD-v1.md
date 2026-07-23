# Veszprémi Taxi utasapp – portable Android build patch v1

Backend files were not modified.

## Modified

- `android/gradle/wrapper/gradle-wrapper.properties`
  - Removed the Work-only `/workspace/downloads` Gradle path.
  - Uses the standard Gradle 8.12 distribution URL.
- `android/app/build.gradle.kts`
  - Removed the unused explicit CMake/NDK configuration.
  - Set Java/Kotlin bytecode target to 17.
  - Added a safe Google Maps manifest placeholder loaded from `local.properties`, Gradle property, or environment variable.
- `android/gradle.properties`
  - Removed the container-specific JVM flag.
- `android/app/src/main/AndroidManifest.xml`
  - Added coarse and fine location permissions.
  - Replaced the literal Maps placeholder with `${googleMapsApiKey}`.
- `android/app/src/main/kotlin/hu/veszpremitaxi/passenger/MainActivity.kt`
  - Moved the activity to the directory matching its package.
- `.gitignore`
  - Added local Android paths and signing secrets.

## Added

- `android/local.properties.example`
- `scripts/build_android_debug.sh`
- `scripts/build_android_debug.ps1`
- `android/key.properties.example`
- `ANDROID_BUILD_README.md`

## Removed

- `android/local.properties`
  - It contained Work-only absolute paths and must be generated for the actual build machine.
- `android/key.properties`
  - It contained only empty values and is replaced by a non-secret example file.
