import 'package:flutter/foundation.dart';

import '../../domain/entities/notification_settings.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../domain/repositories/product_repository.dart';

class NotificationSettingsViewModel extends ChangeNotifier {
  NotificationSettingsViewModel(
    this._notifications,
    this._products,
  ) {
    load();
  }

  final NotificationRepository _notifications;
  final ProductRepository _products;

  NotificationSettings _settings = const NotificationSettings();
  bool _loading = true;
  bool _saving = false;

  NotificationSettings get settings => _settings;

  bool get isLoading => _loading;

  bool get isSaving => _saving;

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    try {
      _settings = await _notifications.getSettings();
    } catch (e, st) {
      debugPrint('NotificationSettingsViewModel.load: $e\n$st');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void setEnabled(bool v) {
    _settings = _settings.copyWith(enabled: v);
    notifyListeners();
  }

  void setRemindDayBefore(bool v) {
    _settings = _settings.copyWith(remindDayBefore: v);
    notifyListeners();
  }

  void setDailyDigest(bool v) {
    _settings = _settings.copyWith(dailyDigest: v);
    notifyListeners();
  }

  void setIncludeLowStock(bool v) {
    _settings = _settings.copyWith(includeLowStockInDigest: v);
    notifyListeners();
  }

  Future<String?> save() async {
    _saving = true;
    notifyListeners();
    try {
      await _notifications.saveSettings(_settings);
      final list = await _products.getAll();
      await _notifications.rescheduleAllForProducts(list);
      await _notifications.requestPermissionsIfNeeded();
      return null;
    } catch (e, st) {
      debugPrint('NotificationSettingsViewModel.save: $e\n$st');
      return 'Impossibile salvare le impostazioni.';
    } finally {
      _saving = false;
      notifyListeners();
    }
  }
}
