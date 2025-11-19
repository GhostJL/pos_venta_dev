// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_movement_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(InventoryMovementNotifier)
const inventoryMovementProvider = InventoryMovementNotifierProvider._();

final class InventoryMovementNotifierProvider
    extends
        $AsyncNotifierProvider<
          InventoryMovementNotifier,
          List<InventoryMovement>
        > {
  const InventoryMovementNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inventoryMovementProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inventoryMovementNotifierHash();

  @$internal
  @override
  InventoryMovementNotifier create() => InventoryMovementNotifier();
}

String _$inventoryMovementNotifierHash() =>
    r'140891af3debe3e0299eea2da8c3495a6a655596';

abstract class _$InventoryMovementNotifier
    extends $AsyncNotifier<List<InventoryMovement>> {
  FutureOr<List<InventoryMovement>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<InventoryMovement>>,
              List<InventoryMovement>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<InventoryMovement>>,
                List<InventoryMovement>
              >,
              AsyncValue<List<InventoryMovement>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(movementsByProduct)
const movementsByProductProvider = MovementsByProductFamily._();

final class MovementsByProductProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<InventoryMovement>>,
          List<InventoryMovement>,
          FutureOr<List<InventoryMovement>>
        >
    with
        $FutureModifier<List<InventoryMovement>>,
        $FutureProvider<List<InventoryMovement>> {
  const MovementsByProductProvider._({
    required MovementsByProductFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'movementsByProductProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$movementsByProductHash();

  @override
  String toString() {
    return r'movementsByProductProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<InventoryMovement>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<InventoryMovement>> create(Ref ref) {
    final argument = this.argument as int;
    return movementsByProduct(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MovementsByProductProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$movementsByProductHash() =>
    r'90a4fa7f1c78175a20b0da9feea4c8a9359320e9';

final class MovementsByProductFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<InventoryMovement>>, int> {
  const MovementsByProductFamily._()
    : super(
        retry: null,
        name: r'movementsByProductProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  MovementsByProductProvider call(int productId) =>
      MovementsByProductProvider._(argument: productId, from: this);

  @override
  String toString() => r'movementsByProductProvider';
}

@ProviderFor(movementsByWarehouse)
const movementsByWarehouseProvider = MovementsByWarehouseFamily._();

final class MovementsByWarehouseProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<InventoryMovement>>,
          List<InventoryMovement>,
          FutureOr<List<InventoryMovement>>
        >
    with
        $FutureModifier<List<InventoryMovement>>,
        $FutureProvider<List<InventoryMovement>> {
  const MovementsByWarehouseProvider._({
    required MovementsByWarehouseFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'movementsByWarehouseProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$movementsByWarehouseHash();

  @override
  String toString() {
    return r'movementsByWarehouseProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<InventoryMovement>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<InventoryMovement>> create(Ref ref) {
    final argument = this.argument as int;
    return movementsByWarehouse(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MovementsByWarehouseProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$movementsByWarehouseHash() =>
    r'ce7639a55ee7d4f479954680f3dc0151dd3ded0b';

final class MovementsByWarehouseFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<InventoryMovement>>, int> {
  const MovementsByWarehouseFamily._()
    : super(
        retry: null,
        name: r'movementsByWarehouseProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  MovementsByWarehouseProvider call(int warehouseId) =>
      MovementsByWarehouseProvider._(argument: warehouseId, from: this);

  @override
  String toString() => r'movementsByWarehouseProvider';
}

@ProviderFor(movementsByDateRange)
const movementsByDateRangeProvider = MovementsByDateRangeFamily._();

final class MovementsByDateRangeProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<InventoryMovement>>,
          List<InventoryMovement>,
          FutureOr<List<InventoryMovement>>
        >
    with
        $FutureModifier<List<InventoryMovement>>,
        $FutureProvider<List<InventoryMovement>> {
  const MovementsByDateRangeProvider._({
    required MovementsByDateRangeFamily super.from,
    required ({DateTime startDate, DateTime endDate}) super.argument,
  }) : super(
         retry: null,
         name: r'movementsByDateRangeProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$movementsByDateRangeHash();

  @override
  String toString() {
    return r'movementsByDateRangeProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<InventoryMovement>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<InventoryMovement>> create(Ref ref) {
    final argument = this.argument as ({DateTime startDate, DateTime endDate});
    return movementsByDateRange(
      ref,
      startDate: argument.startDate,
      endDate: argument.endDate,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is MovementsByDateRangeProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$movementsByDateRangeHash() =>
    r'96d564e523f88ea04b6f755280985f4c546b4cad';

final class MovementsByDateRangeFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<InventoryMovement>>,
          ({DateTime startDate, DateTime endDate})
        > {
  const MovementsByDateRangeFamily._()
    : super(
        retry: null,
        name: r'movementsByDateRangeProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  MovementsByDateRangeProvider call({
    required DateTime startDate,
    required DateTime endDate,
  }) => MovementsByDateRangeProvider._(
    argument: (startDate: startDate, endDate: endDate),
    from: this,
  );

  @override
  String toString() => r'movementsByDateRangeProvider';
}
