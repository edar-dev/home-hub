# Build e release

## Comandi rapidi

```bash
flutter build apk --release
flutter build appbundle --release
flutter build ipa --release    # macOS + Xcode + firma
flutter build web --release
```

## Script

- Bash: [`scripts/build_android.sh`](../../scripts/build_android.sh), [`build_web.sh`](../../scripts/build_web.sh), [`build_ios.sh`](../../scripts/build_ios.sh), [`deploy_web_firebase.sh`](../../scripts/deploy_web_firebase.sh)
- PowerShell: [`scripts/build_android.ps1`](../../scripts/build_android.ps1)

## Versione

- Fonte: `pubspec.yaml` → `version: MAJOR.MINOR.PATCH+BUILD` (nome + `versionCode` Android).
- Bump: `dart run tool/bump_version.dart [build|patch|minor|major]`

## Firma Android

- Template: [`android/key.properties.example`](../../android/key.properties.example) → copia in `android/key.properties` (gitignored).
- Gradle: [`android/app/build.gradle.kts`](../../android/app/build.gradle.kts) usa release signing se `key.properties` esiste.

## iOS

- [`ios/Podfile`](../../ios/Podfile) — `pod install` nella cartella `ios/`.
- Bundle ID e team in Xcode (`Runner.xcworkspace`).

## Web e Firebase

- Output: `build/web/`
- Config hosting: [`firebase.json`](../../firebase.json) (rewrite SPA, header di sicurezza).

## CI

- [`.github/workflows/ci.yml`](../../.github/workflows/ci.yml) — analyze + test
- [`.github/workflows/release.yml`](../../.github/workflows/release.yml) — artifact release; segreti documentati nel commento in cima al file
