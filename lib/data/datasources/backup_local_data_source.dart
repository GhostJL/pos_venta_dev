import 'dart:io';
import 'package:logging/logging.dart';
import 'package:posventa/core/security/encryption_service.dart';

abstract class BackupLocalDataSource {
  Future<void> exportDatabase(File dbFile, String destinationPath);
  Future<void> importDatabase(String sourcePath, File currentDbFile);
}

class BackupLocalDataSourceImpl implements BackupLocalDataSource {
  final EncryptionService _encryptionService;
  final _logger = Logger('BackupLocalDataSource');

  BackupLocalDataSourceImpl(this._encryptionService);

  @override
  Future<void> exportDatabase(File dbFile, String destinationPath) async {
    if (!dbFile.existsSync()) {
      throw Exception('Database file not found at ${dbFile.path}');
    }

    // Temporary copy of the DB to avoid locking issues during encryption if possible,
    // although direct read is usually fine for SQLite in WAL mode.
    // For safety and consistency (handling SHM/WAL integration), ideally we'd checkpoint.
    // But assuming we are just encrypting the .sqlite file:

    // Create destination file object
    final destFile = File(destinationPath);

    // Encrypt directly from source to destination
    await _encryptionService.encryptFile(dbFile, destFile);
    _logger.info('Database exported and encrypted to $destinationPath');
  }

  @override
  Future<void> importDatabase(String sourcePath, File currentDbFile) async {
    final sourceFile = File(sourcePath);
    if (!sourceFile.existsSync()) {
      throw Exception('Source file not found at $sourcePath');
    }

    // Decrypt to a temp file first to verify integrity
    final tempDir = Directory.systemTemp;
    final tempDecryptedFile = File(
      '${tempDir.path}/temp_restore_${DateTime.now().millisecondsSinceEpoch}.sqlite',
    );

    try {
      // 1. Decrypt
      await _encryptionService.decryptFile(sourceFile, tempDecryptedFile);

      // 2. Backup current DB (Safety)
      final backupFile = File('${currentDbFile.path}.bak');
      if (currentDbFile.existsSync()) {
        await currentDbFile.copy(backupFile.path);
        _tryBackupWalShm(currentDbFile.path, backupFile.path);
      }

      // 3. Replace current DB with Decrypted DB
      await tempDecryptedFile.copy(currentDbFile.path);

      // 4. Cleanup WAL/SHM to avoid corruption with new DB file
      final wal = File('${currentDbFile.path}-wal');
      if (wal.existsSync()) await wal.delete();
      final shm = File('${currentDbFile.path}-shm');
      if (shm.existsSync()) await shm.delete();
    } catch (e) {
      _logger.severe('Import failed', e);
      // Cleanup temp
      if (tempDecryptedFile.existsSync()) await tempDecryptedFile.delete();
      rethrow;
    } finally {
      if (tempDecryptedFile.existsSync()) await tempDecryptedFile.delete();
    }
  }

  Future<void> _tryBackupWalShm(String originalPath, String backupPath) async {
    try {
      final wal = File('$originalPath-wal');
      if (wal.existsSync()) await wal.copy('$backupPath-wal');
      final shm = File('$originalPath-shm');
      if (shm.existsSync()) await shm.copy('$backupPath-shm');
    } catch (_) {
      // Ignore aux file errors
    }
  }
}
