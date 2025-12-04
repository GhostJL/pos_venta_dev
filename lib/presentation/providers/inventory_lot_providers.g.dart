// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_lot_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(inventoryLotRepository)
const inventoryLotRepositoryProvider = InventoryLotRepositoryProvider._();

final class InventoryLotRepositoryProvider
    extends
        $FunctionalProvider<
          InventoryLotRepository,
          InventoryLotRepository,
          InventoryLotRepository
        >
    with $Provider<InventoryLotRepository> {
  const InventoryLotRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inventoryLotRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inventoryLotRepositoryHash();

  @$internal
  @override
  $ProviderElement<InventoryLotRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  InventoryLotRepository create(Ref ref) {
    return inventoryLotRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InventoryLotRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InventoryLotRepository>(value),
    );
  }
}

String _$inventoryLotRepositoryHash() =>
    r'34533f51f2ae234796cb9ebeb857b05b26a9b615';

@ProviderFor(productLots)
const productLotsProvider = ProductLotsFamily._();

final class ProductLotsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<InventoryLot>>,
          List<InventoryLot>,
          FutureOr<List<InventoryLot>>
        >
    with
        $FutureModifier<List<InventoryLot>>,
        $FutureProvider<List<InventoryLot>> {
  const ProductLotsProvider._({
    required ProductLotsFamily super.from,
    required (int, int) super.argument,
  }) : super(
         retry: null,
         name: r'productLotsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$productLotsHash();

  @override
  String toString() {
    return r'productLotsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<InventoryLot>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<InventoryLot>> create(Ref ref) {
    final argument = this.argument as (int, int);
    return productLots(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is ProductLotsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$productLotsHash() => r'c16791be9e0fc6e34a3538ea0198d033670324b7';

final class ProductLotsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<InventoryLot>>, (int, int)> {
  const ProductLotsFamily._()
    : super(
        retry: null,
        name: r'productLotsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ProductLotsProvider call(int productId, int warehouseId) =>
      ProductLotsProvider._(argument: (productId, warehouseId), from: this);

  @override
  String toString() => r'productLotsProvider';
}

@ProviderFor(availableLots)
const availableLotsProvider = AvailableLotsFamily._();

final class AvailableLotsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<InventoryLot>>,
          List<InventoryLot>,
          FutureOr<List<InventoryLot>>
        >
    with
        $FutureModifier<List<InventoryLot>>,
        $FutureProvider<List<InventoryLot>> {
  const AvailableLotsProvider._({
    required AvailableLotsFamily super.from,
    required (int, int) super.argument,
  }) : super(
         retry: null,
         name: r'availableLotsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$availableLotsHash();

  @override
  String toString() {
    return r'availableLotsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<InventoryLot>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<InventoryLot>> create(Ref ref) {
    final argument = this.argument as (int, int);
    return availableLots(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is AvailableLotsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$availableLotsHash() => r'3dc59d6d7b0cf3256cd6d89737cf99841d01a968';

final class AvailableLotsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<InventoryLot>>, (int, int)> {
  const AvailableLotsFamily._()
    : super(
        retry: null,
        name: r'availableLotsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AvailableLotsProvider call(int productId, int warehouseId) =>
      AvailableLotsProvider._(argument: (productId, warehouseId), from: this);

  @override
  String toString() => r'availableLotsProvider';
}

@ProviderFor(lotById)
const lotByIdProvider = LotByIdFamily._();

final class LotByIdProvider
    extends
        $FunctionalProvider<
          AsyncValue<InventoryLot?>,
          InventoryLot?,
          FutureOr<InventoryLot?>
        >
    with $FutureModifier<InventoryLot?>, $FutureProvider<InventoryLot?> {
  const LotByIdProvider._({
    required LotByIdFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'lotByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$lotByIdHash();

  @override
  String toString() {
    return r'lotByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<InventoryLot?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<InventoryLot?> create(Ref ref) {
    final argument = this.argument as int;
    return lotById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is LotByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$lotByIdHash() => r'cefb9fa6b8d04866a2e33998f396d5462f67ab8b';

final class LotByIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<InventoryLot?>, int> {
  const LotByIdFamily._()
    : super(
        retry: null,
        name: r'lotByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  LotByIdProvider call(int lotId) =>
      LotByIdProvider._(argument: lotId, from: this);

  @override
  String toString() => r'lotByIdProvider';
}

@ProviderFor(expiringLots)
const expiringLotsProvider = ExpiringLotsFamily._();

final class ExpiringLotsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<InventoryLot>>,
          List<InventoryLot>,
          FutureOr<List<InventoryLot>>
        >
    with
        $FutureModifier<List<InventoryLot>>,
        $FutureProvider<List<InventoryLot>> {
  const ExpiringLotsProvider._({
    required ExpiringLotsFamily super.from,
    required (int, int) super.argument,
  }) : super(
         retry: null,
         name: r'expiringLotsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$expiringLotsHash();

  @override
  String toString() {
    return r'expiringLotsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<InventoryLot>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<InventoryLot>> create(Ref ref) {
    final argument = this.argument as (int, int);
    return expiringLots(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is ExpiringLotsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$expiringLotsHash() => r'fe6484e76eb704965d10ce276fd3ee58b0b9ae26';

final class ExpiringLotsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<InventoryLot>>, (int, int)> {
  const ExpiringLotsFamily._()
    : super(
        retry: null,
        name: r'expiringLotsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ExpiringLotsProvider call(int warehouseId, int withinDays) =>
      ExpiringLotsProvider._(argument: (warehouseId, withinDays), from: this);

  @override
  String toString() => r'expiringLotsProvider';
}

@ProviderFor(warehouseLots)
const warehouseLotsProvider = WarehouseLotsFamily._();

final class WarehouseLotsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<InventoryLot>>,
          List<InventoryLot>,
          FutureOr<List<InventoryLot>>
        >
    with
        $FutureModifier<List<InventoryLot>>,
        $FutureProvider<List<InventoryLot>> {
  const WarehouseLotsProvider._({
    required WarehouseLotsFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'warehouseLotsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$warehouseLotsHash();

  @override
  String toString() {
    return r'warehouseLotsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<InventoryLot>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<InventoryLot>> create(Ref ref) {
    final argument = this.argument as int;
    return warehouseLots(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WarehouseLotsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$warehouseLotsHash() => r'2f781fa3ab47a2a67bd04fc287fbf61d449b9f4b';

final class WarehouseLotsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<InventoryLot>>, int> {
  const WarehouseLotsFamily._()
    : super(
        retry: null,
        name: r'warehouseLotsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WarehouseLotsProvider call(int warehouseId) =>
      WarehouseLotsProvider._(argument: warehouseId, from: this);

  @override
  String toString() => r'warehouseLotsProvider';
}
