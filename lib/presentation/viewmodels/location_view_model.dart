import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/location.dart';
import '../../domain/entities/location_with_positions.dart';
import '../../domain/entities/storage_position.dart';
import '../../domain/exceptions/location_exception.dart';
import '../../domain/repositories/location_repository.dart';
import '../../utils/location_validators.dart';

class LocationViewModel extends ChangeNotifier {
  LocationViewModel(this._repository);

  final LocationRepository _repository;

  List<LocationWithPositions> _items = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<LocationWithPositions> get items => List.unmodifiable(_items);

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

  Future<void> loadHierarchy() async {
    _setLoading(true);
    _errorMessage = null;
    notifyListeners();
    try {
      _items = await _repository.getAllWithPositions();
    } on LocationException catch (e) {
      _errorMessage = e.message;
      _items = [];
    } catch (e, st) {
      debugPrint('loadHierarchy: $e\n$st');
      _errorMessage = 'Qualcosa è andato storto. Riprova.';
      _items = [];
    } finally {
      _setLoading(false);
    }
  }

  Future<String?> createLocation({
    required String nome,
    String? descrizione,
  }) async {
    final desc = descrizione?.trim();
    final loc = Location(
      id: const Uuid().v4(),
      nome: nome.trim(),
      descrizione: (desc == null || desc.isEmpty) ? null : desc,
    );
    final err = LocationValidators.validateLocation(loc);
    if (err != null) {
      _errorMessage = err;
      notifyListeners();
      return err;
    }
    _errorMessage = null;
    notifyListeners();
    try {
      await _repository.saveLocation(loc);
      await loadHierarchy();
      return null;
    } on LocationException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return e.message;
    } catch (e, st) {
      debugPrint('createLocation: $e\n$st');
      _errorMessage = 'Impossibile creare il luogo';
      notifyListeners();
      return _errorMessage;
    }
  }

  Future<String?> updateLocation(Location location) async {
    final err = LocationValidators.validateLocation(location);
    if (err != null) {
      _errorMessage = err;
      notifyListeners();
      return err;
    }
    _errorMessage = null;
    notifyListeners();
    try {
      await _repository.saveLocation(location);
      await loadHierarchy();
      return null;
    } on LocationException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return e.message;
    } catch (e, st) {
      debugPrint('updateLocation: $e\n$st');
      _errorMessage = 'Impossibile aggiornare il luogo';
      notifyListeners();
      return _errorMessage;
    }
  }

  Future<String?> deleteLocation(String id) async {
    _errorMessage = null;
    notifyListeners();
    try {
      await _repository.deleteLocation(id);
      await loadHierarchy();
      return null;
    } on LocationException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return e.message;
    } catch (e, st) {
      debugPrint('deleteLocation: $e\n$st');
      _errorMessage = 'Impossibile eliminare il luogo';
      notifyListeners();
      return _errorMessage;
    }
  }

  Future<String?> addPosition({
    required String locationId,
    required String nome,
    String? descrizione,
  }) async {
    final desc = descrizione?.trim();
    final pos = StoragePosition(
      id: const Uuid().v4(),
      nome: nome.trim(),
      descrizione: (desc == null || desc.isEmpty) ? null : desc,
      locationId: locationId,
    );
    final err = LocationValidators.validatePosition(pos);
    if (err != null) {
      _errorMessage = err;
      notifyListeners();
      return err;
    }
    _errorMessage = null;
    notifyListeners();
    try {
      await _repository.savePosition(pos);
      await loadHierarchy();
      return null;
    } on LocationException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return e.message;
    } catch (e, st) {
      debugPrint('addPosition: $e\n$st');
      _errorMessage = 'Impossibile aggiungere la posizione';
      notifyListeners();
      return _errorMessage;
    }
  }

  Future<String?> updatePosition(StoragePosition position) async {
    final err = LocationValidators.validatePosition(position);
    if (err != null) {
      _errorMessage = err;
      notifyListeners();
      return err;
    }
    _errorMessage = null;
    notifyListeners();
    try {
      await _repository.savePosition(position);
      await loadHierarchy();
      return null;
    } on LocationException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return e.message;
    } catch (e, st) {
      debugPrint('updatePosition: $e\n$st');
      _errorMessage = 'Impossibile aggiornare la posizione';
      notifyListeners();
      return _errorMessage;
    }
  }

  Future<String?> deletePosition(String id) async {
    _errorMessage = null;
    notifyListeners();
    try {
      await _repository.deletePosition(id);
      await loadHierarchy();
      return null;
    } on LocationException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return e.message;
    } catch (e, st) {
      debugPrint('deletePosition: $e\n$st');
      _errorMessage = 'Impossibile eliminare la posizione';
      notifyListeners();
      return _errorMessage;
    }
  }

  LocationWithPositions? getLocationWithPositions(String locationId) {
    for (final item in _items) {
      if (item.location.id == locationId) return item;
    }
    return null;
  }
}
