import '../../domain/entities/product.dart';

/// Livello di urgenza per UI (colori, badge) — solo presentation.
enum ExpiryUrgency {
  expired,
  urgent,
  ok,
  unknown,
}

ExpiryUrgency urgencyOf(Product p) {
  if (p.dataScadenza == null) return ExpiryUrgency.unknown;
  if (p.isExpired) return ExpiryUrgency.expired;
  final d = p.daysUntilExpiry;
  if (d != null && d >= 0 && d <= 7) return ExpiryUrgency.urgent;
  return ExpiryUrgency.ok;
}
