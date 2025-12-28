class ServerException implements Exception {
  final String message;
  ServerException(this.message);
}

class CacheException implements Exception {
  final String message;
  CacheException(this.message);
}

class DatasourceException implements Exception {
  final String message;
  DatasourceException(this.message);
}

class DatabaseException implements Exception {
  final String message;
  DatabaseException(this.message);
}

class DuplicateEntryException implements Exception {
  final String message;
  DuplicateEntryException(this.message);
}
