# Edge case — comportamento atteso

Usare questa tabella come **fonte di verità** durante i test manuali. Comportamento implementato nei repository locali Hive.

| Scenario | Comportamento atteso | Come verificare |
|----------|----------------------|-----------------|
| **Elimina luogo con prodotti assegnati** | I **prodotti non** vengono cancellati. Perdono `positionId` (link alle posizioni rimosse). Posizioni del luogo eliminate. | Dopo delete: prodotti ancora in Inventario, senza posizione; conteggio invariato. Codice: `LocalLocationRepository.deleteLocation`. |
| **Elimina posizione con prodotti** | Prodotti **non** cancellati; `positionId` azzerato per chi puntava a quella posizione. | `LocalLocationRepository.deletePosition` + `clearPositionIdsForPositions`. |
| **Elimina prodotto** | Solo il record prodotto viene rimosso. Le **posizioni** non cambiano (non “contano” prodotti). | Lista Luoghi invariata. |
| **Dataset grande (1000+)** | Lista scrollabile; `loadProducts` carica tutto in memoria (limite noto post-MVP). | DevTools Performance/Memory oppure `flutter test test/performance/`. |
| **Date estreme** | `Product.isExpired` confronta solo **date locali** (anno/mese/giorno). Scadenza molto nel futuro o nel passato: coerenza badge/UI. | Form prodotto: rispettare `validateDateOrder` (scadenza ≥ acquisto se entrambe presenti). |
| **Stesso nome, posizioni diverse** | Ordinamento per nome in lista; due righe distinte. | Inventario ordinato alfabeticamente. |

## ADR correlato

Collegamento prodotto–solo `positionId`: [docs/adr/0004-product-position-fk.md](../adr/0004-product-position-fk.md).

## Checklist rapida

- [ ] Delete luogo + prodotti orfani senza posizione.
- [ ] Delete posizione + prodotti senza posizione.
- [ ] Delete prodotto + posizioni intatte.
- [ ] 1000+ prodotti: scroll smoke OK o documentato come limite noto.
- [ ] Data scadenza prima della data acquisto: form deve rifiutare.
- [ ] Solo scadenza, acquisto null: OK se consentito dai validatori.
