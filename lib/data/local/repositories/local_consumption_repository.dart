import 'package:hive/hive.dart';

import '../../../domain/entities/consumption_entry.dart';
import '../../../domain/repositories/consumption_repository.dart';
import '../models/consumption_entry_hive_model.dart';

class LocalConsumptionRepository implements ConsumptionRepository {
  LocalConsumptionRepository(this._box);

  final Box<ConsumptionEntryHiveModel> _box;

  @override
  Future<void> saveEntry(ConsumptionEntry entry) async {
    final model = ConsumptionEntryHiveModel(
      id: entry.id,
      productId: entry.productId,
      amount: entry.amount,
      unit: entry.unit,
      dateMs: entry.date.toUtc().millisecondsSinceEpoch,
      meal: entry.meal?.index,
      recipe: entry.recipe,
      notes: entry.notes,
      source: entry.source.index,
    );
    await _box.put(entry.id, model);
  }

  @override
  Future<List<ConsumptionEntry>> getByProductId(String productId) async {
    final out = _box.values
        .where((e) => e.productId == productId)
        .map(_toDomain)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    return out;
  }

  @override
  Future<List<ConsumptionEntry>> getByDateRange(DateTime start, DateTime end) async {
    final s = start.toUtc().millisecondsSinceEpoch;
    final e = end.toUtc().millisecondsSinceEpoch;
    final out = _box.values
        .where((x) => x.dateMs >= s && x.dateMs <= e)
        .map(_toDomain)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    return out;
  }

  @override
  Future<void> deleteByProductId(String productId) async {
    final ids = _box.values
        .where((x) => x.productId == productId)
        .map((x) => x.id)
        .toList();
    await _box.deleteAll(ids);
  }

  ConsumptionEntry _toDomain(ConsumptionEntryHiveModel e) {
    return ConsumptionEntry(
      id: e.id,
      productId: e.productId,
      amount: e.amount,
      unit: e.unit,
      date: DateTime.fromMillisecondsSinceEpoch(e.dateMs, isUtc: true).toLocal(),
      meal: e.meal == null ? null : ConsumptionMeal.values[e.meal!],
      recipe: e.recipe,
      notes: e.notes,
      source: ConsumptionSource.values[e.source],
    );
  }
}
