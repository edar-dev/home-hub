# Test, coverage e debug (FASE 1)

## Coverage

```bash
flutter test --coverage
dart run tool/coverage_gate.dart
```

Il gate esclude `lib/**/*.g.dart` e `lib/main.dart` dal calcolo. Per report HTML (richiede `lcov` installato):

```bash
lcov --remove coverage/lcov.info '**/*.g.dart' 'lib/main.dart' -o coverage/lcov_filtered.info
genhtml coverage/lcov_filtered.info -o coverage/html
```

## Integration test

Con più target (Windows/Chrome/Edge) Flutter può richiedere un device esplicito. Per eseguire sul motore di test headless:

```bash
flutter test integration_test/app_test.dart -d flutter-tester
```

Hive usa una directory temporanea tramite `AppFactory.create(hiveStoragePath: ...)`.

Il test usa `TestWidgetsFlutterBinding` (stesso stack dei widget test). Per esecuzione su desktop Windows: `flutter test integration_test/... -d windows` richiede **Developer Mode** (symlink per i plugin). In alternativa: emulatore Android o CI Linux/macOS.

## Performance / memoria (lista lunga)

Non esiste API Dart portabile per l’uso memoria nei test. Per verifiche manuali:

1. `flutter run --profile`
2. Aprire **Dart DevTools → Memory** durante salvataggi ripetuti o scroll su lista grande
3. **Performance** per jank su liste lunghe

Il test `test/performance/product_list_scroll_test.dart` misura solo tempi di `pump` / scroll in ambiente test (soglia ampia per variabilità CI/VM).

## Hive su disco

- In produzione il path dipende da `Hive.initFlutter()` / piattaforma.
- Per ispezionare file: strumenti desktop tipo **Hive Studio** (file `.hive` su disco).
- In debug, `LocalProductRepository.save` può loggare su `kDebugMode` (vedi `assert` nel repository).

## Logging e errori

- Messaggi utente: centralizzati nel ViewModel.
- `main.dart`: `FlutterError.onError` e `PlatformDispatcher.instance.onError` in debug per stack in console.
- Per log strutturati: `dart:developer` `log()` o pacchetti tipo `logger` (opzionale).

## Flutter DevTools

- **Widget Inspector**: albero widget e layout
- **Logging**: `debugPrint` / `log()`
- **Memory / Performance**: come sopra

## Golden

Aggiornare immagini di riferimento solo su una piattaforma coerente con CI:

```bash
flutter test test/views/goldens/product_card_golden_test.dart --update-goldens
```
