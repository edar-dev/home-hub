# 0003. State management con Provider

- Stato: Accettato
- Data: 2026-03-28

## Contesto

Serve uno stato condiviso tra schermate (inventario, luoghi, riepilogo) senza accoppiare eccessivamente i widget ai repository.

## Decisione

Usare il package **provider** con `ChangeNotifier` nei ViewModel, `Provider` / `ChangeNotifierProvider` nella root, e dove utile **`Selector`** per ridurre rebuild (es. lista prodotti).

## Conseguenze

- Pattern familiare alla documentazione Flutter; dipendenza ufficiale community.
- I ViewModel non sostituiscono il domain: restano sotto i repository astratti.

## Alternative scartate

- **Riverpod** — più potente ma migrazione e curva di apprendimento maggiori per questo codebase.
- **Bloc** — eventi/stati espliciti utili su scala grande; qui MVVM + Provider è sufficiente.
- **setState only** — non scala per più tab e repository condivisi.
