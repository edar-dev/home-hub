# Release Android APK + AAB. Run from repository root: .\scripts\build_android.ps1
$ErrorActionPreference = "Stop"
Set-Location (Split-Path $PSScriptRoot -Parent)
flutter pub get
flutter build apk --release
flutter build appbundle --release
Write-Host "APK: build/app/outputs/flutter-apk/app-release.apk"
Write-Host "AAB: build/app/outputs/bundle/release/app-release.aab"
