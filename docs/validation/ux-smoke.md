# UX smoke — navigazione, errori, onboarding

## First-time / onboarding

Oggi **non** è implementato un flusso onboarding (`SharedPreferences` / tutorial) in `main` → `HousekeepApp`. Il materiale utente di riferimento è [docs/user/overview.md](../user/overview.md).

**Checklist**

- [ ] All’avvio, le tre voci di navigazione sono comprensibili senza guida (Inventario, Luoghi, Riepilogo).
- [ ] (Opzionale futuro) Allineamento tutorial in-app con `docs/user/overview.md`.

## Navigazione

- [ ] Inventario → dettaglio prodotto → modifica → indietro: stato tab **Inventario** preservato (`IndexedStack` in shell).
- [ ] Luoghi: creazione luogo → aggiunta posizione → nessun vicolo cieco senza pulsante indietro.
- [ ] Riepilogo: sezioni per luogo leggibili con più posizioni.

## Messaggi di errore

- [ ] Validazione form: messaggi in italiano e collegati ai campi (rosso / testo errore).
- [ ] Errori da repository (`ProductException`, `LocationException`): snackbar o testo comprensibile, non stack trace in UI.
- [ ] Operazioni lunghe: feedback di caricamento dove presente (`isLoading`).

## Accessibilità (minimo)

- [ ] Contrasto leggibile in tema chiaro (e scuro se attivo).
- [ ] Aree tocabili sufficienti per target touch (circa 48 logical pixels per controlli principali).
