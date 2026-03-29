import 'package:hive/hive.dart';

import '../../../domain/entities/barcode_cache_entry.dart';
import '../../../domain/repositories/barcode_repository.dart';
import '../models/barcode_cache_hive_model.dart';

class LocalBarcodeRepository implements BarcodeRepository {
  LocalBarcodeRepository(this._box);

  final Box<BarcodeCacheHiveModel> _box;

  @override
  Future<BarcodeCacheEntry?> lookupBarcode(String barcode) async {
    final m = _box.get(barcode);
    if (m == null) return null;
    return BarcodeCacheEntry(
      barcode: m.barcode,
      suggestedName: m.suggestedName,
      scanCount: m.scanCount,
      lastScannedMs: m.lastScannedMs,
    );
  }

  @override
  Future<void> cacheBarcodeProduct({
    required String barcode,
    String? suggestedName,
  }) async {
    final existing = _box.get(barcode);
    await _box.put(
      barcode,
      BarcodeCacheHiveModel(
        barcode: barcode,
        suggestedName: suggestedName ?? existing?.suggestedName,
        scanCount: existing?.scanCount ?? 0,
        lastScannedMs: existing?.lastScannedMs,
      ),
    );
  }

  @override
  Future<List<BarcodeCacheEntry>> getFrequentBarcodes({int limit = 10}) async {
    final list = _box.values.toList()
      ..sort((a, b) => b.scanCount.compareTo(a.scanCount));
    return list
        .take(limit)
        .map(
          (m) => BarcodeCacheEntry(
            barcode: m.barcode,
            suggestedName: m.suggestedName,
            scanCount: m.scanCount,
            lastScannedMs: m.lastScannedMs,
          ),
        )
        .toList();
  }

  @override
  Future<void> recordScan(String barcode) async {
    final existing = _box.get(barcode);
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    await _box.put(
      barcode,
      BarcodeCacheHiveModel(
        barcode: barcode,
        suggestedName: existing?.suggestedName,
        scanCount: (existing?.scanCount ?? 0) + 1,
        lastScannedMs: now,
      ),
    );
  }
}
