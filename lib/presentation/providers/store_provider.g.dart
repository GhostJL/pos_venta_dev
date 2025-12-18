// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(StoreNotifier)
const storeProvider = StoreNotifierProvider._();

final class StoreNotifierProvider
    extends $AsyncNotifierProvider<StoreNotifier, Store?> {
  const StoreNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'storeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$storeNotifierHash();

  @$internal
  @override
  StoreNotifier create() => StoreNotifier();
}

String _$storeNotifierHash() => r'10f9bd7efce6c18d1af428b1175c67bb15c28ca5';

abstract class _$StoreNotifier extends $AsyncNotifier<Store?> {
  FutureOr<Store?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<Store?>, Store?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Store?>, Store?>,
              AsyncValue<Store?>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
