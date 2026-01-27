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
    r'124de69cead014e61fa5c9b7cc808c788cedcbcf';

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

@ProviderFor(QuickAuditState)
const quickAuditStateProvider = QuickAuditStateProvider._();

final class QuickAuditStateProvider
    extends $NotifierProvider<QuickAuditState, int> {
  const QuickAuditStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'quickAuditStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$quickAuditStateHash();

  @$internal
  @override
  QuickAuditState create() => QuickAuditState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$quickAuditStateHash() => r'2bd48920e76d83277da7c4da090e718571ff84d3';

abstract class _$QuickAuditState extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
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
