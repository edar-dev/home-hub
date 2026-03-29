#!/usr/bin/env bash
# Release Android APK + AAB. Run from repository root.
set -euo pipefail
cd "$(dirname "$0")/.."
flutter pub get
flutter build apk --release
flutter build appbundle --release
echo "APK: build/app/outputs/flutter-apk/app-release.apk"
echo "AAB: build/app/outputs/bundle/release/app-release.aab"
