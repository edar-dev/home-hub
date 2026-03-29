#!/usr/bin/env bash
# Release IPA (macOS + Xcode + signing required).
set -euo pipefail
cd "$(dirname "$0")/.."
flutter pub get
cd ios && pod install && cd ..
flutter build ipa --release
echo "Output: build/ios/ipa/"
