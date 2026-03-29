# Housekeep

App Flutter per **inventario domestico** offline: prodotti (quantità, scadenze), **luoghi** e **posizioni** (es. Cucina → Frigo), collegamento opzionale prodotto–posizione. I dati restano sul dispositivo (Hive).

## Requisiti

- **Flutter** con Dart compatibile con `environment.sdk` in `pubspec.yaml` (attualmente **^3.4.0**).

## Setup

```bash
git clone <url-del-repository>
cd housekeep
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

Dopo ogni modifica ai modelli `@HiveType` / `@HiveField`, rigenerare con `build_runner`.

## Esecuzione

```bash
flutter run
```

Supportate le piattaforme abilitate nel progetto (Android, iOS, Web, desktop secondo ambiente).

## Test e qualità

```bash
flutter analyze
flutter test test/
flutter test test/performance/
```

Opzionale: `flutter test integration_test/app_test.dart` (vedi [docs/developer/testing.md](docs/developer/testing.md)).

**Pre-release / E2E:** checklist e procedure in [docs/validation/](docs/validation/README.md).

## Build release

Comandi e firma: [docs/developer/build.md](docs/developer/build.md). Script in `scripts/`, CI in `.github/workflows/`.

## Struttura `lib/`

| Cartella | Ruolo |
|----------|--------|
| `domain/` | Entità, eccezioni, interfacce repository |
| `data/` | Hive, mapper, `Local*Repository` |
| `presentation/` | Schermate, widget, ViewModel |
| `core/` | Tema, navigazione, DI (`app_providers.dart`) |
| `utils/` | Validatori, formattazione |

## Documentazione

- **Architettura**: [docs/architecture/overview.md](docs/architecture/overview.md)
- **Sviluppatore**: [docs/developer/setup.md](docs/developer/setup.md)
- **ADR**: [docs/adr/README.md](docs/adr/README.md)
- **Utente**: [docs/user/overview.md](docs/user/overview.md)
- **Validazione pre-release**: [docs/validation/pre-release-checklist.md](docs/validation/pre-release-checklist.md)

## Licenza / pubblicazione

`publish_to: 'none'` in `pubspec.yaml` — progetto privato o non pubblicato su pub.dev.
