# 0004. Prodotto collegato solo tramite positionId

- Stato: Accettato
- Data: 2026-03-28

## Contesto

I prodotti devono poter essere collocati in casa. Esistono **Location** (stanza) e **StoragePosition** (punto dentro la stanza).

## Decisione

Il prodotto ha un solo riferimento opzionale: **`positionId`** → `StoragePosition.id`. La **location** si **deriva** dalla posizione (`position.locationId`), non con un secondo FK sul prodotto, per evitare stati incoerenti (prodotto che punta a posizione di un’altra stanza).

## Conseguenze

- “Solo stanza senza mobiletto” richiede in futuro una posizione generica o altro meccanismo (fuori scope MVP).
- Cancellazione posizione/luogo: integrità tramite `clearPositionIdsForPositions` lato repository.

## Alternative scartate

- **locationId + positionId opzionali sul prodotto** — permette incoerenze se non validati insieme.
- **Lista prodotti embedded nella Position in Hive** — duplicazione e migrazioni più pesanti.
