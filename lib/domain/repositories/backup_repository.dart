import 'dart:io';

abstract class BackupRepository {
  /// Gets the path of the current database file.
  Future<String> getDatabasePath();

  /// Exports the current database to the specified [destinationPath].
  Future<File> exportDatabase(String destinationPath);

  /// Creates a temporary backup file (encrypted).
  /// The caller is responsible for moving/reading this file and deleting it if necessary.
  Future<File> createBackupFile();

  /// Imports a database from [sourcePath], replacing the current one.
  Future<void> importDatabase(String sourcePath);
}
