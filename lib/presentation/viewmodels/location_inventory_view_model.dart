import 'package:flutter/foundation.dart';

import '../../domain/entities/location.dart';
import '../../domain/entities/location_with_positions.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/storage_position.dart';
import '../../domain/exceptions/location_exception.dart';
import '../../domain/exceptions/product_exception.dart';
import '../../domain/repositories/location_repository.dart';
import '../../domain/repositories/product_repository.dart';

enum ProductStatusFilter { all, expiring, expired, lowStock }

enum ProductOpenStateFilter { all, opened, unopened }

/// Blocco posizione + prodotti in quel punto (read model).
class PositionProductsBlock {
  const PositionProductsBlock({
    required this.position,
    required this.products,
  });

  final StoragePosition position;
  final List<Product> products;
}

/// Sezione inventario per un luogo.
class LocationInventorySection {
  const LocationInventorySection({
    required this.location,
    required this.blocks,
  });

  final Location location;
  final List<PositionProductsBlock> blocks;

  int get productCount => blocks.fold<int>(0, (s, b) => s + b.products.length);
}

/// Riepilogo inventario per stanza: per ogni [Location], blocchi posizione → prodotti.
///
/// Costruisce le [sections] incrociando gerarchia luoghi e [Product.positionId].
class LocationInventoryViewModel extends ChangeNotifier {
  LocationInventoryViewModel(
    this._productRepository,
    this._locationRepository,
  );

  final ProductRepository _productRepository;
  final LocationRepository _locationRepository;

  List<LocationInventorySection> _sections = [];
  bool _isLoading = false;
  String? _errorMessage;
  List<LocationWithPositions> _hierarchyCache = [];
  List<Product> _productsCache = [];
  bool _hasLocationsInScope = false;
  int _productsInScopeBeforeFilters = 0;

  List<LocationInventorySection> get sections => List.unmodifiable(_sections);

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;
  bool get hasLocationsInScope => _hasLocationsInScope;
  int get productsInScopeBeforeFilters => _productsInScopeBeforeFilters;

  /// Se non null, solo questa location è inclusa.
  String? _filterLocationId;
  String _searchQuery = '';
  ProductStatusFilter _statusFilter = ProductStatusFilter.all;
  ProductOpenStateFilter _openStateFilter = ProductOpenStateFilter.all;

  String get searchQuery => _searchQuery;
  ProductStatusFilter get statusFilter => _statusFilter;
  ProductOpenStateFilter get openStateFilter => _openStateFilter;
  bool get hasActiveProductFilters =>
      _searchQuery.trim().isNotEmpty ||
      _statusFilter != ProductStatusFilter.all ||
      _openStateFilter != ProductOpenStateFilter.all;

  void setLocationFilter(String? locationId) {
    _filterLocationId = locationId;
    _rebuildSections();
  }

  void setSearchQuery(String value) {
    if (_searchQuery == value) return;
    _searchQuery = value;
    _rebuildSections();
    notifyListeners();
  }

  void setStatusFilter(ProductStatusFilter value) {
    if (_statusFilter == value) return;
    _statusFilter = value;
    _rebuildSections();
    notifyListeners();
  }

  void setOpenStateFilter(ProductOpenStateFilter value) {
    if (_openStateFilter == value) return;
    _openStateFilter = value;
    _rebuildSections();
    notifyListeners();
  }

  void clearProductFilters() {
    if (!hasActiveProductFilters) return;
    _searchQuery = '';
    _statusFilter = ProductStatusFilter.all;
    _openStateFilter = ProductOpenStateFilter.all;
    _rebuildSections();
    notifyListeners();
  }

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      var hierarchy = await _locationRepository.getAllWithPositions();
      if (_filterLocationId != null) {
        hierarchy =
            hierarchy.where((e) => e.location.id == _filterLocationId).toList();
      }
      _hierarchyCache = hierarchy;
      _productsCache = await _productRepository.getAll();
      _rebuildSections();
    } on ProductException catch (e) {
      _errorMessage = e.message;
      _sections = [];
    } on LocationException catch (e) {
      _errorMessage = e.message;
      _sections = [];
    } catch (e, st) {
      debugPrint('LocationInventoryViewModel.load: $e\n$st');
      _errorMessage = 'Qualcosa è andato storto. Riprova.';
      _sections = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool _matchesStatus(Product p) {
    switch (_statusFilter) {
      case ProductStatusFilter.all:
        return true;
      case ProductStatusFilter.expiring:
        final days = p.daysUntilExpiry;
        return days != null && days >= 0 && days <= 7;
      case ProductStatusFilter.expired:
        return p.isExpired;
      case ProductStatusFilter.lowStock:
        return p.isLowStock;
    }
  }

  bool _matchesOpenState(Product p) {
    switch (_openStateFilter) {
      case ProductOpenStateFilter.all:
        return true;
      case ProductOpenStateFilter.opened:
        return p.isOpened;
      case ProductOpenStateFilter.unopened:
        return !p.isOpened;
    }
  }

  bool _matchesSearch(Product p) {
    final q = _searchQuery.trim().toLowerCase();
    if (q.isEmpty) return true;
    return p.nome.toLowerCase().contains(q);
  }

  void _rebuildSections() {
    final hierarchy = _hierarchyCache;
    _hasLocationsInScope = hierarchy.isNotEmpty;

    final byPos = <String, List<Product>>{};
    for (final p in _productsCache) {
      final pid = p.positionId;
      if (pid != null) {
        (byPos[pid] ??= []).add(p);
      }
    }
    _productsInScopeBeforeFilters = byPos.values.fold<int>(
      0,
      (sum, products) => sum + products.length,
    );
    for (final list in byPos.values) {
      list.sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
    }

    final filteredByPos = <String, List<Product>>{};
    for (final entry in byPos.entries) {
      final filtered = entry.value
          .where((p) =>
              _matchesSearch(p) && _matchesStatus(p) && _matchesOpenState(p))
          .toList();
      if (filtered.isNotEmpty) {
        filteredByPos[entry.key] = filtered;
      }
    }

    final nextSections = <LocationInventorySection>[];
    for (final row in hierarchy) {
      final blocks = row.positions
          .map(
            (pos) => PositionProductsBlock(
              position: pos,
              products: List<Product>.from(filteredByPos[pos.id] ?? const []),
            ),
          )
          .toList();
      if (hasActiveProductFilters) {
        final withMatches = blocks.where((b) => b.products.isNotEmpty).toList();
        if (withMatches.isNotEmpty) {
          nextSections.add(
            LocationInventorySection(
                location: row.location, blocks: withMatches),
          );
        }
      } else {
        nextSections.add(
          LocationInventorySection(location: row.location, blocks: blocks),
        );
      }
    }
    _sections = nextSections;
  }
}
