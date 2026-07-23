#!/usr/bin/env bash
set -euo pipefail

REQUIRED_FLUTTER="3.41.9"
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

fail() {
  printf 'ERROR: %s\n' "$1" >&2
  exit 1
}

command -v flutter >/dev/null 2>&1 || fail "Flutter is not available on PATH. Required: Flutter ${REQUIRED_FLUTTER}."
command -v java >/dev/null 2>&1 || fail "Java is not available on PATH. Required: JDK 17."

FLUTTER_LINE="$(flutter --version 2>/dev/null | head -n 1 || true)"
case "$FLUTTER_LINE" in
  *"Flutter ${REQUIRED_FLUTTER}"*) ;;
  *) fail "Wrong Flutter version. Required ${REQUIRED_FLUTTER}; found: ${FLUTTER_LINE:-unknown}." ;;
esac

JAVA_LINE="$(java -version 2>&1 | head -n 1 || true)"
case "$JAVA_LINE" in
  *'"17.'*|*' 17.'*) ;;
  *) printf 'WARNING: JDK 17 is the tested version; found: %s\n' "$JAVA_LINE" >&2 ;;
esac

ANDROID_SDK="${ANDROID_SDK_ROOT:-${ANDROID_HOME:-}}"
[ -n "$ANDROID_SDK" ] || fail "Set ANDROID_SDK_ROOT (or ANDROID_HOME) to the Android SDK directory."
[ -d "$ANDROID_SDK" ] || fail "Android SDK directory does not exist: $ANDROID_SDK"

FLUTTER_BIN="$(command -v flutter)"
if command -v readlink >/dev/null 2>&1; then
  FLUTTER_BIN="$(readlink -f "$FLUTTER_BIN" 2>/dev/null || printf '%s' "$FLUTTER_BIN")"
fi
FLUTTER_SDK="$(cd "$(dirname "$FLUTTER_BIN")/.." && pwd)"

normalize_path() {
  printf '%s' "$1" | sed 's#\\#/#g' | sed 's#:#\\:#g'
}

LOCAL_PROPERTIES="$PROJECT_ROOT/android/local.properties"
{
  printf 'sdk.dir=%s\n' "$(normalize_path "$ANDROID_SDK")"
  printf 'flutter.sdk=%s\n' "$(normalize_path "$FLUTTER_SDK")"
  printf 'flutter.buildMode=debug\n'
  printf 'flutter.versionName=1.0.1\n'
  printf 'flutter.versionCode=10\n'
  printf 'google.maps.api.key=%s\n' "${GOOGLE_MAPS_API_KEY:-}"
} > "$LOCAL_PROPERTIES"

# The same Android Maps key is also used by the Dart Places/Routes requests.
{
  printf 'GOOGLE_MAPS_API_KEY_Android=%s\n' "${GOOGLE_MAPS_API_KEY:-}"
  printf 'GOOGLE_MAPS_API_KEY_Ios=\n'
} > "$PROJECT_ROOT/assets/.env"

cd "$PROJECT_ROOT"
printf 'Flutter: %s\n' "$FLUTTER_LINE"
printf 'Java: %s\n' "$JAVA_LINE"
printf 'Android SDK: %s\n' "$ANDROID_SDK"
printf 'Build command: flutter build apk --debug\n'

flutter pub get
flutter build apk --debug

SOURCE_APK="$PROJECT_ROOT/build/app/outputs/flutter-apk/app-debug.apk"
[ -f "$SOURCE_APK" ] || fail "Flutter reported success, but the APK was not found at $SOURCE_APK"

OUTPUT_DIR="$PROJECT_ROOT/deliverables"
OUTPUT_APK="$OUTPUT_DIR/VeszpremiTaxi-utas-debug.apk"
mkdir -p "$OUTPUT_DIR"
cp "$SOURCE_APK" "$OUTPUT_APK"

printf 'APK: %s\n' "$OUTPUT_APK"
if command -v sha256sum >/dev/null 2>&1; then
  sha256sum "$OUTPUT_APK" | tee "$OUTPUT_APK.sha256"
elif command -v shasum >/dev/null 2>&1; then
  shasum -a 256 "$OUTPUT_APK" | tee "$OUTPUT_APK.sha256"
fi
