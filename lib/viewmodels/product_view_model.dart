import 'package:flutter/foundation.dart';

import '../models/product.dart';
import '../services/product_storage_service.dart';
import '../services/storage_exception.dart';
import '../utils/product_validators.dart';

class ProductViewModel extends ChangeNotifier {
  ProductViewModel(this._storage);

  final ProductStorageService _storage;

  List<Product> _products = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Product> get products => List.unmodifiable(_products);

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> loadProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _products = _storage.getAll()
        ..sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
    } on StorageException catch (e) {
      _errorMessage = e.message;
      _products = [];
    } catch (e, st) {
      debugPrint('loadProducts: $e\n$st');
      _errorMessage = 'Errore imprevisto durante il caricamento';
      _products = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> addProduct(Product product) async {
    final err = ProductValidators.validateProduct(product);
    if (err != null) {
      _errorMessage = err;
      notifyListeners();
      return err;
    }
    _errorMessage = null;
    notifyListeners();
    try {
      await _storage.upsert(product);
      await loadProducts();
      return null;
    } on StorageException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return e.message;
    } catch (e, st) {
      debugPrint('addProduct: $e\n$st');
      _errorMessage = 'Impossibile aggiungere il prodotto';
      notifyListeners();
      return _errorMessage;
    }
  }

  Future<String?> updateProduct(Product product) async {
    final err = ProductValidators.validateProduct(product);
    if (err != null) {
      _errorMessage = err;
      notifyListeners();
      return err;
    }
    _errorMessage = null;
    notifyListeners();
    try {
      await _storage.upsert(product);
      await loadProducts();
      return null;
    } on StorageException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return e.message;
    } catch (e, st) {
      debugPrint('updateProduct: $e\n$st');
      _errorMessage = 'Impossibile aggiornare il prodotto';
      notifyListeners();
      return _errorMessage;
    }
  }

  Future<String?> deleteProduct(String id) async {
    _errorMessage = null;
    notifyListeners();
    try {
      await _storage.delete(id);
      await loadProducts();
      return null;
    } on StorageException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return e.message;
    } catch (e, st) {
      debugPrint('deleteProduct: $e\n$st');
      _errorMessage = 'Impossibile eliminare il prodotto';
      notifyListeners();
      return _errorMessage;
    }
  }
}
