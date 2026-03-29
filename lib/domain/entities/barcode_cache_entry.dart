/// Cache locale codice a barre → nome suggerito e frequenza.
class BarcodeCacheEntry {
  const BarcodeCacheEntry({
    required this.barcode,
    this.suggestedName,
    this.scanCount = 0,
    this.lastScannedMs,
  });

  final String barcode;
  final String? suggestedName;
  final int scanCount;
  final int? lastScannedMs;
}
