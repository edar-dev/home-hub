import 'package:flutter/foundation.dart';

import '../../domain/entities/location.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/storage_position.dart';
import '../../domain/exceptions/location_exception.dart';
import '../../domain/exceptions/product_exception.dart';
import '../../domain/repositories/location_repository.dart';
import '../../domain/repositories/product_repository.dart';

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

  int get productCount =>
      blocks.fold<int>(0, (s, b) => s + b.products.length);
}

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

  List<LocationInventorySection> get sections =>
      List.unmodifiable(_sections);

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  /// Se non null, solo questa location è inclusa.
  String? _filterLocationId;

  void setLocationFilter(String? locationId) {
    _filterLocationId = locationId;
  }

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      var hierarchy = await _locationRepository.getAllWithPositions();
      if (_filterLocationId != null) {
        hierarchy = hierarchy
            .where((e) => e.location.id == _filterLocationId)
            .toList();
      }
      final prods = await _productRepository.getAll();
      final byPos = <String, List<Product>>{};
      for (final p in prods) {
        final pid = p.positionId;
        if (pid != null) {
          (byPos[pid] ??= []).add(p);
        }
      }
      for (final list in byPos.values) {
        list.sort(
          (a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()),
        );
      }
      _sections = hierarchy.map((row) {
        final blocks = row.positions
            .map(
              (pos) => PositionProductsBlock(
                position: pos,
                products: List<Product>.from(byPos[pos.id] ?? const []),
              ),
            )
            .toList();
        return LocationInventorySection(
          location: row.location,
          blocks: blocks,
        );
      }).toList();
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
}
