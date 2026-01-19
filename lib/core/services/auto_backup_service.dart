import 'dart:async';
import 'dart:io';
import 'package:posventa/core/utils/file_manager_service.dart';
import 'package:posventa/domain/entities/app_settings.dart';
import 'package:posventa/domain/repositories/backup_repository.dart';
import 'package:posventa/core/error/error_reporter.dart';

/// Service for managing automatic backups based on configured schedules
class AutoBackupService {
  final BackupRepository _backupRepository;
  Timer? _checkTimer;
  DateTime? _lastBackupCheck;

  AutoBackupService(this._backupRepository);

  /// Initialize the automatic backup service with settings
  void initialize(AppSettings settings) {
    // Cancel any existing timer
    _checkTimer?.cancel();

    if (!settings.autoBackupEnabled || settings.autoBackupTimes.isEmpty) {
      AppErrorReporter().log('Auto backup disabled or no times configured');
      return;
    }

    AppErrorReporter().log(
      'Initializing auto backup with times: ${settings.autoBackupTimes}',
    );

    // Check every minute if it's time to backup
    _checkTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkAndExecuteBackup(settings);
    });

    // Also check immediately on initialization
    _checkAndExecuteBackup(settings);
  }

  /// Check if current time matches any configured backup time
  void _checkAndExecuteBackup(AppSettings settings) {
    final now = DateTime.now();
    final currentTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    // Avoid running backup multiple times in the same minute
    if (_lastBackupCheck != null &&
        _lastBackupCheck!.year == now.year &&
        _lastBackupCheck!.month == now.month &&
        _lastBackupCheck!.day == now.day &&
        _lastBackupCheck!.hour == now.hour &&
        _lastBackupCheck!.minute == now.minute) {
      return;
    }

    _lastBackupCheck = now;

    // Check if current time matches any configured backup time
    if (settings.autoBackupTimes.contains(currentTime)) {
      AppErrorReporter().log('Auto backup triggered at $currentTime');
      executeBackup(settings);
    }
  }

  /// Execute a backup
  Future<bool> executeBackup(AppSettings settings) async {
    try {
      AppErrorReporter().log('Executing automatic backup...');
      final baseBackupPath =
          settings.backupPath ??
          await FileManagerService.getDefaultBackupPath();

      // Organization: Backups/YYYY/MM/
      final organizedPath = FileManagerService.getOrganizedPath(
        baseBackupPath,
        category: 'Backups',
      );
      await FileManagerService.ensureDirectoryExists(organizedPath);

      // Filename: backup_YYYYMMDD_HHMMSS.sqlite
      final fileName = FileManagerService.generateFileName('backup', 'sqlite');

      final fullPath = '$organizedPath${Platform.pathSeparator}$fileName';

      await _backupRepository.exportDatabase(fullPath);

      AppErrorReporter().log('Automatic backup completed successfully');
      return true;
    } catch (e, stackTrace) {
      AppErrorReporter().reportError(
        e,
        stackTrace,
        context: 'AutoBackupService - executeBackup',
      );
      return false;
    }
  }

  /// Dispose and clean up resources
  void dispose() {
    _checkTimer?.cancel();
    _checkTimer = null;
  }
}
