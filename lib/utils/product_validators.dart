import '../models/product.dart';

/// Validazione pura per [Product] e campi form — utilizzabile da ViewModel e test.
abstract final class ProductValidators {
  static String? validateNome(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Il nome è obbligatorio';
    }
    return null;
  }

  static String? validateQuantitaTotale(int totale) {
    if (totale < 1) {
      return 'La quantità totale deve essere almeno 1';
    }
    return null;
  }

  static String? validateQuantitaRimasta(int rimasta, int totale) {
    if (rimasta < 0) {
      return 'La quantità rimasta non può essere negativa';
    }
    if (rimasta > totale) {
      return 'La quantità rimasta non può superare la totale';
    }
    return null;
  }

  /// Se entrambe le date sono presenti, scadenza deve essere >= acquisto (solo data).
  static String? validateDateOrder(DateTime? acquisto, DateTime? scadenza) {
    if (acquisto == null || scadenza == null) return null;
    final a = DateTime(acquisto.year, acquisto.month, acquisto.day);
    final s = DateTime(scadenza.year, scadenza.month, scadenza.day);
    if (s.isBefore(a)) {
      return 'La scadenza non può precedere la data di acquisto';
    }
    return null;
  }

  /// Restituisce il primo messaggio di errore o `null` se il prodotto è valido.
  static String? validateProduct(Product p) {
    return validateNome(p.nome) ??
        validateQuantitaTotale(p.quantitaTotale) ??
        validateQuantitaRimasta(p.quantitaRimasta, p.quantitaTotale) ??
        validateDateOrder(p.dataAcquisto, p.dataScadenza);
  }
}
