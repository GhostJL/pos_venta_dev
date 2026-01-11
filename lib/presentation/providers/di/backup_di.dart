import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:posventa/domain/repositories/backup_repository.dart';
import 'package:posventa/data/repositories/backup_repository_impl.dart';

part 'backup_di.g.dart';

@riverpod
BackupRepository backupRepository(ref) {
  return BackupRepositoryImpl();
}
