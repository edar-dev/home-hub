/// Base per errori di dominio / applicazione con messaggio user-facing.
class AppException implements Exception {
  AppException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() =>
      cause != null ? '$message ($cause)' : message;
}
