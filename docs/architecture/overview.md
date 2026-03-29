# Housekeep — panoramica architetturale

## Scopo

**Housekeep** è un’app Flutter per **inventario domestico**: prodotti con quantità e scadenze, **luoghi** (stanze) e **posizioni** (es. frigo, dispensa), collegamento opzionale prodotto → posizione. I dati sono **persistiti in locale** (nessun account obbligatorio).

## Stack

| Area | Tecnologia |
|------|------------|
| UI | Flutter (Material 3) |
| Stato | [provider](https://pub.dev/packages/provider) (`ChangeNotifier`, `Selector`) |
| Persistenza | [Hive](https://pub.dev/packages/hive) + modelli `@HiveType` |
| ID | UUID (`uuid`) |
| Test | `flutter_test`, [mocktail](https://pub.dev/packages/mocktail) |

## Vincoli di design

- **Offline-first**: tutto il CRUD passa dai repository locali.
- **Clean-ish layering**: `domain` (entità + interfacce) → `data` (Hive, mapper, implementazioni) → `presentation` (schermate, ViewModel).
- **Compatibilità dati**: nuovi campi Hive solo **in coda** (`@HiveField` progressivo) per non rompere box esistenti.

## Riferimenti nel codice

- Composizione app: [`lib/app.dart`](../../lib/app.dart)
- DI e bootstrap: [`lib/core/di/app_providers.dart`](../../lib/core/di/app_providers.dart)
- Hive: [`lib/data/local/hive_service.dart`](../../lib/data/local/hive_service.dart)

## Documenti correlati

- [layers.md](layers.md) — MVVM, repository, diagrammi
- [data-flow.md](data-flow.md) — flussi operativi principali
