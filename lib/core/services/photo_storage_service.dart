import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;

/// Salva JPEG ridimensionato sotto [root]; restituisce path **relativo** a [root].
class PhotoStorageService {
  PhotoStorageService(this.root);

  final Directory root;

  /// Salva da file picker/camera; max larghezza 800px, qualità 85.
  Future<String> saveProductPhotoFromFile(File source, String productId) async {
    final bytes = await source.readAsBytes();
    return saveProductPhotoFromBytes(bytes, productId);
  }

  /// Stessa logica di [saveProductPhotoFromFile], utile per Web / [XFile.readAsBytes].
  Future<String> saveProductPhotoFromBytes(
    Uint8List bytes,
    String productId,
  ) async {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw StateError('Immagine non decodificabile');
    }
    final w = decoded.width > 800 ? 800 : decoded.width;
    final resized = img.copyResize(decoded, width: w);
    final jpg = img.encodeJpg(resized, quality: 85);
    final sub = 'products';
    final dir = Directory(p.join(root.path, sub));
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    final name = '$productId.jpg';
    final outFile = File(p.join(dir.path, name));
    await outFile.writeAsBytes(jpg, flush: true);
    return p.join(sub, name);
  }

  File resolveFile(String relativePath) => File(p.join(root.path, relativePath));

  Future<void> deleteIfExists(String? relativePath) async {
    if (relativePath == null || relativePath.isEmpty) return;
    final f = resolveFile(relativePath);
    if (f.existsSync()) {
      await f.delete();
    }
  }
}
