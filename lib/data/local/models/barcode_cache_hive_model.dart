import 'package:hive/hive.dart';

part 'barcode_cache_hive_model.g.dart';

@HiveType(typeId: 3)
class BarcodeCacheHiveModel extends HiveObject {
  BarcodeCacheHiveModel({
    required this.barcode,
    this.suggestedName,
    this.scanCount = 0,
    this.lastScannedMs,
  });

  @HiveField(0)
  String barcode;

  @HiveField(1)
  String? suggestedName;

  @HiveField(2)
  int scanCount;

  @HiveField(3)
  int? lastScannedMs;
}
