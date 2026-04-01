import '../entities/consumption_entry.dart';

abstract class ConsumptionRepository {
  Future<void> saveEntry(ConsumptionEntry entry);

  Future<List<ConsumptionEntry>> getByProductId(String productId);

  /// Una sola scansione dello storage: entry raggruppate per [ConsumptionEntry.productId].
  /// Utile per analytics senza pattern N+1.
  Future<Map<String, List<ConsumptionEntry>>> getAllGroupedByProductId();

  Future<List<ConsumptionEntry>> getByDateRange(DateTime start, DateTime end);

  Future<void> deleteByProductId(String productId);
}
