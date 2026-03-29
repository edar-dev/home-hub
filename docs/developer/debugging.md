# Debugging

## Flutter DevTools

- **Widget Inspector** — albero widget, overflow, `Selector` / `Provider`.
- **Performance** — frame durante scroll liste lunghe; vedere anche `test/performance/`.
- **Logging** — messaggi `debugPrint` dai repository in modalità debug (assert).

## Dati Hive

- In **debug**, alcuni repository loggano operazioni dietro `assert(() { debugPrint(...); return true; }());`.
- **Test/integration**: usa `AppFactory.create(hiveStoragePath: dir.path)` e alla fine [`HiveService.dispose()`](../../lib/data/local/hive_service.dart) o `Hive.close()`.
- Path su dispositivo reale: dipende dalla piattaforma; per ispezioni manuali si usano tool tipo Hive Studio su file estratti (Android/iOS richiedono accesso al filesystem dell’app).

## Errori comuni

- **`ProviderNotFoundException`** — ordine dei `Provider` in `MultiProvider` in `app.dart`: i repository devono stare **sopra** i ViewModel che li leggono con `context.read` nel `create`.
- **Adapter Hive non registrato** — eseguire `init()` prima di `openBox`; verificare `isAdapterRegistered` in `HiveService`.

## Web

- Hive usa IndexedDB. Testare con `flutter run -d chrome` e build release su hosting (vedi [build.md](build.md)).
