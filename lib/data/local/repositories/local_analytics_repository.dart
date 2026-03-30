import '../../../domain/entities/consumption_entry.dart';
import '../../../domain/entities/analytics_metrics.dart';
import '../../../domain/entities/chart_data_point.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/repositories/consumption_repository.dart';
import '../../../domain/repositories/analytics_repository.dart';
import '../../../domain/repositories/location_repository.dart';
import '../../../domain/repositories/product_repository.dart';
import '../../../domain/services/consumption_calculator.dart';

/// Implementazione analytics da [ProductRepository] + [LocationRepository].
class LocalAnalyticsRepository implements AnalyticsRepository {
  LocalAnalyticsRepository(
    this._products,
    this._locations, [
    ConsumptionRepository? consumptions,
  ]) : _consumptions = consumptions ?? _NoOpConsumptionRepository();

  final ProductRepository _products;
  final LocationRepository _locations;
  final ConsumptionRepository _consumptions;

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
    var avgDailySum = 0.0;
    var almostEmptyCount = 0;

    for (final p in list) {
      sumConsumed += (p.quantitaTotale - p.quantitaRimasta).clamp(0, 1 << 30);
      final entries = await _consumptions.getByProductId(p.id);
      final stats = ConsumptionCalculator.compute(p, entries);
      avgDailySum += stats.avgDailyConsumption;
      if (stats.isAlmostEmpty) {
        almostEmptyCount++;
      }

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
      avgDailyConsumption: list.isEmpty ? 0 : (avgDailySum / list.length),
      almostEmptyProducts: almostEmptyCount,
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
    final events = await _allEventsInLastMonths(months);
    final now = DateTime.now();
    final out = <ChartDataPoint>[];
    for (var i = months - 1; i >= 0; i--) {
      final d = DateTime(now.year, now.month - i, 1);
      final monthStart = DateTime(d.year, d.month, 1);
      final monthEnd = DateTime(d.year, d.month + 1, 0, 23, 59, 59);
      var value = 0.0;
      for (final e in events) {
        if (_isBetween(e.date, monthStart, monthEnd)) {
          value += e.amount;
        }
      }
      out.add(
        ChartDataPoint(
          label: '${d.month.toString().padLeft(2, '0')}/${d.year}',
          value: value,
        ),
      );
    }
    return out;
  }

  @override
  Future<List<ChartDataPoint>> getTopConsumedProducts({
    int days = 30,
    int limit = 10,
  }) async {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: days));
    final events = await _consumptions.getByDateRange(start, now);
    final names = <String, String>{};
    for (final p in await _products.getAll()) {
      names[p.id] = p.nome;
    }
    final totals = <String, double>{};
    for (final e in events) {
      totals[e.productId] = (totals[e.productId] ?? 0) + e.amount;
    }
    final out = totals.entries
        .map(
          (e) => ChartDataPoint(
            label: names[e.key] ?? 'Prodotto',
            value: e.value,
            groupKey: e.key,
          ),
        )
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return out.take(limit).toList();
  }

  @override
  Future<List<ChartDataPoint>> getRecentConsumptionSummary({int days = 7}) async {
    return getTopConsumedProducts(days: days, limit: 5);
  }

  @override
  Future<List<ChartDataPoint>> getMonthlyConsumptionByCategory({
    required DateTime month,
  }) async {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
    final events = await _consumptions.getByDateRange(start, end);
    final products = await _products.getAll();
    final pMap = <String, Product>{for (final p in products) p.id: p};
    final totals = <String, double>{};
    for (final e in events) {
      final p = pMap[e.productId];
      final key = p?.categoryId ?? 'Senza categoria';
      totals[key] = (totals[key] ?? 0) + e.amount;
    }
    final out = totals.entries
        .map((e) => ChartDataPoint(label: e.key, value: e.value, groupKey: e.key))
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return out;
  }

  Future<List<ConsumptionEntry>> _allEventsInLastMonths(int months) async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month - months + 1, 1);
    final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    return _consumptions.getByDateRange(start, end);
  }

  bool _isBetween(DateTime d, DateTime start, DateTime end) {
    return !d.isBefore(start) && !d.isAfter(end);
  }
}

class _NoOpConsumptionRepository implements ConsumptionRepository {
  @override
  Future<void> deleteByProductId(String productId) async {}

  @override
  Future<List<ConsumptionEntry>> getByDateRange(DateTime start, DateTime end) async {
    return const [];
  }

  @override
  Future<List<ConsumptionEntry>> getByProductId(String productId) async {
    return const [];
  }

  @override
  Future<void> saveEntry(ConsumptionEntry entry) async {}
}
