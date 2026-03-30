import '../entities/consumption_entry.dart';

abstract class ConsumptionRepository {
  Future<void> saveEntry(ConsumptionEntry entry);

  Future<List<ConsumptionEntry>> getByProductId(String productId);

  Future<List<ConsumptionEntry>> getByDateRange(DateTime start, DateTime end);

  Future<void> deleteByProductId(String productId);
}
