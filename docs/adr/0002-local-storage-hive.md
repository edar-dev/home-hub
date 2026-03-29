# 0002. Persistenza locale con Hive

- Stato: Accettato
- Data: 2026-03-28

## Contesto

Serve storage **offline**, tipizzato, adatto a modelli Dart senza server. L’app deve funzionare su mobile e web.

## Decisione

Usare **Hive** con modelli `@HiveType` / `@HiveField`, box separati per prodotti, luoghi e posizioni. Migrazioni: preferire **nuovi field solo in coda** per compatibilità con dati esistenti.

## Conseguenze

- `build_runner` obbligatorio dopo cambi agli adapter.
- Nessuna query SQL: filtri complessi su grandi volumi possono richiedere indici o paginazione in futuro.

## Alternative scartate

- **sqflite** — SQL potente ma più boilerplate e diverso modello su web.
- **Isar** — valido ma scelta iniziale Hive già integrata e sufficiente per il volume domestico.
- **Solo JSON su file** — semplice ma senza tipizzazione e indici come Hive.
