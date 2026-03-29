import '../../../domain/entities/notification_settings.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/repositories/notification_repository.dart';

/// Web o ambienti senza plugin notifiche.
class NoOpNotificationRepository implements NotificationRepository {
  @override
  Future<void> initialize() async {}

  @override
  Future<NotificationSettings> getSettings() async =>
      const NotificationSettings();

  @override
  Future<void> saveSettings(NotificationSettings settings) async {}

  @override
  Future<void> requestPermissionsIfNeeded() async {}

  @override
  Future<void> rescheduleAllForProducts(List<Product> products) async {}
}
