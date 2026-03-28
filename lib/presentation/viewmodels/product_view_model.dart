import 'package:flutter/foundation.dart';

import '../../domain/entities/product.dart';
import '../../domain/exceptions/product_exception.dart';
import '../../domain/exceptions/validation_exception.dart';
import '../../domain/repositories/location_repository.dart';
import '../../domain/repositories/product_repository.dart';
import '../../utils/product_validators.dart';

class ProductViewModel extends ChangeNotifier {
  ProductViewModel(this._repository, this._locationRepository);

  final ProductRepository _repository;
  final LocationRepository _locationRepository;

  List<Product> _products = [];
  bool _isLoading = false;
  String? _errorMessage;

  String? _filterLocationId;
  Set<String> _positionIdsInFilter = {};

  List<Product> get products => List.unmodifiable(_products);

  /// Lista mostrata in UI (rispetta filtro luogo se attivo).
  List<Product> get displayedProducts {
    if (_filterLocationId == null) return products;
    return _products
        .where(
          (p) =>
              p.positionId != null &&
              _positionIdsInFilter.contains(p.positionId),
        )
        .toList();
  }

  String? get filterLocationId => _filterLocationId;

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

  Future<void> _refreshFilterPositions() async {
    if (_filterLocationId == null) {
      _positionIdsInFilter = {};
      return;
    }
    final loc = await _locationRepository.getLocationWithPositions(
      _filterLocationId!,
    );
    _positionIdsInFilter = loc?.positions.map((e) => e.id).toSet() ?? {};
  }

  /// Filtro inventario per luogo (`null` = tutti i prodotti).
  Future<void> setLocationFilter(String? locationId) async {
    _filterLocationId = locationId;
    await _refreshFilterPositions();
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
      if (_filterLocationId != null) {
        await _refreshFilterPositions();
      }
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
    notifyListeners();
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
    final snapshot = List<Product>.from(_products);
    _products = _products.where((p) => p.id != id).toList();
    notifyListeners();
    try {
      await _repository.delete(id);
      await loadProducts();
      return null;
    } on ProductException catch (e) {
      _products = snapshot;
      _errorMessage = e.message;
      notifyListeners();
      return e.message;
    } catch (e, st) {
      debugPrint('deleteProduct: $e\n$st');
      _products = snapshot;
      _errorMessage = 'Impossibile eliminare il prodotto';
      notifyListeners();
      return _errorMessage;
    }
  }
}
