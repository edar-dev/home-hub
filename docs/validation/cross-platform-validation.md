# Validazione cross-platform

Hive **non** sincronizza tra Android, iOS e Web: su ogni piattaforma **ricreare** lo stesso scenario (o usare solo confronto funzionale con dati minimi).

## Matrice di verifica

Eseguire le stesse azioni su **Android**, **iOS** (simulatore o device) e **Chrome** (web).

| Area | Cosa verificare |
|------|------------------|
| Navigazione | Tre tab: Inventario, Luoghi, Riepilogo. Su schermo largo `NavigationRail`, su stretto `NavigationBar` ([`home_shell_screen.dart`](../../lib/presentation/views/screens/home_shell_screen.dart)). |
| CRUD | Creazione / modifica / eliminazione luogo, posizione, prodotto; messaggi coerenti. |
| Filtri | Filtro per luogo sull’inventario allineato alle posizioni del luogo. |
| Testi | Locale `it_IT` ([`app.dart`](../../lib/app.dart)): stesse stringhe UI dove applicabile. |

## UI consistency

- [ ] **Overflow**: nomi lunghi (luogo, posizione, prodotto) senza overflow critico.
- [ ] **Mobile**: tastiera non nasconde pulsanti essenziali nel form prodotto.
- [ ] **Web**: scroll, focus tra campi, nessun blur strano su `TextField`.

## Performance (qualitativa)

Ripetere uno scenario con **molti prodotti** (vedi `dart run tool/seed_performance_dataset.dart` + reinstallazione non necessaria: preferire [test performance](../../test/performance/) o seed manuale).

- [ ] Scroll lista inventario: accettabile (no jank prolungato).
- [ ] Apertura tab Inventario: tempo accettabile.
- [ ] Note comparative tra piattaforme (nessun obiettivo ms fisso in MVP).

## Comandi di esecuzione

```bash
flutter run -d <device_id>
flutter run -d chrome
```

Build release smoke (opzionale pre-rilascio):

```bash
flutter build apk --release
flutter build web --release
```

Dettagli firma e store: [docs/developer/build.md](../developer/build.md).
