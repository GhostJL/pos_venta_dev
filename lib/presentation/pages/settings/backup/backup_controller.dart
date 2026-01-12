import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:posventa/presentation/providers/di/backup_di.dart';
import 'package:posventa/presentation/providers/di/core_di.dart';
import 'package:posventa/presentation/providers/backup_state_provider.dart';

part 'backup_controller.g.dart';

@Riverpod(keepAlive: true)
class BackupController extends _$BackupController {
  @override
  BackupState build() {
    return const BackupState();
  }

  Future<void> executeExport() async {
    state = const BackupState(
      status: BackupStatus.loading,
      message: 'Exportando base de datos...\nPor favor espere.',
    );

    File? tempFile;
    try {
      final repository = ref.read(backupRepositoryProvider);

      // 1. Generate encrypted backup file
      tempFile = await repository.createBackupFile();

      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final filename = 'pos_backup_$timestamp.sqlite';

      if (Platform.isAndroid || Platform.isIOS) {
        // Mobile: Must pass bytes to saveFile
        final bytes = await tempFile.readAsBytes();
        await FilePicker.platform.saveFile(
          dialogTitle: 'Exportar Base de Datos',
          fileName: filename,
          bytes: bytes,
          type: FileType.any,
        );
      } else {
        // Desktop: Get path then copy
        final outFile = await FilePicker.platform.saveFile(
          dialogTitle: 'Exportar Base de Datos',
          fileName: filename,
          type: FileType.any,
        );

        if (outFile == null) {
          // User cancelled
          state = const BackupState(status: BackupStatus.idle);
          return;
        }

        await tempFile.copy(outFile);
      }

      state = const BackupState(
        status: BackupStatus.success,
        title: 'Exportación Completa',
        message: 'La base de datos se ha exportado correctamente.',
      );
    } catch (e) {
      state = BackupState(status: BackupStatus.error, message: e.toString());
    } finally {
      // Cleanup temp file
      if (tempFile != null && await tempFile.exists()) {
        try {
          await tempFile.delete();
        } catch (_) {}
      }
    }
  }

  Future<String?> pickImportPath() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result == null || result.files.isEmpty) return null;
    return result.files.single.path;
  }

  Future<void> executeImport(String path) async {
    // 1. Set global flag for Guard
    ref.read(isBackupInProgressProvider.notifier).state = true;

    // 2. Update local state to loading
    state = const BackupState(
      status: BackupStatus.loading,
      message: 'Restaurando base de datos...\nEsto puede tardar unos momentos.',
    );

    // Allow UI to rebuild
    await Future.delayed(const Duration(milliseconds: 100));

    try {
      // 3. Close database
      try {
        await ref.read(appDatabaseProvider).close();
      } catch (e) {
        // Ignore close errors
      }

      await Future.delayed(const Duration(milliseconds: 500));

      // 4. Import
      final repository = ref.read(backupRepositoryProvider);
      await repository.importDatabase(path);

      // 5. Success
      state = const BackupState(
        status: BackupStatus.success,
        title: 'Restauración Completa',
        message:
            'La base de datos se ha restaurado correctamente. La aplicación se reiniciará.',
      );

      // Note: We intentionally leave isBackupInProgressProvider = true
      // until the user dismisses the success dialog and app restarts.
    } catch (e) {
      ref.read(isBackupInProgressProvider.notifier).state = false;
      state = BackupState(status: BackupStatus.error, message: e.toString());
    }
  }

  void resetState() {
    state = const BackupState(status: BackupStatus.idle);
  }

  void restartApp() {
    // This will trigger the Auth restart and Router redirect
    ref.invalidate(appDatabaseProvider);
    // Reset backup flag just in case, though app might reload
    ref.read(isBackupInProgressProvider.notifier).state = false;
  }
}
