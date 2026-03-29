# Setup per nuovi sviluppatori

## Prerequisiti

- [Flutter SDK](https://docs.flutter.dev/get-started/install) compatibile con `environment.sdk` in `pubspec.yaml` (attualmente **Dart ^3.4.0**).
- Editor: VS Code o Android Studio con estensioni Flutter/Dart.
- Per iOS (macOS): Xcode, CocoaPods (`pod`).

## Clone e dipendenze

```bash
git clone <url-repo>
cd housekeep
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

`build_runner` rigenera gli adapter Hive (`*.g.dart`) dopo modifiche a `@HiveType` / `@HiveField`.

## IDE e qualità

- Rispettare [`analysis_options.yaml`](../../analysis_options.yaml) (flutter_lints).
- Formattazione: `dart format .`
- Analisi statica: `flutter analyze`

## Branch e contributi

Vedi [CONTRIBUTING.md](../../CONTRIBUTING.md) se presente.

## Documentazione

- Architettura: [docs/architecture/](../architecture/overview.md)
- Task comuni: [common-tasks.md](common-tasks.md)
