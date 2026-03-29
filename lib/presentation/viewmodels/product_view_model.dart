import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../domain/entities/product.dart';
import '../../domain/exceptions/product_exception.dart';
import '../../domain/exceptions/validation_exception.dart';
import '../../domain/repositories/location_repository.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../domain/repositories/product_repository.dart';
import '../../utils/product_validators.dart';

/// Chip orizzontali inventario (prototipo Stitch).
enum InventoryQuickChip { tutti, scadenza, bassoStock, luogo }

/// Stato inventario: lista prodotti, filtro per luogo, caricamento ed errori.
///
/// Espone [displayedProducts] e [displayUiGeneration] per `Selector` efficienti.
class ProductViewModel extends ChangeNotifier {
  ProductViewModel(
    this._repository,
    this._locationRepository, {
    NotificationRepository? notificationRepository,
  })  : _notificationRepository = notificationRepository {
    _syncDisplayedAndBump();
  }

  final ProductRepository _repository;
  final LocationRepository _locationRepository;
  final NotificationRepository? _notificationRepository;

  List<Product> _products = [];
  List<Product> _displayedProducts = [];
  int _displayUiGeneration = 0;

  bool _isLoading = false;
  String? _errorMessage;

  String? _filterLocationId;
  Set<String> _positionIdsInFilter = {};
  InventoryQuickChip _quickChip = InventoryQuickChip.tutti;

  List<Product> get products => List.unmodifiable(_products);

  /// Snapshot aggiornato con `_products` e filtro luogo (no nuova lista a ogni getter).
  List<Product> get displayedProducts => _displayedProducts;

  /// Incrementato quando lista o filtro cambiano — utile a `Selector` nella UI.
  int get displayUiGeneration => _displayUiGeneration;

  String? get filterLocationId => _filterLocationId;

  InventoryQuickChip get quickInventoryChip => _quickChip;

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

  void _syncDisplayedAndBump() {
    Iterable<Product> cand = _products;
    if (_quickChip == InventoryQuickChip.scadenza) {
      cand = cand.where((p) {
        final d = p.daysUntilExpiry;
        return d != null && d >= 0 && d <= 7;
      });
    } else if (_quickChip == InventoryQuickChip.bassoStock) {
      cand = cand.where((p) => p.isLowStock);
    } else if (_quickChip == InventoryQuickChip.luogo &&
        _filterLocationId != null) {
      cand = cand.where(
        (p) =>
            p.positionId != null &&
            _positionIdsInFilter.contains(p.positionId),
      );
    }
    _displayedProducts = List.unmodifiable(cand.toList());
    _displayUiGeneration++;
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
    if (locationId != null) {
      _quickChip = InventoryQuickChip.luogo;
    } else {
      _quickChip = InventoryQuickChip.tutti;
    }
    await _refreshFilterPositions();
    _syncDisplayedAndBump();
    notifyListeners();
  }

  /// Chip rapidi (Stitch): [luogo] richiede [locationId].
  Future<void> setQuickInventoryChip(
    InventoryQuickChip chip, {
    String? locationId,
  }) async {
    if (chip == InventoryQuickChip.luogo) {
      if (locationId == null) return;
      _quickChip = chip;
      _filterLocationId = locationId;
      await _refreshFilterPositions();
      _syncDisplayedAndBump();
      notifyListeners();
      return;
    }
    _quickChip = chip;
    _filterLocationId = null;
    _positionIdsInFilter = {};
    _syncDisplayedAndBump();
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
    _syncDisplayedAndBump();
    notifyListeners();
    if (_errorMessage == null) {
      unawaited(_rescheduleNotifications());
    }
  }

  Future<void> _rescheduleNotifications() async {
    final n = _notificationRepository;
    if (n == null) return;
    try {
      await n.rescheduleAllForProducts(List<Product>.from(_products));
    } catch (e, st) {
      debugPrint('ProductViewModel._rescheduleNotifications: $e\n$st');
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
    final snapshot = List<Product>.from(_products);
    _products = _products.where((p) => p.id != id).toList();
    _syncDisplayedAndBump();
    notifyListeners();
    try {
      await _repository.delete(id);
      await loadProducts();
      return null;
    } on ProductException catch (e) {
      _products = snapshot;
      _syncDisplayedAndBump();
      _errorMessage = e.message;
      notifyListeners();
      return e.message;
    } catch (e, st) {
      debugPrint('deleteProduct: $e\n$st');
      _products = snapshot;
      _syncDisplayedAndBump();
      _errorMessage = 'Impossibile eliminare il prodotto';
      notifyListeners();
      return _errorMessage;
    }
  }
}
