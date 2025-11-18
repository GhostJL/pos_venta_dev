// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'warehouse_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(WarehouseNotifier)
const warehouseProvider = WarehouseNotifierProvider._();

final class WarehouseNotifierProvider
    extends $AsyncNotifierProvider<WarehouseNotifier, List<Warehouse>> {
  const WarehouseNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'warehouseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$warehouseNotifierHash();

  @$internal
  @override
  WarehouseNotifier create() => WarehouseNotifier();
}

String _$warehouseNotifierHash() => r'8edecb30f656f7903f0900e4504c4c86f0318ee7';

abstract class _$WarehouseNotifier extends $AsyncNotifier<List<Warehouse>> {
  FutureOr<List<Warehouse>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<List<Warehouse>>, List<Warehouse>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Warehouse>>, List<Warehouse>>,
              AsyncValue<List<Warehouse>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
