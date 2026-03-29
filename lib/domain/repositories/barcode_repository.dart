import '../entities/barcode_cache_entry.dart';

abstract class BarcodeRepository {
  Future<BarcodeCacheEntry?> lookupBarcode(String barcode);

  Future<void> cacheBarcodeProduct({
    required String barcode,
    String? suggestedName,
  });

  Future<List<BarcodeCacheEntry>> getFrequentBarcodes({int limit = 10});

  Future<void> recordScan(String barcode);
}
