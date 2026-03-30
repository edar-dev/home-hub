import '../entities/analytics_metrics.dart';
import '../entities/chart_data_point.dart';

/// Query read-only su inventario per dashboard analytics.
abstract class AnalyticsRepository {
  Future<AnalyticsMetrics> getMetrics({
    required DateTime startDate,
    required DateTime endDate,
    String? locationId,
  });

  /// Prodotti per luogo (via posizione); include bucket "Senza luogo".
  Future<List<ChartDataPoint>> getProductDistributionByLocation();

  /// Top prodotti per quantità rimasta.
  Future<List<ChartDataPoint>> getTopByQuantity({int limit = 5});

  /// Trend mensile: senza storico reale, valori ripartiti uniformemente
  /// sulla somma `(totale - rimasta)` (vedi documentazione [AnalyticsMetrics]).
  Future<List<ChartDataPoint>> getConsumptionTrendMonths({
    required int months,
    String? locationId,
  });

  /// Top prodotti per quantità consumata in una finestra di [days].
  Future<List<ChartDataPoint>> getTopConsumedProducts({
    int days = 30,
    int limit = 10,
  });

  /// Sintesi consumi recenti (label prodotto -> quantità consumata).
  Future<List<ChartDataPoint>> getRecentConsumptionSummary({int days = 7});

  /// Totale consumato nel mese corrente e precedente per categoria.
  Future<List<ChartDataPoint>> getMonthlyConsumptionByCategory({
    required DateTime month,
  });
}
