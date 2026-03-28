import 'package:flutter/foundation.dart';

import '../../domain/entities/product.dart';
import '../../domain/exceptions/product_exception.dart';
import '../../domain/exceptions/validation_exception.dart';
import '../../domain/repositories/product_repository.dart';
import '../../utils/product_validators.dart';

class ProductViewModel extends ChangeNotifier {
  ProductViewModel(this._repository);

  final ProductRepository _repository;

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

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  Future<void> loadProducts() async {
    _setLoading(true);
    _errorMessage = null;
    notifyListeners();
    try {
      final list = await _repository.getAll();
      list.sort(
        (a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()),
      );
      _products = list;
    } on ProductException catch (e) {
      _errorMessage = e.message;
      _products = [];
    } catch (e, st) {
      debugPrint('loadProducts: $e\n$st');
      _errorMessage = 'Qualcosa è andato storto. Riprova.';
      _products = [];
    } finally {
      _setLoading(false);
    }
  }

  Future<String?> createProduct(Product product) async {
    final err = ProductValidators.validateProduct(product);
    if (err != null) {
      _errorMessage = err;
      notifyListeners();
      return err;
    }
    _errorMessage = null;
    notifyListeners();
    try {
      await _repository.save(product);
      await loadProducts();
      return null;
    } on ValidationException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return e.message;
    } on ProductException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return e.message;
    } catch (e, st) {
      debugPrint('createProduct: $e\n$st');
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
      await _repository.save(product);
      await loadProducts();
      return null;
    } on ValidationException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return e.message;
    } on ProductException catch (e) {
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
      await _repository.delete(id);
      await loadProducts();
      return null;
    } on ProductException catch (e) {
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
