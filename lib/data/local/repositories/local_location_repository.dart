import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../domain/entities/location.dart';
import '../../../domain/entities/location_with_positions.dart';
import '../../../domain/entities/storage_position.dart';
import '../../../domain/exceptions/location_exception.dart';
import '../../../domain/repositories/location_repository.dart';
import '../../../domain/repositories/product_repository.dart';
import '../mappers/location_mapper.dart';
import '../mappers/position_mapper.dart';
import '../models/location_hive_model.dart';
import '../models/position_hive_model.dart';

class LocalLocationRepository implements LocationRepository {
  LocalLocationRepository(
    this._locationsBox,
    this._positionsBox,
    this._productRepository,
  );

  final Box<LocationHiveModel> _locationsBox;
  final Box<PositionHiveModel> _positionsBox;
  final ProductRepository _productRepository;

  List<LocationWithPositions> _buildHierarchy() {
    final allLocations =
        _locationsBox.values.map(LocationMapper.toDomain).toList();
    final allPositions =
        _positionsBox.values.map(PositionMapper.toDomain).toList();

    final byLocation = <String, List<StoragePosition>>{};
    for (final p in allPositions) {
      (byLocation[p.locationId] ??= []).add(p);
    }

    return allLocations.map((loc) {
      final children =
          List<StoragePosition>.from(byLocation[loc.id] ?? const [])
            ..sort(
              (a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()),
            );
      return LocationWithPositions(location: loc, positions: children);
    }).toList()
      ..sort(
        (a, b) => a.location.nome
            .toLowerCase()
            .compareTo(b.location.nome.toLowerCase()),
      );
  }

  @override
  Future<List<LocationWithPositions>> getAllWithPositions() async {
    try {
      return _buildHierarchy();
    } catch (e, st) {
      debugPrint('LocalLocationRepository.getAllWithPositions: $e\n$st');
      throw LocationException('Errore lettura luoghi', e);
    }
  }

  @override
  Future<Location?> getLocationById(String id) async {
    try {
      final m = _locationsBox.get(id);
      return m == null ? null : LocationMapper.toDomain(m);
    } catch (e, st) {
      debugPrint('LocalLocationRepository.getLocationById: $e\n$st');
      throw LocationException('Errore lettura luogo', e);
    }
  }

  @override
  Future<LocationWithPositions?> getLocationWithPositions(
    String locationId,
  ) async {
    try {
      final loc = await getLocationById(locationId);
      if (loc == null) return null;
      final positions = _positionsBox.values
          .map(PositionMapper.toDomain)
          .where((p) => p.locationId == locationId)
          .toList()
        ..sort(
          (a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()),
        );
      return LocationWithPositions(location: loc, positions: positions);
    } catch (e, st) {
      debugPrint('LocalLocationRepository.getLocationWithPositions: $e\n$st');
      throw LocationException('Errore lettura luogo', e);
    }
  }

  @override
  Future<void> saveLocation(Location location) async {
    try {
      final stamped = location.copyWith(updatedAt: DateTime.now().toUtc());
      await _locationsBox.put(stamped.id, LocationMapper.toHive(stamped));
    } catch (e, st) {
      debugPrint('LocalLocationRepository.saveLocation: $e\n$st');
      throw LocationException('Impossibile salvare il luogo', e);
    }
  }

  @override
  Future<void> deleteLocation(String id) async {
    try {
      final positionIds = <String>[];
      final keysToDelete = <dynamic>[];
      for (final key in _positionsBox.keys.toList()) {
        final p = _positionsBox.get(key);
        if (p != null && p.locationId == id) {
          positionIds.add(p.id);
          keysToDelete.add(key);
        }
      }
      await _productRepository.clearPositionIdsForPositions(positionIds);
      for (final key in keysToDelete) {
        await _positionsBox.delete(key);
      }
      await _locationsBox.delete(id);
    } catch (e, st) {
      debugPrint('LocalLocationRepository.deleteLocation: $e\n$st');
      throw LocationException('Impossibile eliminare il luogo', e);
    }
  }

  @override
  Future<void> savePosition(StoragePosition position) async {
    try {
      if (!_locationsBox.containsKey(position.locationId)) {
        throw LocationException('Il luogo selezionato non esiste');
      }
      final stamped = position.copyWith(updatedAt: DateTime.now().toUtc());
      await _positionsBox.put(stamped.id, PositionMapper.toHive(stamped));
    } on LocationException {
      rethrow;
    } catch (e, st) {
      debugPrint('LocalLocationRepository.savePosition: $e\n$st');
      throw LocationException('Impossibile salvare la posizione', e);
    }
  }

  @override
  Future<void> deletePosition(String id) async {
    try {
      await _productRepository.clearPositionIdsForPositions([id]);
      await _positionsBox.delete(id);
    } catch (e, st) {
      debugPrint('LocalLocationRepository.deletePosition: $e\n$st');
      throw LocationException('Impossibile eliminare la posizione', e);
    }
  }
}
