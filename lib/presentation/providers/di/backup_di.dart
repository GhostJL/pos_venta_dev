import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:posventa/core/security/encryption_service.dart';
import 'package:posventa/data/datasources/backup_local_data_source.dart';
import 'package:posventa/presentation/providers/di/core_di.dart';
import 'package:posventa/domain/repositories/backup_repository.dart';
import 'package:posventa/data/repositories/backup_repository_impl.dart';

part 'backup_di.g.dart';

@riverpod
EncryptionService encryptionService(ref) {
  return EncryptionService();
}

@riverpod
BackupLocalDataSource backupLocalDataSource(ref) {
  final encryptionService = ref.watch(encryptionServiceProvider);
  return BackupLocalDataSourceImpl(encryptionService);
}

@riverpod
BackupRepository backupRepository(ref) {
  final dataSource = ref.watch(backupLocalDataSourceProvider);
  final database = ref.watch(appDatabaseProvider);
  return BackupRepositoryImpl(dataSource, database);
}
