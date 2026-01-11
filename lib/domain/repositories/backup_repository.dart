import 'dart:io';

abstract class BackupRepository {
  /// Gets the path of the current database file.
  Future<String> getDatabasePath();

  /// Exports the current database to the specified [destinationPath].
  Future<File> exportDatabase(String destinationPath);

  /// Imports a database from [sourcePath], replacing the current one.
  Future<void> importDatabase(String sourcePath);
}
