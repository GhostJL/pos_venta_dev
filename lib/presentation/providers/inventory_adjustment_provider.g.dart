// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_adjustment_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(InventoryAdjustmentNotifier)
const inventoryAdjustmentProvider = InventoryAdjustmentNotifierProvider._();

final class InventoryAdjustmentNotifierProvider
    extends
        $NotifierProvider<InventoryAdjustmentNotifier, List<AdjustmentItem>> {
  const InventoryAdjustmentNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inventoryAdjustmentProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inventoryAdjustmentNotifierHash();

  @$internal
  @override
  InventoryAdjustmentNotifier create() => InventoryAdjustmentNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<AdjustmentItem> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<AdjustmentItem>>(value),
    );
  }
}

String _$inventoryAdjustmentNotifierHash() =>
    r'4e4ace0075fdad6c4122e8e93492a064fa9d7ac2';

abstract class _$InventoryAdjustmentNotifier
    extends $Notifier<List<AdjustmentItem>> {
  List<AdjustmentItem> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<List<AdjustmentItem>, List<AdjustmentItem>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<AdjustmentItem>, List<AdjustmentItem>>,
              List<AdjustmentItem>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
