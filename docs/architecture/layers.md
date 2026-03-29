# Layer e dipendenze (MVVM + repository)

## Regole

1. **Presentation** (`lib/presentation/`) può dipendere da **domain** e Flutter; **non** importa Hive, `Box`, o modelli `*HiveModel`.
2. **Domain** (`lib/domain/`) è puro Dart: entità, eccezioni, **interfacce** repository. Nessuna dipendenza da Flutter o Hive.
3. **Data** (`lib/data/`) implementa le interfacce domain, usa Hive, mapper e DTO.
4. **ViewModel** espone stato alla UI e chiama solo **repository astratti** (tipi domain).

## Diagramma layer

```mermaid
flowchart TB
  subgraph presentation [Presentation]
    Screens[Screens e Widgets]
    VM[ViewModels ChangeNotifier]
  end
  subgraph domain [Domain]
    Entities[Entities]
    RepoIf[Repository interfaces]
  end
  subgraph data [Data]
    LocalRepo[Local repositories]
    HiveModels[Hive models e mapper]
  end
  Screens --> VM
  VM --> RepoIf
  LocalRepo --> RepoIf
  LocalRepo --> HiveModels
```

## State management (Provider)

La root registra `Provider` per i repository e `ChangeNotifierProvider` per i ViewModel. Le schermate usano `context.read`, `context.watch` o `Selector` per limitare i rebuild.

```mermaid
sequenceDiagram
  participant UI as Schermata
  participant VM as ProductViewModel
  participant R as ProductRepository
  UI->>VM: read watch Selector
  VM->>R: getAll o save
  R-->>VM: dati o eccezione
  VM-->>UI: notifyListeners
```

## Hive e typeId

| typeId | Modello | Box |
|--------|---------|-----|
| 0 | `ProductHiveModel` | `products` |
| 1 | `LocationHiveModel` | `locations` |
| 2 | `PositionHiveModel` | `positions` |

Registrazione adapter in [`HiveService.init`](../../lib/data/local/hive_service.dart).

## File di riferimento

| Layer | Esempi |
|-------|--------|
| Domain | `lib/domain/entities/`, `lib/domain/repositories/` |
| Data | `lib/data/local/repositories/`, `lib/data/local/mappers/` |
| Presentation | `lib/presentation/views/`, `lib/presentation/viewmodels/` |
