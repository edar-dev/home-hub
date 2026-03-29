# 0005. Trend consumo analytics senza storico

- Stato: Accettato
- Data: 2026-03-29

## Contesto

Il grafico “trend consumo” richiederebbe eventi di consumo nel tempo. L’inventario attuale espone solo quantità attuali.

## Decisione

`LocalAnalyticsRepository.getConsumptionTrendMonths` restituisce **tre punti mensili** con lo stesso valore: consumo implicito totale `sum(max(0, quantitaTotale - quantitaRimasta))` diviso per il numero di mesi. La UI indica che è una **stima** senza storico.

## Conseguenze

- Line chart può apparire piatta; accettabile per MVP.
- Evoluzione futura: box `ConsumptionEvent` o export periodico.

## Alternative scartate

- Snapshot giornaliero automatico (complessità scheduling).
- Nascondere il grafico (meno valore per l’utente).
