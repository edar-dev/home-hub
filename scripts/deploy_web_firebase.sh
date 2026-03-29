#!/usr/bin/env bash
# Deploy build/web to Firebase Hosting. Requires: npm i -g firebase-tools, firebase login:ci token.
# Usage: FIREBASE_TOKEN=... ./scripts/deploy_web_firebase.sh
# Or:    firebase deploy --only hosting --project YOUR_PROJECT_ID
set -euo pipefail
cd "$(dirname "$0")/.."
if [[ ! -d build/web ]]; then
  echo "Run scripts/build_web.sh first." >&2
  exit 1
fi
if [[ -n "${FIREBASE_TOKEN:-}" ]]; then
  firebase deploy --only hosting --token "$FIREBASE_TOKEN" "$@"
else
  firebase deploy --only hosting "$@"
fi
