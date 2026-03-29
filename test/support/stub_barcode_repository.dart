import 'dart:io';

import 'package:housekeep/core/services/photo_storage_service.dart';
import 'package:housekeep/domain/repositories/barcode_repository.dart';
import 'package:mocktail/mocktail.dart';

class StubBarcodeRepository extends Mock implements BarcodeRepository {}

StubBarcodeRepository buildStubBarcodeRepository() {
  final m = StubBarcodeRepository();
  when(() => m.lookupBarcode(any())).thenAnswer((_) async => null);
  when(
    () => m.cacheBarcodeProduct(
      barcode: any(named: 'barcode'),
      suggestedName: any(named: 'suggestedName'),
    ),
  ).thenAnswer((_) async {});
  when(() => m.getFrequentBarcodes(limit: any(named: 'limit')))
      .thenAnswer((_) async => []);
  when(() => m.recordScan(any())).thenAnswer((_) async {});
  return m;
}

PhotoStorageService buildTempPhotoStorage() {
  final d = Directory.systemTemp.createTempSync('hk_photo_');
  return PhotoStorageService(d);
}
