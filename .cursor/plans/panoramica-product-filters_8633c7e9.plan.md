---
name: panoramica-product-filters
overview: Aggiungere nella Panoramica una sezione filtri (ricerca, stato, aperto/non aperto) con persistenza in sessione e integrazione nel rendering sezioni/espansioni esistenti.
todos: []
isProject: false
---

# Piano Filtri Panoramica

## Obiettivo

Introdurre nella pagina Panoramica una sezione filtri semplice e veloce per trovare prodotti, con filtri su testo, stato prodotto e stato apertura, mantenendo i filtri attivi durante la sessione app.

## Scope confermato

- Filtri richiesti: ricerca testuale, stato prodotto, aperto/non aperto.
- Persistenza: filtri mantenuti in memoria finché l’app resta aperta (`session_keep`).

## Strategia tecnica

### 1) Stato filtri nella ViewModel di Panoramica

- Estendere la ViewModel per contenere il filtro corrente e non perderlo ai reload.
- Definire un piccolo model/enum per:
  - query testo
  - stato prodotto (`all`, `expiring`, `expired`, `lowStock`)
  - stato apertura (`all`, `opened`, `unopened`)
- Applicare i filtri al momento della costruzione delle `sections`/`blocks` già esistenti.

File principali:

- [d:/source/housekeep/lib/presentation/viewmodels/location_inventory_view_model.dart](d:/source/housekeep/lib/presentation/viewmodels/location_inventory_view_model.dart)

### 2) UI filtri nella Panoramica

- Aggiungere una sezione filtri in alto nella Panoramica (prima delle card luoghi):
  - campo ricerca (debounced o submit-based per evitare notify troppo frequenti)
  - chip stato prodotto
  - chip aperto/non aperto
  - azione “Reset filtri” visibile solo se filtri attivi
- Integrare la UI nello stile corrente (surface/spacing/tipografia già in uso).

File principali:

- [d:/source/housekeep/lib/presentation/views/screens/location_inventory_screen.dart](d:/source/housekeep/lib/presentation/views/screens/location_inventory_screen.dart)

### 3) Comportamento e UX

- Mostrare un empty-state specifico quando non ci sono match con filtro attivo (diverso da “nessun luogo”).
- Mantenere espansioni/carte coerenti senza rompere CTA già introdotte (`Aggiungi prodotto`, `Aggiungi posizione`).

File principali:

- [d:/source/housekeep/lib/presentation/views/screens/location_inventory_screen.dart](d:/source/housekeep/lib/presentation/views/screens/location_inventory_screen.dart)

### 4) Test e validazione

- Aggiungere test ViewModel per logica filtri combinati.
- Aggiungere test widget Panoramica per:
  - ricerca testo
  - filtro stato prodotto
  - filtro aperto/non aperto
  - reset filtri
- Verificare assenza regressioni su test Panoramica già presenti.

File principali:

- [d:/source/housekeep/test/views/location_inventory_screen_test.dart](d:/source/housekeep/test/views/location_inventory_screen_test.dart)
- (eventuale nuovo test VM) [d:/source/housekeep/test/presentation/location_inventory_view_model_test.dart](d:/source/housekeep/test/presentation/location_inventory_view_model_test.dart)

## Criteri di accettazione

- Sezione filtri visibile e usabile in Panoramica.
- Filtri combinabili (testo + stato + apertura).
- Filtri persistono durante la sessione (navigazione tab/schermate) senza reset automatico.
- Empty-state corretto in caso di nessun risultato filtrato.
- Test nuovi/aggiornati verdi.

