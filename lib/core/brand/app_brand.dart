/// Costanti di brand consumer **The Organized Hive**.
///
/// Il package Dart resta `housekeep`; [appNameDisplay] è il nome prodotto in UI e store.
/// Riferimento: `docs/brand/the-organized-hive-brand-decisions.md`.
abstract final class AppBrand {
  AppBrand._();

  /// Nome completo su launcher, MaterialApp, store.
  static const String appNameDisplay = 'The Organized Hive';

  /// Nome breve: notifiche, tooltip, spazi ridotti.
  static const String appNameShort = 'Hive';

  /// Tagline (IT).
  static const String taglineIt = 'La casa, a colpo d’occhio.';

  /// Tagline (EN).
  static const String taglineEn = 'Your home, at a glance.';

  /// Payoff one-liner (IT).
  static const String payoffOneLinerIt =
      'Inventario, scadenze e spesa in un solo posto chiaro — per chi coordina la casa.';

  /// Payoff one-liner (EN).
  static const String payoffOneLinerEn =
      'Inventory, expiry, and shopping in one clear place — for whoever runs the home.';

  /// Titolo [MaterialApp] (sistema / task switcher).
  static String get materialAppTitle => appNameDisplay;
}
