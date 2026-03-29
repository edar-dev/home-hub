#!/usr/bin/env bash
# Release web build. Optional: BASE_HREF=/app/ ./scripts/build_web.sh
set -euo pipefail
cd "$(dirname "$0")/.."
flutter pub get
if [[ -n "${BASE_HREF:-}" ]]; then
  flutter build web --release --base-href "$BASE_HREF"
else
  flutter build web --release
fi
echo "Output: build/web/"
