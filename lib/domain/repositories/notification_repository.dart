import '../entities/notification_settings.dart';
import '../entities/product.dart';

/// Impostazioni notifiche + scheduling (plugin nativo); su Web è no-op.
abstract class NotificationRepository {
  Future<void> initialize();

  Future<NotificationSettings> getSettings();

  Future<void> saveSettings(NotificationSettings settings);

  /// Richiede permesso notifiche dove necessario (es. Android 13+).
  Future<void> requestPermissionsIfNeeded();

  /// Ricalcola tutte le notifiche in base ai prodotti correnti.
  Future<void> rescheduleAllForProducts(List<Product> products);
}
