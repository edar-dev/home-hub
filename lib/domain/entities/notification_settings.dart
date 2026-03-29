/// Preferenze promemoria locali (nessuna dipendenza da Flutter).
class NotificationSettings {
  const NotificationSettings({
    this.enabled = true,
    this.remindDayBefore = true,
    this.dailyDigest = false,
    this.includeLowStockInDigest = true,
  });

  final bool enabled;

  /// Notifica il giorno prima della scadenza (ore 9:00 locali).
  final bool remindDayBefore;

  /// Riepilogo giornaliero (ore 8:00 locali).
  final bool dailyDigest;

  /// Nel digest: conta prodotti con poca quantità ([Product.isLowStock]).
  final bool includeLowStockInDigest;

  NotificationSettings copyWith({
    bool? enabled,
    bool? remindDayBefore,
    bool? dailyDigest,
    bool? includeLowStockInDigest,
  }) {
    return NotificationSettings(
      enabled: enabled ?? this.enabled,
      remindDayBefore: remindDayBefore ?? this.remindDayBefore,
      dailyDigest: dailyDigest ?? this.dailyDigest,
      includeLowStockInDigest:
          includeLowStockInDigest ?? this.includeLowStockInDigest,
    );
  }
}
