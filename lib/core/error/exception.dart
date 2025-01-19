class LocalStorageException implements Exception {
  final String message;

  const LocalStorageException(this.message);
}

class ServerException implements Exception {
  final String message;

  const ServerException(this.message);
}