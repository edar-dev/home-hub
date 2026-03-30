import '../entities/consumption_entry.dart';
import '../entities/consumption_stats.dart';
import '../entities/product.dart';

abstract final class ConsumptionCalculator {
  static ConsumptionStats compute(
    Product product,
    List<ConsumptionEntry> entries,
  ) {
    if (entries.isEmpty) {
      return ConsumptionStats(
        totalConsumed: 0,
        avgDailyConsumption: 0,
        avgWeeklyConsumption: 0,
        daysRemainingEstimate: null,
        lastConsumptionDate: null,
        isAlmostEmpty: _fallbackAlmostEmpty(product, null),
      );
    }
    final sorted = List<ConsumptionEntry>.from(entries)
      ..sort((a, b) => a.date.compareTo(b.date));
    final firstDay = _day(sorted.first.date);
    final lastDay = _day(sorted.last.date);
    final daysSpan = (lastDay.difference(firstDay).inDays + 1).clamp(1, 100000);

    var total = 0.0;
    for (final e in sorted) {
      total += e.amount;
    }

    final avgDaily = total / daysSpan;
    final avgWeekly = avgDaily * 7;
    final remaining = product.quantitaRimasta.toDouble();
    final daysRemaining = avgDaily > 0 ? (remaining / avgDaily) : null;

    final almostEmpty = _fallbackAlmostEmpty(product, daysRemaining);
    return ConsumptionStats(
      totalConsumed: total,
      avgDailyConsumption: avgDaily,
      avgWeeklyConsumption: avgWeekly,
      daysRemainingEstimate: daysRemaining,
      lastConsumptionDate: sorted.last.date,
      isAlmostEmpty: almostEmpty,
    );
  }

  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

  static bool _fallbackAlmostEmpty(Product product, double? daysRemaining) {
    if (daysRemaining != null && daysRemaining <= 3) return true;
    final tp = product.typicalPortion;
    if (tp != null && tp > 0) {
      return product.quantitaRimasta < (tp * 3);
    }
    return product.isLowStock;
  }
}
