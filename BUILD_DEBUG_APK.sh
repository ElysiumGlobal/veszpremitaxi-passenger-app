#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
command -v flutter >/dev/null 2>&1 || { echo "HIBA: a flutter parancs nem található." >&2; exit 127; }
flutter --version
flutter pub get
flutter analyze
flutter build apk --debug
cp -f build/app/outputs/flutter-apk/app-debug.apk VeszpremiTaxi-Driver-1.0.32-debug.apk
echo "Kész: $(pwd)/VeszpremiTaxi-Driver-1.0.32-debug.apk"
