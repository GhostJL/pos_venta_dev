// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backup_di.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(backupRepository)
const backupRepositoryProvider = BackupRepositoryProvider._();

final class BackupRepositoryProvider
    extends
        $FunctionalProvider<
          BackupRepository,
          BackupRepository,
          BackupRepository
        >
    with $Provider<BackupRepository> {
  const BackupRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'backupRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$backupRepositoryHash();

  @$internal
  @override
  $ProviderElement<BackupRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BackupRepository create(Ref ref) {
    return backupRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BackupRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BackupRepository>(value),
    );
  }
}

String _$backupRepositoryHash() => r'ae1ad5fb492fe5f84d4037da60b19891b7d022a7';
