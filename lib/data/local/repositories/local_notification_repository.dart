import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:hive/hive.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../../../domain/entities/consumption_stats.dart';
import '../../../domain/entities/notification_settings.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/repositories/consumption_repository.dart';
import '../../../core/brand/app_brand.dart';
import '../../../domain/repositories/notification_repository.dart';
import '../../../domain/services/consumption_calculator.dart';
import '../models/notification_settings_hive_model.dart';

class LocalNotificationRepository implements NotificationRepository {
  LocalNotificationRepository(
    this._box, {
    FlutterLocalNotificationsPlugin? plugin,
    ConsumptionRepository? consumptionRepository,
  })  : _plugin = plugin ?? FlutterLocalNotificationsPlugin(),
        _consumptionRepository = consumptionRepository;

  static const String _boxKey = 'settings';
  static const int _digestNotificationId = 900000001;

  final Box<NotificationSettingsHiveModel> _box;
  final FlutterLocalNotificationsPlugin _plugin;
  final ConsumptionRepository? _consumptionRepository;

  bool _initialized = false;

  @override
  Future<void> initialize() async {
    if (kIsWeb) return;
    if (_initialized) return;
    tzdata.initializeTimeZones();
    try {
      final tzInfo = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(tzInfo.identifier));
    } catch (e, st) {
      debugPrint('LocalNotificationRepository: timezone fallback $e\n$st');
      tz.setLocalLocation(tz.getLocation('Europe/Rome'));
    }

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _plugin.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.createNotificationChannel(
      AndroidNotificationChannel(
        'housekeep_main',
        AppBrand.appNameShort,
        description: 'Scadenze e riepiloghi',
        importance: Importance.defaultImportance,
      ),
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    _initialized = true;
  }

  void _onNotificationResponse(NotificationResponse response) {
    debugPrint('notification tap payload=${response.payload}');
  }

  NotificationSettings _toDomain(NotificationSettingsHiveModel m) {
    return NotificationSettings(
      enabled: m.enabled,
      remindDayBefore: m.remindDayBefore,
      dailyDigest: m.dailyDigest,
      includeLowStockInDigest: m.includeLowStockInDigest,
    );
  }

  NotificationSettingsHiveModel _toHive(NotificationSettings s) {
    return NotificationSettingsHiveModel(
      enabled: s.enabled,
      remindDayBefore: s.remindDayBefore,
      dailyDigest: s.dailyDigest,
      includeLowStockInDigest: s.includeLowStockInDigest,
    );
  }

  @override
  Future<NotificationSettings> getSettings() async {
    final m = _box.get(_boxKey);
    if (m == null) {
      const defaults = NotificationSettings();
      await _box.put(_boxKey, _toHive(defaults));
      return defaults;
    }
    return _toDomain(m);
  }

  @override
  Future<void> saveSettings(NotificationSettings settings) async {
    await _box.put(_boxKey, _toHive(settings));
  }

  @override
  Future<void> requestPermissionsIfNeeded() async {
    if (kIsWeb) return;
    if (defaultTargetPlatform == TargetPlatform.android) {
      final status = await Permission.notification.status;
      if (!status.isGranted) {
        await Permission.notification.request();
      }
    }
  }

  Future<NotificationDetails> _details() async {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        'housekeep_main',
        AppBrand.appNameShort,
        channelDescription: 'Scadenze e riepiloghi',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
      iOS: const DarwinNotificationDetails(),
    );
  }

  tz.TZDateTime _atNineAm(DateTime date) {
    final loc = tz.local;
    return tz.TZDateTime(
      loc,
      date.year,
      date.month,
      date.day,
      9,
      0,
    );
  }

  tz.TZDateTime _nextEightAmFrom(DateTime from) {
    final loc = tz.local;
    var t = tz.TZDateTime(loc, from.year, from.month, from.day, 8, 0);
    if (!t.isAfter(from)) {
      t = t.add(const Duration(days: 1));
    }
    return t;
  }

  @override
  Future<void> rescheduleAllForProducts(List<Product> products) async {
    if (kIsWeb) return;
    if (!_initialized) {
      await initialize();
    }
    final settings = await getSettings();
    await _plugin.cancelAll();
    if (!settings.enabled) {
      return;
    }

    final details = await _details();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final statsByProduct = <String, ConsumptionStats>{};
    final cRepo = _consumptionRepository;
    if (cRepo != null) {
      for (final p in products) {
        final entries = await cRepo.getByProductId(p.id);
        statsByProduct[p.id] = ConsumptionCalculator.compute(p, entries);
      }
    }

    if (settings.remindDayBefore) {
      for (final p in products) {
        final d = p.dataScadenza;
        if (d == null) continue;
        final expiryDay = DateTime(d.year, d.month, d.day);
        final remindDay = expiryDay.subtract(const Duration(days: 1));
        if (remindDay.isBefore(today)) continue;
        final scheduled = _atNineAm(remindDay);
        final tzNow = tz.TZDateTime.now(tz.local);
        if (!scheduled.isAfter(tzNow)) continue;

        final id = p.id.hashCode & 0x7fffffff;
        await _plugin.zonedSchedule(
          id,
          'Scadenza in arrivo',
          '${p.nome} scade il ${_fmt(expiryDay)}',
          scheduled,
          details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
    }

    if (settings.dailyDigest) {
      final low = settings.includeLowStockInDigest
          ? products.where((e) => e.isLowStock).length
          : 0;
      final expiringSoon = products.where((p) {
        final days = p.daysUntilExpiry;
        return days != null && days >= 0 && days <= 7;
      }).length;
      final expired = products.where((p) => p.isExpired).length;

      final body =
          'Scaduti: $expired · In scadenza (7gg): $expiringSoon'
          '${settings.includeLowStockInDigest ? ' · Poca quantità: $low' : ''}'
          '${statsByProduct.isNotEmpty ? ' · Quasi finiti: ${statsByProduct.values.where((s) => s.isAlmostEmpty).length}' : ''}';

      final when = _nextEightAmFrom(now);
      await _plugin.zonedSchedule(
        _digestNotificationId,
        'Riepilogo ${AppBrand.appNameShort}',
        body,
        when,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }

    // Alert consumo intelligenti: quasi esaurito + non usato.
    if (statsByProduct.isNotEmpty) {
      var i = 0;
      for (final p in products) {
        final st = statsByProduct[p.id];
        if (st == null) continue;
        if (st.isAlmostEmpty && p.quantitaRimasta > 0) {
          final when = _nextEightAmFrom(now).add(Duration(minutes: i));
          await _plugin.zonedSchedule(
            910000000 + i,
            'Quasi esaurito: ${p.nome}',
            'Hai ancora ${p.quantitaRimasta} ${p.unit}. Finitura stimata: '
                '${st.daysRemainingEstimate?.toStringAsFixed(1) ?? 'n/d'} giorni.',
            when,
            details,
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
          );
          i++;
          continue;
        }
        final last = st.lastConsumptionDate;
        if (last != null) {
          final days = DateTime.now().difference(last).inDays;
          final nearExpiry = (p.daysUntilExpiry ?? 999) <= 3;
          if (days > 14 && nearExpiry && p.quantitaRimasta > 0) {
            final when = _nextEightAmFrom(now).add(Duration(minutes: i));
            await _plugin.zonedSchedule(
              920000000 + i,
              'Spreco potenziale: ${p.nome}',
              '${p.nome} scade tra ${(p.daysUntilExpiry ?? 0)} giorni e non è usato da $days giorni.',
              when,
              details,
              androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
              uiLocalNotificationDateInterpretation:
                  UILocalNotificationDateInterpretation.absoluteTime,
            );
            i++;
          }
        }
      }
    }
  }

  String _fmt(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd/$mm/${d.year}';
  }
}
