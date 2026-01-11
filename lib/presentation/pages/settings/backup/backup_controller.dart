import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:posventa/presentation/providers/di/backup_di.dart';
import 'package:posventa/presentation/providers/di/core_di.dart';
// import 'package:share_plus/share_plus.dart'; // Unused

part 'backup_controller.g.dart';

@Riverpod(keepAlive: true)
class BackupController extends _$BackupController {
  @override
  FutureOr<void> build() {
    // Initial state is idle
  }

  Future<void> exportDatabase() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(backupRepositoryProvider);

      // Determine default filename with timestamp
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final filename = 'pos_backup_$timestamp.sqlite';

      // Pick location to save
      final String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Exportar Base de Datos',
        fileName: filename,
        type: FileType.any, // .sqlite might not be standard filter everywhere
      );

      if (outputFile == null) {
        // User canceled
        return;
      }

      await repository.exportDatabase(outputFile);
    });
  }

  Future<void> importDatabase() async {
    // Step 1: Pick file
    final FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result == null || result.files.isEmpty) return;

    final path = result.files.single.path;
    if (path == null) return;

    state = const AsyncValue.loading();

    try {
      final repository = ref.read(backupRepositoryProvider);

      // Force close database connection
      // We accept that this might cause errors if other async ops are running.
      // Ideally we invalidate the provider.
      ref.invalidate(appDatabaseProvider);

      await Future.delayed(const Duration(milliseconds: 500)); // Safety buffer

      // If the controller was disposed (e.g. page changed) during the waiting,
      // 'ref' might be invalid. But keeping it alive helps.

      await repository.importDatabase(path);

      // Success
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      // If controller is disposed, setting state throws, but with keepAlive it should be safe unless scope is disposed.
      // We can check if we are still mounted by just trying?
      // Actually Ref doesn't expose mounted in this version easily.
      // But since we are keepAlive, we should be fine.
      state = AsyncValue.error(e, stack);
    }
  }
}
