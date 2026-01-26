// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_audit_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(InventoryAuditViewModel)
const inventoryAuditViewModelProvider = InventoryAuditViewModelProvider._();

final class InventoryAuditViewModelProvider
    extends
        $AsyncNotifierProvider<InventoryAuditViewModel, InventoryAuditEntity?> {
  const InventoryAuditViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inventoryAuditViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inventoryAuditViewModelHash();

  @$internal
  @override
  InventoryAuditViewModel create() => InventoryAuditViewModel();
}

String _$inventoryAuditViewModelHash() =>
    r'7981d7f3be876efee623278c39596721a92dd665';

abstract class _$InventoryAuditViewModel
    extends $AsyncNotifier<InventoryAuditEntity?> {
  FutureOr<InventoryAuditEntity?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<AsyncValue<InventoryAuditEntity?>, InventoryAuditEntity?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<InventoryAuditEntity?>,
                InventoryAuditEntity?
              >,
              AsyncValue<InventoryAuditEntity?>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(inventoryAuditList)
const inventoryAuditListProvider = InventoryAuditListProvider._();

final class InventoryAuditListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<InventoryAuditEntity>>,
          List<InventoryAuditEntity>,
          FutureOr<List<InventoryAuditEntity>>
        >
    with
        $FutureModifier<List<InventoryAuditEntity>>,
        $FutureProvider<List<InventoryAuditEntity>> {
  const InventoryAuditListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inventoryAuditListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inventoryAuditListHash();

  @$internal
  @override
  $FutureProviderElement<List<InventoryAuditEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<InventoryAuditEntity>> create(Ref ref) {
    return inventoryAuditList(ref);
  }
}

String _$inventoryAuditListHash() =>
    r'abdd07638600088b26b2d2c1700d3f2982e0d2da';
