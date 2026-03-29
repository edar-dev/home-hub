import 'package:hive/hive.dart';

part 'notification_settings_hive_model.g.dart';

@HiveType(typeId: 4)
class NotificationSettingsHiveModel extends HiveObject {
  NotificationSettingsHiveModel({
    required this.enabled,
    required this.remindDayBefore,
    required this.dailyDigest,
    required this.includeLowStockInDigest,
  });

  @HiveField(0)
  bool enabled;

  @HiveField(1)
  bool remindDayBefore;

  @HiveField(2)
  bool dailyDigest;

  @HiveField(3)
  bool includeLowStockInDigest;
}
