# Task comuni

## Aggiungere una feature UI

1. Valuta se serve solo UI o anche dati nuovi.
2. **Schermata/widget**: `lib/presentation/views/` (sottocartelle `screens/` o `widgets/`).
3. **Stato**: estendi un `ChangeNotifier` esistente o aggiungi un ViewModel in `lib/presentation/viewmodels/`.
4. **Registra il provider** in [`lib/app.dart`](../../lib/app.dart) se serve un nuovo ViewModel o repository.

Mantieni le dipendenze verso **repository astratti** (`lib/domain/repositories/`), non verso `Local*Repository`.

## Aggiungere un campo a un’entità persistita

Ordine consigliato:

1. **Domain** — aggiorna l’entità in `lib/domain/entities/` (`copyWith`, costruttore).
2. **Hive** — aggiungi **solo** `@HiveField(n)` in **coda** al modello in `lib/data/local/models/`.
3. Esegui `dart run build_runner build --delete-conflicting-outputs`.
4. **Mapper** — `lib/data/local/mappers/` (`toDomain` / `toHive`).
5. **Repository** — lettura/scrittura se il campo richiede logica (validazione, default).
6. **Test** — mapper round-trip; opzionale test “legacy” senza il nuovo field (come in `local_product_repository_test.dart`).

Non cambiare ordine o significato dei field Hive esistenti: rompe la lettura dei dati sul dispositivo.

## Aggiungere un nuovo tipo persistito (nuovo box)

1. Nuovo `*HiveModel` con `@HiveType` e **typeId** non usato (vedi [`layers.md`](../architecture/layers.md)).
2. Registra l’adapter in [`HiveService.init`](../../lib/data/local/hive_service.dart).
3. Aggiungi `openXxxBox()` e costante nome box.
4. Estendi `AppFactory.create` per aprire il box e passarlo al repository.
5. Test in `test/data/` con `Directory.systemTemp` + `Hive.init`.

## Aggiungere una route / schermata

- Pattern attuale: `MaterialPageRoute` da pulsanti/FAB (vedi `ProductListScreen`, `LocationListScreen`).
- Shell principale: [`home_shell_screen.dart`](../../lib/presentation/views/screens/home_shell_screen.dart) con tab `IndexedStack`.
