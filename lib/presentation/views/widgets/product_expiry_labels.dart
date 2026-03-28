import '../../../domain/entities/product.dart';

String expiryLineForList(Product p) {
  if (p.dataScadenza == null) return 'Nessuna scadenza';
  if (p.isExpired) return 'Scaduto';
  final d = p.daysUntilExpiry;
  if (d == null) return '';
  if (d == 0) return 'Scade oggi';
  if (d == 1) return 'Tra 1 giorno';
  return 'Tra $d giorni';
}

String recommendedUseHint(Product p) {
  if (p.isExpired) {
    return 'Non consumare: prodotto scaduto.';
  }
  final d = p.daysUntilExpiry;
  if (d != null && d >= 0 && d <= 7) {
    return 'Consumare presto: in scadenza entro una settimana.';
  }
  if (p.isOpened && p.dataApertura != null) {
    final daysOpen = DateTime.now().difference(p.dataApertura!).inDays;
    if (daysOpen > 7) {
      return 'Aperto da più di una settimana: verificare conservazione e odore/aspetto prima del consumo.';
    }
    return 'Prodotto aperto: chiudere bene dopo l’uso e rispettare le indicazioni del packaging.';
  }
  if (p.dataScadenza == null) {
    return 'Nessuna data di scadenza: annotarla se presente sulla confezione.';
  }
  return 'Conservare come indicato sulla confezione.';
}
