# Architecture Decision Records (ADR)

Gli ADR documentano **decisioni strutturali** difficili da dedurre dal solo codice: contesto, scelta presa, conseguenze e alternative scartate.

## Indice

| # | Titolo |
|---|--------|
| 0001 | [Usare ADR in questo repo](0001-record-architecture-decisions.md) |
| 0002 | [Persistenza locale con Hive](0002-local-storage-hive.md) |
| 0003 | [State management con Provider](0003-state-management-provider.md) |
| 0004 | [Prodotto collegato solo tramite positionId](0004-product-position-fk.md) |
| 0005 | [Trend consumo analytics senza storico](0005-analytics-consumption-trend.md) |

## Come proporre un nuovo ADR

1. Copia la struttura da un ADR esistente.
2. Nome file: `NNNN-titolo-kebab-case.md` (NNNN progressivo).
3. Sezioni: **Contesto**, **Decisione**, **Conseguenze**, **Alternative scartate**.
4. Stato iniziale: `Proposto` o `Accettato`.

## Template minimo

```markdown
# NNNN. Titolo breve

- Stato: Proposto | Accettato | Deprecato
- Data: YYYY-MM-DD

## Contesto

## Decisione

## Conseguenze

## Alternative scartate
```
