import 'package:flutter_riverpod/legacy.dart';

enum BackupStatus { idle, loading, success, error }

class BackupState {
  final BackupStatus status;
  final String? message;
  final String? title;

  const BackupState({
    this.status = BackupStatus.idle,
    this.message,
    this.title,
  });

  BackupState copyWith({BackupStatus? status, String? message, String? title}) {
    return BackupState(
      status: status ?? this.status,
      message: message ?? this.message,
      title: title ?? this.title,
    );
  }
}

final isBackupInProgressProvider = StateProvider<bool>((ref) => false);
