# Testing

## Comandi

```bash
flutter analyze
flutter test test/
```

Integration (con device/emulator o VM secondo configurazione):

```bash
flutter test integration_test/app_test.dart
```

## Struttura

| Cartella | Contenuto |
|----------|-----------|
| `test/domain/` | Entità, validatori, eccezioni |
| `test/data/` | Repository Hive su directory temporanea, mapper |
| `test/presentation/` | ViewModel con mock repository |
| `test/views/` | Widget test, `MaterialApp` + `MultiProvider` |
| `test/performance/` | Liste grandi, soglie temporali indicative |
| `integration_test/` | Flussi end-to-end con Hive reale |

## Mock

- [mocktail](https://pub.dev/packages/mocktail): `registerFallbackValue` per tipi custom (`Product`, `Location`, ecc.).

## Golden

- `test/views/goldens/` — aggiornare con `flutter test --update-goldens` solo quando il cambiamento UI è voluto.

## Linee guida

- Evitare `pumpAndSettle` infinito con `CircularProgressIndicator` senza fine; usare `pump(Duration)`.
- Dopo modifiche a Hive model, rigenerare codice e aggiornare test di migrazione/legacy se applicabile.
