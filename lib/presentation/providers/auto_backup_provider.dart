import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/core/services/auto_backup_service.dart';
import 'package:posventa/presentation/providers/di/backup_di.dart';
import 'package:posventa/presentation/providers/settings_provider.dart';

/// Provider for the automatic backup service
final autoBackupServiceProvider = Provider<AutoBackupService>((ref) {
  final backupRepository = ref.watch(backupRepositoryProvider);
  return AutoBackupService(backupRepository);
});

/// Provider that initializes and manages the auto backup service
final autoBackupManagerProvider = Provider<void>((ref) {
  final autoBackupService = ref.watch(autoBackupServiceProvider);
  final settings = ref.watch(settingsProvider);

  settings.whenData((appSettings) {
    autoBackupService.initialize(appSettings);
  });

  // Clean up when provider is disposed
  ref.onDispose(() {
    autoBackupService.dispose();
  });
});
