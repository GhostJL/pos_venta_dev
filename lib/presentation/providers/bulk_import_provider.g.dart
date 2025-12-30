// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bulk_import_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(BulkImport)
const bulkImportProvider = BulkImportProvider._();

final class BulkImportProvider
    extends $NotifierProvider<BulkImport, BulkImportState> {
  const BulkImportProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bulkImportProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bulkImportHash();

  @$internal
  @override
  BulkImport create() => BulkImport();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BulkImportState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BulkImportState>(value),
    );
  }
}

String _$bulkImportHash() => r'3ecd495c6f3bc0dee0c3b5fa4f6940109079f569';

abstract class _$BulkImport extends $Notifier<BulkImportState> {
  BulkImportState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<BulkImportState, BulkImportState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<BulkImportState, BulkImportState>,
              BulkImportState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
