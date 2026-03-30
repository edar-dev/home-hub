---
name: consumption-first rollout
overview: "Implementerò Priority 1 + Priority 2 con architettura event-based: registro consumi rapido, calcoli automatici, alert intelligenti e dashboard/report consumi, usando un box Hive separato per gli eventi di consumo."
todos:
  - id: data-layer-consumption-events
    content: Creare ConsumptionEntry entity/model/repository con box Hive separato e wiring DI
    status: completed
  - id: consumption-calculator-rules
    content: Implementare calcoli avg daily/weekly, days remaining e regole is_almost_empty
    status: completed
  - id: quick-consume-ui
    content: Aggiungere schermata/flow Registro Consumo Rapido con CTA da lista/dettaglio/FAB
    status: completed
  - id: alerts-integration
    content: Integrare alert intelligenti nel sistema notifiche/digest
    status: completed
  - id: dashboard-reports
    content: Aggiornare Analytics/Home con sezioni consumi e report mensili aggregati
    status: completed
  - id: scanner-support-flow
    content: Riadattare scanner+lookup come shortcut alla registrazione consumo
    status: completed
  - id: tests-and-goldens
    content: Coprire con unit/repo/widget test e aggiornare golden necessari
    status: completed
isProject: false
---

# Piano Implementazione Consumption-First

## Obiettivo

Portare l'app da inventario statico a gestione consumi dinamica, con registrazione rapida (2–3 tap), metriche/forecast affidabili e dashboard/report orientati ai consumi.

## Scelte confermate

- Scope: **Priority 1 + Priority 2** nello stesso intervento.
- Data model: **eventi consumo in box separato** (non annidati in `Product`).

## Architettura proposta

- **Product** resta fonte di verità per stock corrente (`quantitaTotale`, `quantitaRimasta`).
- Nuovo dominio **ConsumptionEntry** persiste ogni evento (`productId`, `date`, `amount`, `unit`, `meal`, `recipe`, `notes`, `source`).
- Servizio/calcolatore consumi aggrega eventi per:
  - `avg_daily_consumption`, `avg_weekly_consumption`
  - `days_remaining_estimate`
  - `is_almost_empty` (regola giorni o porzioni)
- Analytics e notifiche leggono gli aggregati consumo + stato prodotto.

## File principali da toccare

- Modelli/persistenza
  - [d:/source/housekeep/lib/domain/entities/product.dart](d:/source/housekeep/lib/domain/entities/product.dart)
  - [d:/source/housekeep/lib/domain/entities](d:/source/housekeep/lib/domain/entities)
  - [d:/source/housekeep/lib/data/local/models](d:/source/housekeep/lib/data/local/models)
  - [d:/source/housekeep/lib/data/local/hive_service.dart](d:/source/housekeep/lib/data/local/hive_service.dart)
  - [d:/source/housekeep/lib/core/di/app_providers.dart](d:/source/housekeep/lib/core/di/app_providers.dart)
- Logica consumi e alert
  - [d:/source/housekeep/lib/presentation/viewmodels/product_view_model.dart](d:/source/housekeep/lib/presentation/viewmodels/product_view_model.dart)
  - [d:/source/housekeep/lib/data/local/repositories/local_notification_repository.dart](d:/source/housekeep/lib/data/local/repositories/local_notification_repository.dart)
  - [d:/source/housekeep/lib/data/local/repositories/local_analytics_repository.dart](d:/source/housekeep/lib/data/local/repositories/local_analytics_repository.dart)
- UX rapida + dashboard
  - [d:/source/housekeep/lib/presentation/views/screens/product_list_screen.dart](d:/source/housekeep/lib/presentation/views/screens/product_list_screen.dart)
  - [d:/source/housekeep/lib/presentation/views/widgets/product_card.dart](d:/source/housekeep/lib/presentation/views/widgets/product_card.dart)
  - [d:/source/housekeep/lib/presentation/views/widgets/product_detail_body.dart](d:/source/housekeep/lib/presentation/views/widgets/product_detail_body.dart)
  - [d:/source/housekeep/lib/presentation/views/screens/analytics/analytics_dashboard_screen.dart](d:/source/housekeep/lib/presentation/views/screens/analytics/analytics_dashboard_screen.dart)
  - [d:/source/housekeep/lib/presentation/views/screens/analytics/widgets](d:/source/housekeep/lib/presentation/views/screens/analytics/widgets)

## Fasi di implementazione

1. **Fondazioni dati consumo**
  - Introdurre entity/model/repository per `ConsumptionEntry` in box Hive dedicato.
  - Aggiornare DI e bootstrap Hive (adapter + box open).
  - Estendere `Product` con campi supporto (`typicalPortion`, eventuali helper non persistiti).
2. **Calcoli e regole business**
  - Implementare calcolatore aggregati consumo per prodotto (giornaliero/settimanale/stima giorni).
  - Regole `is_almost_empty`, fallback quando media è zero.
  - Agganciare ricalcolo a ogni registrazione consumo.
3. **Registro consumo rapido (2–3 tap)**
  - Nuova UI minimale “Registra consumo” con quick-pick quantità + unità precompilata.
  - Entrate rapide da lista prodotto, dettaglio prodotto e CTA globale.
  - Salvataggio evento + update quantità rimanente + feedback toast/snackbar.
4. **Alert intelligenti (Priority 1)**
  - Quasi esaurito, spreco potenziale, consumo anomalo, prodotto non usato.
  - Integrare nel flusso notifiche esistente e nel digest.
5. **Dashboard consumi + report mensili (Priority 2)**
  - Sezioni: quasi finiti, top consumi 7/30gg, sintesi consumi recenti, alert spreco.
  - Aggregazioni mensili categoria/prodotto, confronto mese/mese, costo stimato (se prezzo presente).
  - Riuso widget chart esistenti con datasource consumi reali.
6. **Scanner come supporto consumo**
  - Se barcode matcha prodotto esistente: shortcut verso registro consumo.
  - Se nuovo prodotto: prefill + passaggio immediato al consumo.
7. **Test e validazione**
  - Unit: calcoli consumi/forecast/alert.
  - Repo: persistenza eventi e aggregazioni.
  - Widget: quick consume flow in 2–3 tap.
  - Aggiornamento goldens dove cambia UI.

## Criteri di accettazione

- Registrazione consumo completabile in max 3 tap nei casi comuni.
- Quantità rimanente e metriche consumo aggiornate automaticamente.
- Dashboard mostra quasi finiti, top consumi, alert spreco.
- Alert automatici attivi per scenari definiti.
- Report mensili disponibili con trend e confronto mese/mese.

