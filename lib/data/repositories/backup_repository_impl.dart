import 'dart:io';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:posventa/data/datasources/backup_local_data_source.dart';
import 'package:posventa/data/datasources/local/database/app_database.dart';
import 'package:posventa/domain/repositories/backup_repository.dart';

class BackupRepositoryImpl implements BackupRepository {
  final _logger = Logger('BackupRepository');
  final BackupLocalDataSource _dataSource;
  final AppDatabase _database;
  static const String _dbName = 'pos.sqlite';

  BackupRepositoryImpl(this._dataSource, this._database);

  @override
  Future<String> getDatabasePath() async {
    final dir = await getApplicationDocumentsDirectory();
    return p.join(dir.path, _dbName);
  }

  @override
  Future<File> exportDatabase(String destinationPath) async {
    File? tempSnapshot;
    try {
      // 1. Create a temp file path for the snapshot
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final snapshotPath = p.join(tempDir.path, 'snapshot_$timestamp.db');
      tempSnapshot = File(snapshotPath);

      // 2. Execute VACUUM INTO to create a consistent snapshot (includes WAL)
      // This works even while the DB is open and active
      await _database.customStatement('VACUUM INTO ?', [snapshotPath]);

      // 3. Encrypt the snapshot to the destination
      await _dataSource.exportDatabase(tempSnapshot, destinationPath);

      return File(destinationPath);
    } catch (e, stack) {
      _logger.severe('Export failed', e, stack);
      rethrow;
    } finally {
      // 4. Cleanup
      if (tempSnapshot != null && await tempSnapshot.exists()) {
        try {
          await tempSnapshot.delete();
        } catch (e) {
          _logger.warning('Failed to delete temp snapshot', e);
        }
      }
    }
  }

  @override
  Future<void> importDatabase(String sourcePath) async {
    try {
      final dbPath = await getDatabasePath();
      final dbFile = File(dbPath);

      await _dataSource.importDatabase(sourcePath, dbFile);
    } catch (e, stack) {
      _logger.severe('Import failed', e, stack);
      rethrow;
    }
  }
}
