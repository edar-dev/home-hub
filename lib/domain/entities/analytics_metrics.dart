/// KPI aggregati calcolati da inventario locale.
///
/// **Consumo medio mensile**: euristica `somma(max(0, quantitaTotale - quantitaRimasta)) / mesi`
/// nel periodo `[startDate, endDate]` (almeno 1 mese). Non richiede log storico.
///
/// **Percentuale sprechi**: rapporto tra prodotti con scadenza caduta negli ultimi 30 giorni
/// (rispetto a `referenceDate`) e il totale prodotti considerati.
class AnalyticsMetrics {
  const AnalyticsMetrics({
    required this.totalProducts,
    required this.expiringIn7Days,
    required this.expiredInLast30Days,
    required this.wastePercentage,
    required this.monthlyConsumptionAverage,
    required this.startDate,
    required this.endDate,
  });

  final int totalProducts;

  /// Scadenza tra oggi e i prossimi 7 giorni (inclusi).
  final int expiringIn7Days;

  /// Scaduti nel periodo mobile di 30 giorni prima di `referenceDate` (tipicamente oggi).
  final int expiredInLast30Days;

  /// `expiredInLast30Days / max(totalProducts, 1) * 100`.
  final double wastePercentage;

  /// Unità consumate implicitamente per mese (vedi euristica sopra).
  final double monthlyConsumptionAverage;

  final DateTime startDate;
  final DateTime endDate;
}
