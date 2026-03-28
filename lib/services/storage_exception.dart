/// Errore di dominio per fallimenti lettura/scrittura locale.
class StorageException implements Exception {
  StorageException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() =>
      cause != null ? 'StorageException: $message ($cause)' : 'StorageException: $message';
}
