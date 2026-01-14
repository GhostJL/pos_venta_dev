import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

/// Service for managing organized file storage with date-based folder structure
class FileManagerService {
  /// Generates an organized path with year/month subdirectories
  ///
  /// Example: /base/path/2026/01/
  static String getOrganizedPath(String basePath, {DateTime? date}) {
    final targetDate = date ?? DateTime.now();
    final year = targetDate.year.toString();
    final month = targetDate.month.toString().padLeft(2, '0');

    return path.join(basePath, year, month);
  }

  /// Ensures a directory exists, creating it if necessary
  static Future<void> ensureDirectoryExists(String dirPath) async {
    final directory = Directory(dirPath);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
  }

  /// Generates a unique filename with timestamp
  ///
  /// Example: ticket_12345_20260114_002918.pdf
  static String generateFileName(
    String prefix,
    String extension, {
    String? identifier,
    DateTime? timestamp,
  }) {
    final now = timestamp ?? DateTime.now();
    final dateStr =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';

    final parts = <String>[prefix];
    if (identifier != null) {
      parts.add(identifier);
    }
    parts.add(dateStr);
    parts.add(timeStr);

    return '${parts.join('_')}.$extension';
  }

  /// Gets the default backup path for the current platform
  static Future<String> getDefaultBackupPath() async {
    if (Platform.isAndroid) {
      // On Android, use external storage if available
      try {
        final directory = await getExternalStorageDirectory();
        if (directory != null) {
          return path.join(directory.path, 'POS_Backups');
        }
      } catch (e) {
        // Fallback to app documents directory
      }
      final directory = await getApplicationDocumentsDirectory();
      return path.join(directory.path, 'backups');
    } else if (Platform.isIOS) {
      // On iOS, use documents directory
      final directory = await getApplicationDocumentsDirectory();
      return path.join(directory.path, 'backups');
    } else if (Platform.isWindows) {
      // On Windows, use Documents folder
      final directory = await getApplicationDocumentsDirectory();
      return path.join(directory.path, 'POS_Backups');
    } else if (Platform.isLinux || Platform.isMacOS) {
      // On Linux/macOS, use documents directory
      final directory = await getApplicationDocumentsDirectory();
      return path.join(directory.path, 'pos_backups');
    }

    // Fallback
    final directory = await getApplicationDocumentsDirectory();
    return path.join(directory.path, 'backups');
  }

  /// Gets the default PDF save path for the current platform
  static Future<String> getDefaultPdfSavePath() async {
    if (Platform.isAndroid) {
      // On Android, use external storage if available
      try {
        final directory = await getExternalStorageDirectory();
        if (directory != null) {
          return path.join(directory.path, 'POS_Receipts');
        }
      } catch (e) {
        // Fallback to app documents directory
      }
      final directory = await getApplicationDocumentsDirectory();
      return path.join(directory.path, 'receipts');
    } else if (Platform.isIOS) {
      // On iOS, use documents directory
      final directory = await getApplicationDocumentsDirectory();
      return path.join(directory.path, 'receipts');
    } else if (Platform.isWindows) {
      // On Windows, use Documents folder
      final directory = await getApplicationDocumentsDirectory();
      return path.join(directory.path, 'POS_Receipts');
    } else if (Platform.isLinux || Platform.isMacOS) {
      // On Linux/macOS, use documents directory
      final directory = await getApplicationDocumentsDirectory();
      return path.join(directory.path, 'pos_receipts');
    }

    // Fallback
    final directory = await getApplicationDocumentsDirectory();
    return path.join(directory.path, 'receipts');
  }

  /// Validates that a path is writable
  /// Returns true if the path exists and is writable, false otherwise
  static Future<bool> validatePath(String dirPath) async {
    try {
      final directory = Directory(dirPath);

      // Check if directory exists
      if (!await directory.exists()) {
        // Try to create it
        await directory.create(recursive: true);
      }

      // Try to write a test file
      final testFile = File(path.join(dirPath, '.write_test'));
      await testFile.writeAsString('test');
      await testFile.delete();

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Gets available disk space in bytes for a given path
  /// Returns null if unable to determine
  static Future<int?> getAvailableSpace(String dirPath) async {
    try {
      if (Platform.isAndroid || Platform.isLinux || Platform.isMacOS) {
        // Use df command on Unix-like systems
        final result = await Process.run('df', ['-k', dirPath]);
        if (result.exitCode == 0) {
          final lines = (result.stdout as String).split('\n');
          if (lines.length > 1) {
            final parts = lines[1].split(RegExp(r'\s+'));
            if (parts.length >= 4) {
              final availableKB = int.tryParse(parts[3]);
              if (availableKB != null) {
                return availableKB * 1024; // Convert to bytes
              }
            }
          }
        }
      } else if (Platform.isWindows) {
        // On Windows, we'd need to use platform channels or a package
        // For now, return null
        return null;
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  /// Formats bytes to human-readable string
  static String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
