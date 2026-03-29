import '../../../domain/entities/analytics_metrics.dart';
import '../../../domain/entities/chart_data_point.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/repositories/analytics_repository.dart';
import '../../../domain/repositories/location_repository.dart';
import '../../../domain/repositories/product_repository.dart';

/// Implementazione analytics da [ProductRepository] + [LocationRepository].
class LocalAnalyticsRepository implements AnalyticsRepository {
  LocalAnalyticsRepository(this._products, this._locations);

  final ProductRepository _products;
  final LocationRepository _locations;

  Future<List<Product>> _allProducts({String? locationId}) async {
    if (locationId != null) {
      return _products.getByLocationId(locationId);
    }
    return _products.getAll();
  }

  DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  Future<AnalyticsMetrics> getMetrics({
    required DateTime startDate,
    required DateTime endDate,
    String? locationId,
  }) async {
    final list = await _allProducts(locationId: locationId);
    final today = _dayOnly(DateTime.now());
    final start = _dayOnly(startDate);
    final end = _dayOnly(endDate);

    var expiring7 = 0;
    var expired30 = 0;
    var sumConsumed = 0;

    for (final p in list) {
      sumConsumed += (p.quantitaTotale - p.quantitaRimasta).clamp(0, 1 << 30);

      final due = p.daysUntilExpiry;
      if (due != null && due >= 0 && due <= 7) {
        expiring7++;
      }

      final scad = p.dataScadenza;
      if (scad != null) {
        final sd = _dayOnly(scad);
        if (sd.isBefore(today)) {
          final limit = today.subtract(const Duration(days: 30));
          if (!sd.isBefore(limit)) {
            expired30++;
          }
        }
      }
    }

    final months = _monthSpanInclusive(start, end);
    final monthlyAvg = months > 0 ? sumConsumed / months : 0.0;
    final total = list.length;
    final waste = total > 0 ? (expired30 / total) * 100.0 : 0.0;

    return AnalyticsMetrics(
      totalProducts: total,
      expiringIn7Days: expiring7,
      expiredInLast30Days: expired30,
      wastePercentage: waste,
      monthlyConsumptionAverage: monthlyAvg,
      startDate: start,
      endDate: end,
    );
  }

  int _monthSpanInclusive(DateTime a, DateTime b) {
    if (b.isBefore(a)) return 1;
    return (b.year - a.year) * 12 + b.month - a.month + 1;
  }

  @override
  Future<List<ChartDataPoint>> getProductDistributionByLocation() async {
    final products = await _products.getAll();
    final hierarchy = await _locations.getAllWithPositions();
    final locNames = <String, String>{
      for (final row in hierarchy) row.location.id: row.location.nome,
    };
    final posToLoc = <String, String>{};
    for (final row in hierarchy) {
      for (final pos in row.positions) {
        posToLoc[pos.id] = row.location.id;
      }
    }

    final counts = <String, int>{};
    for (final p in products) {
      final pid = p.positionId;
      String key;
      if (pid == null || !posToLoc.containsKey(pid)) {
        key = '__none__';
      } else {
        final lid = posToLoc[pid]!;
        key = locNames[lid] ?? 'Luogo';
      }
      counts[key] = (counts[key] ?? 0) + 1;
    }

    final points = <ChartDataPoint>[];
    counts.forEach((k, v) {
      points.add(
        ChartDataPoint(
          label: k == '__none__' ? 'Senza luogo' : k,
          value: v.toDouble(),
          groupKey: k,
        ),
      );
    });
    points.sort((a, b) => b.value.compareTo(a.value));
    return points;
  }

  @override
  Future<List<ChartDataPoint>> getTopByQuantity({int limit = 5}) async {
    final products = await _products.getAll();
    final sorted = List<Product>.from(products)
      ..sort((a, b) => b.quantitaRimasta.compareTo(a.quantitaRimasta));
    return sorted
        .take(limit)
        .map(
          (p) => ChartDataPoint(
            label: p.nome,
            value: p.quantitaRimasta.toDouble(),
            groupKey: p.id,
          ),
        )
        .toList();
  }

  @override
  Future<List<ChartDataPoint>> getConsumptionTrendMonths({
    required int months,
    String? locationId,
  }) async {
    final list = await _allProducts(locationId: locationId);
    final sumConsumed = list.fold<int>(
      0,
      (s, p) => s + (p.quantitaTotale - p.quantitaRimasta).clamp(0, 1 << 30),
    );
    final perMonth = months > 0 ? sumConsumed / months : 0.0;
    final now = DateTime.now();
    final out = <ChartDataPoint>[];
    for (var i = months - 1; i >= 0; i--) {
      final d = DateTime(now.year, now.month - i, 1);
      out.add(
        ChartDataPoint(
          label: '${d.month.toString().padLeft(2, '0')}/${d.year}',
          value: perMonth,
        ),
      );
    }
    return out;
  }
}
