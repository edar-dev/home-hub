# Checklist pre-release (Housekeep)

Segnare ogni voce prima di taggare una release o pubblicare su store.

## 1. Validazione manuale

- [ ] [Scenario 50 prodotti + luoghi](e2e-manual-scenario.md) eseguito su almeno una piattaforma primaria.
- [ ] [Cross-platform](cross-platform-validation.md): smoke su Android, iOS e Web (dove disponibile).
- [ ] [Edge case](edge-cases.md): delete luogo/posizione/prodotto verificati.
- [ ] [UX smoke](ux-smoke.md): navigazione e messaggi.

## 2. Automazione (CI locale)

```bash
flutter analyze
flutter test test/
flutter test integration_test/app_test.dart
flutter test test/performance/product_list_scroll_benchmark.dart test/performance/product_view_model_load_benchmark.dart test/performance/product_list_scale_benchmark.dart
```

- [ ] `flutter analyze` senza errori.
- [ ] `flutter test test/` verde.
- [ ] `integration_test/app_test.dart` verde (persistenza Hive).
- [ ] Benchmark `test/performance/*_benchmark.dart` verdi (scroll lista, `loadProducts` massivo, scale multi-riga).

Script opzionale (solo VM Dart, box `products` in directory temporanea o passata):

`dart run tool/seed_performance_dataset.dart 1500`

## 3. Crash e flussi principali

- [ ] CRUD prodotto senza crash.
- [ ] CRUD luogo/posizione senza crash.
- [ ] Nessun assert in debug nei flussi felici.

## 4. Versione e documentazione

- [ ] `version` in `pubspec.yaml` coerente con tag Git / note di release.
- [ ] [docs/developer/build.md](../developer/build.md) aggiornato se cambiano comandi o firma.

## 5. Performance (smoke)

- [ ] Lista con **molti prodotti** (vedi tool seed o test performance): accettabile **oppure** limite documentato in issue/README post-MVP.

## 6. Web specifico

- [ ] Build `flutter build web --release` eseguita almeno una volta prima del deploy.
- [ ] Se si usa `base-href`, allineare hosting (Firebase / static server).

## 7. Opzionale — integrazione continua

Se il repo usa GitHub Actions: workflow CI verde sull’ultimo commit della release.

---

**Firma / data** (opzionale): _________________ / ___________
