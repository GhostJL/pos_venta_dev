// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(InventoryNotifier)
const inventoryProvider = InventoryNotifierProvider._();

final class InventoryNotifierProvider
    extends $StreamNotifierProvider<InventoryNotifier, List<Inventory>> {
  const InventoryNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inventoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inventoryNotifierHash();

  @$internal
  @override
  InventoryNotifier create() => InventoryNotifier();
}

String _$inventoryNotifierHash() => r'b888b5f1b5373134d4468988c3b44cc4750d89ec';

abstract class _$InventoryNotifier extends $StreamNotifier<List<Inventory>> {
  Stream<List<Inventory>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<List<Inventory>>, List<Inventory>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Inventory>>, List<Inventory>>,
              AsyncValue<List<Inventory>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(inventoryByProduct)
const inventoryByProductProvider = InventoryByProductFamily._();

final class InventoryByProductProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Inventory>>,
          List<Inventory>,
          FutureOr<List<Inventory>>
        >
    with $FutureModifier<List<Inventory>>, $FutureProvider<List<Inventory>> {
  const InventoryByProductProvider._({
    required InventoryByProductFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'inventoryByProductProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$inventoryByProductHash();

  @override
  String toString() {
    return r'inventoryByProductProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Inventory>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Inventory>> create(Ref ref) {
    final argument = this.argument as int;
    return inventoryByProduct(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is InventoryByProductProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$inventoryByProductHash() =>
    r'63f8ca9574b3214ba6653d94189d36c3c7d9253c';

final class InventoryByProductFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Inventory>>, int> {
  const InventoryByProductFamily._()
    : super(
        retry: null,
        name: r'inventoryByProductProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  InventoryByProductProvider call(int productId) =>
      InventoryByProductProvider._(argument: productId, from: this);

  @override
  String toString() => r'inventoryByProductProvider';
}

@ProviderFor(products)
const productsProvider = ProductsProvider._();

final class ProductsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Product>>,
          List<Product>,
          FutureOr<List<Product>>
        >
    with $FutureModifier<List<Product>>, $FutureProvider<List<Product>> {
  const ProductsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'productsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$productsHash();

  @$internal
  @override
  $FutureProviderElement<List<Product>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Product>> create(Ref ref) {
    return products(ref);
  }
}

String _$productsHash() => r'4f8082162ab8c6db6ea40458f807b38355d3bf44';

@ProviderFor(warehouses)
const warehousesProvider = WarehousesProvider._();

final class WarehousesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Warehouse>>,
          List<Warehouse>,
          FutureOr<List<Warehouse>>
        >
    with $FutureModifier<List<Warehouse>>, $FutureProvider<List<Warehouse>> {
  const WarehousesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'warehousesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$warehousesHash();

  @$internal
  @override
  $FutureProviderElement<List<Warehouse>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Warehouse>> create(Ref ref) {
    return warehouses(ref);
  }
}

String _$warehousesHash() => r'f1d6b02782de0fea40a17fa18fc035c79bb33c58';
