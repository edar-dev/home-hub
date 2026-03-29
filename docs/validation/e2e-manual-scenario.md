# Scenario manuale end-to-end (50 prodotti + persistenza)

Eseguire su **almeno una piattaforma primaria** (consigliato: Android o Chrome), poi ripetere su le altre se possibile.

## 1. Struttura luoghi (seed)

Creare la gerarchia:

| Luogo | Posizioni |
|-------|-----------|
| Cucina | Frigo, Dispensa, Congelatore |
| Bagno | Armadietto, Ripiano |
| Cantina | Scaffale |

**Checklist**

- [ ] Tab **Luoghi**: tutti i luoghi visibili con posizioni annidate.
- [ ] Rinomina di un luogo e di una posizione senza perdita dati.
- [ ] (Se previsto dalla UI) navigazione da luogo a inventario filtrato.

## 2. Cinquanta prodotti

Distribuzione suggerita:

- ~20 prodotti in **Cucina** (mix Frigo / Dispensa / Congelatore).
- ~15 in **Bagno**.
- ~10 in **Cantina** o **senza posizione**.
- ~5 con **solo data di scadenza** (vedi [edge-cases.md](edge-cases.md)).
- Almeno **due prodotti con lo stesso nome** in luoghi diversi (verifica ordinamento per nome).

**Checklist**

- [ ] Conteggio inventario = 50.
- [ ] Filtro per luogo (Inventario) coerente con le posizioni scelte.
- [ ] Tab **Riepilogo**: ogni prodotto con posizione compare sotto la posizione corretta.

Riferimenti codice: `ProductViewModel.loadProducts`, `LocationInventoryViewModel.load`.

## 3. Associazione posizione

Per un campione di prodotti (almeno 5):

- [ ] Modulo prodotto: posizione selezionata = posizione attesa in Riepilogo.

## 4. Persistenza (cold start)

1. Annotare conteggio prodotti e un nome prodotto “di riferimento”.
2. **Chiudere** l’app: su mobile *force stop*; su web chiudere il tab o ricaricare (non “Clear site data” salvo test dedicato).
3. Riaprire l’app.

**Checklist**

- [ ] Conteggio prodotti invariato.
- [ ] Filtro luogo e Riepilogo ancora coerenti.
- [ ] Dettaglio prodotto di riferimento invariato.

### Web

- [ ] Distinguere test **refresh normale** vs **svuota dati sito** (IndexedDB può essere cancellata).

## 5. Quantità limite

- [ ] Verificare che i validatori accettino i casi usati (es. quantità minime). Se `quantitaTotale` deve essere ≥ 1, non usare 0 in creazione.
