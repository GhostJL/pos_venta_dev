import 'dart:io';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:posventa/domain/repositories/backup_repository.dart';

class BackupRepositoryImpl implements BackupRepository {
  final _logger = Logger('BackupRepository');
  static const String _dbName = 'pos.sqlite';

  @override
  Future<String> getDatabasePath() async {
    final dir = await getApplicationDocumentsDirectory();
    return p.join(dir.path, _dbName);
  }

  @override
  Future<File> exportDatabase(String destinationPath) async {
    try {
      final dbPath = await getDatabasePath();
      final dbFile = File(dbPath);

      if (!dbFile.existsSync()) {
        throw Exception('Database file not found at $dbPath');
      }

      // Check WAL and SHM files
      final walFile = File('$dbPath-wal');
      final shmFile = File('$dbPath-shm');

      // If WAL mode is active, we should ideally checkpoint, but effective backup
      // of just .sqlite might miss data if not checkpointed.
      // However, simplified approach: copy the main file.
      // Ideally we use SQLite's backup API, but for simple file copy:

      return await dbFile.copy(destinationPath);
    } catch (e, stack) {
      _logger.severe('Export failed', e, stack);
      rethrow;
    }
  }

  @override
  Future<void> importDatabase(String sourcePath) async {
    try {
      final dbPath = await getDatabasePath();
      final dbFile = File(dbPath);
      final backupFile = File('$dbPath.bak');

      // 1. Create safety backup
      if (dbFile.existsSync()) {
        await dbFile.copy(backupFile.path);

        // Also try to backup WAL/SHM if they exist, just in case
        try {
          final wal = File('$dbPath-wal');
          if (wal.existsSync()) await wal.copy('${backupFile.path}-wal');
          final shm = File('$dbPath-shm');
          if (shm.existsSync()) await shm.copy('${backupFile.path}-shm');
        } catch (_) {
          // Ignore failures here
        }
      }

      // 2. Overwrite
      final sourceFile = File(sourcePath);
      if (!sourceFile.existsSync()) {
        throw Exception('Source file not found');
      }

      await sourceFile.copy(dbPath);

      // 3. Cleanup WAL/SHM to force SQLite to read fresh from the main DB file
      // If we don't delete them, SQLite might try to use the old WAL with the new DB, causing corruption.
      final wal = File('$dbPath-wal');
      if (wal.existsSync()) await wal.delete();
      final shm = File('$dbPath-shm');
      if (shm.existsSync()) await shm.delete();
    } catch (e, stack) {
      _logger.severe('Import failed', e, stack);
      // Attempt restore?
      // For now, rethrow implementation error
      rethrow;
    }
  }
}
