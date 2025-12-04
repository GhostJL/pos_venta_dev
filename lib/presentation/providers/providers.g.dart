// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(databaseHelper)
const databaseHelperProvider = DatabaseHelperProvider._();

final class DatabaseHelperProvider
    extends $FunctionalProvider<DatabaseHelper, DatabaseHelper, DatabaseHelper>
    with $Provider<DatabaseHelper> {
  const DatabaseHelperProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'databaseHelperProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$databaseHelperHash();

  @$internal
  @override
  $ProviderElement<DatabaseHelper> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DatabaseHelper create(Ref ref) {
    return databaseHelper(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DatabaseHelper value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DatabaseHelper>(value),
    );
  }
}

String _$databaseHelperHash() => r'4d8f44f034cca2afca8cfb05114be3ccb645e0ef';

@ProviderFor(warehouseRepository)
const warehouseRepositoryProvider = WarehouseRepositoryProvider._();

final class WarehouseRepositoryProvider
    extends
        $FunctionalProvider<
          WarehouseRepository,
          WarehouseRepository,
          WarehouseRepository
        >
    with $Provider<WarehouseRepository> {
  const WarehouseRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'warehouseRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$warehouseRepositoryHash();

  @$internal
  @override
  $ProviderElement<WarehouseRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  WarehouseRepository create(Ref ref) {
    return warehouseRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WarehouseRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WarehouseRepository>(value),
    );
  }
}

String _$warehouseRepositoryHash() =>
    r'0445df20c5f82dc07c45291169519f5bf3f49924';

@ProviderFor(getAllWarehouses)
const getAllWarehousesProvider = GetAllWarehousesProvider._();

final class GetAllWarehousesProvider
    extends
        $FunctionalProvider<
          GetAllWarehouses,
          GetAllWarehouses,
          GetAllWarehouses
        >
    with $Provider<GetAllWarehouses> {
  const GetAllWarehousesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getAllWarehousesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getAllWarehousesHash();

  @$internal
  @override
  $ProviderElement<GetAllWarehouses> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GetAllWarehouses create(Ref ref) {
    return getAllWarehouses(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetAllWarehouses value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetAllWarehouses>(value),
    );
  }
}

String _$getAllWarehousesHash() => r'e446a7deb39b7a24422846a85a983bbf54db2a1e';

@ProviderFor(createWarehouse)
const createWarehouseProvider = CreateWarehouseProvider._();

final class CreateWarehouseProvider
    extends
        $FunctionalProvider<CreateWarehouse, CreateWarehouse, CreateWarehouse>
    with $Provider<CreateWarehouse> {
  const CreateWarehouseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createWarehouseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createWarehouseHash();

  @$internal
  @override
  $ProviderElement<CreateWarehouse> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CreateWarehouse create(Ref ref) {
    return createWarehouse(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreateWarehouse value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreateWarehouse>(value),
    );
  }
}

String _$createWarehouseHash() => r'e2453ba1e77cf7bf5afb2a8cb48e7891917ca483';

@ProviderFor(updateWarehouse)
const updateWarehouseProvider = UpdateWarehouseProvider._();

final class UpdateWarehouseProvider
    extends
        $FunctionalProvider<UpdateWarehouse, UpdateWarehouse, UpdateWarehouse>
    with $Provider<UpdateWarehouse> {
  const UpdateWarehouseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updateWarehouseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updateWarehouseHash();

  @$internal
  @override
  $ProviderElement<UpdateWarehouse> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UpdateWarehouse create(Ref ref) {
    return updateWarehouse(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpdateWarehouse value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpdateWarehouse>(value),
    );
  }
}

String _$updateWarehouseHash() => r'ed70bdc1282e7308eaf0846bd9b5008ec7112042';

@ProviderFor(deleteWarehouse)
const deleteWarehouseProvider = DeleteWarehouseProvider._();

final class DeleteWarehouseProvider
    extends
        $FunctionalProvider<DeleteWarehouse, DeleteWarehouse, DeleteWarehouse>
    with $Provider<DeleteWarehouse> {
  const DeleteWarehouseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deleteWarehouseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deleteWarehouseHash();

  @$internal
  @override
  $ProviderElement<DeleteWarehouse> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DeleteWarehouse create(Ref ref) {
    return deleteWarehouse(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeleteWarehouse value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeleteWarehouse>(value),
    );
  }
}

String _$deleteWarehouseHash() => r'ff886f51aaaa27cac0f986e339c5425f50726be8';

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
    r'10df6387d3eeeb5945e6990d9bd4945b84b5f8d0';

@ProviderFor(inventoryRepository)
const inventoryRepositoryProvider = InventoryRepositoryProvider._();

final class InventoryRepositoryProvider
    extends
        $FunctionalProvider<
          InventoryRepository,
          InventoryRepository,
          InventoryRepository
        >
    with $Provider<InventoryRepository> {
  const InventoryRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inventoryRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inventoryRepositoryHash();

  @$internal
  @override
  $ProviderElement<InventoryRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  InventoryRepository create(Ref ref) {
    return inventoryRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InventoryRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InventoryRepository>(value),
    );
  }
}

String _$inventoryRepositoryHash() =>
    r'c3863d46bed234cab2dc5b4f269d6df1b7c0a757';

@ProviderFor(getAllInventory)
const getAllInventoryProvider = GetAllInventoryProvider._();

final class GetAllInventoryProvider
    extends
        $FunctionalProvider<GetAllInventory, GetAllInventory, GetAllInventory>
    with $Provider<GetAllInventory> {
  const GetAllInventoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getAllInventoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getAllInventoryHash();

  @$internal
  @override
  $ProviderElement<GetAllInventory> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GetAllInventory create(Ref ref) {
    return getAllInventory(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetAllInventory value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetAllInventory>(value),
    );
  }
}

String _$getAllInventoryHash() => r'63d984d40c5f6da707dd39b43e6b86a56a30f5fc';

@ProviderFor(createInventory)
const createInventoryProvider = CreateInventoryProvider._();

final class CreateInventoryProvider
    extends
        $FunctionalProvider<CreateInventory, CreateInventory, CreateInventory>
    with $Provider<CreateInventory> {
  const CreateInventoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createInventoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createInventoryHash();

  @$internal
  @override
  $ProviderElement<CreateInventory> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CreateInventory create(Ref ref) {
    return createInventory(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreateInventory value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreateInventory>(value),
    );
  }
}

String _$createInventoryHash() => r'666d34631d416ba3778ff6227cff9782e2bed5b5';

@ProviderFor(updateInventory)
const updateInventoryProvider = UpdateInventoryProvider._();

final class UpdateInventoryProvider
    extends
        $FunctionalProvider<UpdateInventory, UpdateInventory, UpdateInventory>
    with $Provider<UpdateInventory> {
  const UpdateInventoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updateInventoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updateInventoryHash();

  @$internal
  @override
  $ProviderElement<UpdateInventory> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UpdateInventory create(Ref ref) {
    return updateInventory(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpdateInventory value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpdateInventory>(value),
    );
  }
}

String _$updateInventoryHash() => r'327da91d31bed8308fbc4455da2f680016a89e25';

@ProviderFor(deleteInventory)
const deleteInventoryProvider = DeleteInventoryProvider._();

final class DeleteInventoryProvider
    extends
        $FunctionalProvider<DeleteInventory, DeleteInventory, DeleteInventory>
    with $Provider<DeleteInventory> {
  const DeleteInventoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deleteInventoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deleteInventoryHash();

  @$internal
  @override
  $ProviderElement<DeleteInventory> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DeleteInventory create(Ref ref) {
    return deleteInventory(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeleteInventory value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeleteInventory>(value),
    );
  }
}

String _$deleteInventoryHash() => r'a229bf00707b08639fcb0ecf71999551160726e5';

@ProviderFor(getInventoryByProduct)
const getInventoryByProductProvider = GetInventoryByProductProvider._();

final class GetInventoryByProductProvider
    extends
        $FunctionalProvider<
          GetInventoryByProduct,
          GetInventoryByProduct,
          GetInventoryByProduct
        >
    with $Provider<GetInventoryByProduct> {
  const GetInventoryByProductProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getInventoryByProductProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getInventoryByProductHash();

  @$internal
  @override
  $ProviderElement<GetInventoryByProduct> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetInventoryByProduct create(Ref ref) {
    return getInventoryByProduct(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetInventoryByProduct value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetInventoryByProduct>(value),
    );
  }
}

String _$getInventoryByProductHash() =>
    r'fbac78c7ac55ec962f3c22e2cae76d2652d0f046';

@ProviderFor(unitOfMeasureRepository)
const unitOfMeasureRepositoryProvider = UnitOfMeasureRepositoryProvider._();

final class UnitOfMeasureRepositoryProvider
    extends
        $FunctionalProvider<
          UnitOfMeasureRepository,
          UnitOfMeasureRepository,
          UnitOfMeasureRepository
        >
    with $Provider<UnitOfMeasureRepository> {
  const UnitOfMeasureRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'unitOfMeasureRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$unitOfMeasureRepositoryHash();

  @$internal
  @override
  $ProviderElement<UnitOfMeasureRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  UnitOfMeasureRepository create(Ref ref) {
    return unitOfMeasureRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UnitOfMeasureRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UnitOfMeasureRepository>(value),
    );
  }
}

String _$unitOfMeasureRepositoryHash() =>
    r'8d195a40e2442b5efb5dbf42bf47b14c38161d7f';

@ProviderFor(unitList)
const unitListProvider = UnitListProvider._();

final class UnitListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<UnitOfMeasure>>,
          List<UnitOfMeasure>,
          FutureOr<List<UnitOfMeasure>>
        >
    with
        $FutureModifier<List<UnitOfMeasure>>,
        $FutureProvider<List<UnitOfMeasure>> {
  const UnitListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'unitListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$unitListHash();

  @$internal
  @override
  $FutureProviderElement<List<UnitOfMeasure>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<UnitOfMeasure>> create(Ref ref) {
    return unitList(ref);
  }
}

String _$unitListHash() => r'9cdd6ca6c9018e567a7a0a83abb16947514d8b92';

@ProviderFor(productRepository)
const productRepositoryProvider = ProductRepositoryProvider._();

final class ProductRepositoryProvider
    extends
        $FunctionalProvider<
          ProductRepository,
          ProductRepository,
          ProductRepository
        >
    with $Provider<ProductRepository> {
  const ProductRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'productRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$productRepositoryHash();

  @$internal
  @override
  $ProviderElement<ProductRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProductRepository create(Ref ref) {
    return productRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProductRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProductRepository>(value),
    );
  }
}

String _$productRepositoryHash() => r'b51564a0778ce901e0f1f141b2080754ea386fb8';

@ProviderFor(getAllProducts)
const getAllProductsProvider = GetAllProductsProvider._();

final class GetAllProductsProvider
    extends $FunctionalProvider<GetAllProducts, GetAllProducts, GetAllProducts>
    with $Provider<GetAllProducts> {
  const GetAllProductsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getAllProductsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getAllProductsHash();

  @$internal
  @override
  $ProviderElement<GetAllProducts> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GetAllProducts create(Ref ref) {
    return getAllProducts(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetAllProducts value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetAllProducts>(value),
    );
  }
}

String _$getAllProductsHash() => r'c3ac952cc908ae400e33b23c535dfe98f4e68d5a';

@ProviderFor(createProduct)
const createProductProvider = CreateProductProvider._();

final class CreateProductProvider
    extends $FunctionalProvider<CreateProduct, CreateProduct, CreateProduct>
    with $Provider<CreateProduct> {
  const CreateProductProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createProductProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createProductHash();

  @$internal
  @override
  $ProviderElement<CreateProduct> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CreateProduct create(Ref ref) {
    return createProduct(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreateProduct value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreateProduct>(value),
    );
  }
}

String _$createProductHash() => r'fc7b2830886a8f75cebcde18247df99c52ffebaa';

@ProviderFor(updateProduct)
const updateProductProvider = UpdateProductProvider._();

final class UpdateProductProvider
    extends $FunctionalProvider<UpdateProduct, UpdateProduct, UpdateProduct>
    with $Provider<UpdateProduct> {
  const UpdateProductProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updateProductProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updateProductHash();

  @$internal
  @override
  $ProviderElement<UpdateProduct> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UpdateProduct create(Ref ref) {
    return updateProduct(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpdateProduct value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpdateProduct>(value),
    );
  }
}

String _$updateProductHash() => r'550cf10a8a4919fd361dacc938307517f851497f';

@ProviderFor(deleteProduct)
const deleteProductProvider = DeleteProductProvider._();

final class DeleteProductProvider
    extends $FunctionalProvider<DeleteProduct, DeleteProduct, DeleteProduct>
    with $Provider<DeleteProduct> {
  const DeleteProductProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deleteProductProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deleteProductHash();

  @$internal
  @override
  $ProviderElement<DeleteProduct> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DeleteProduct create(Ref ref) {
    return deleteProduct(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeleteProduct value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeleteProduct>(value),
    );
  }
}

String _$deleteProductHash() => r'5850111edda5cac19ef54114f99d4d2be5fcd6a4';

@ProviderFor(searchProducts)
const searchProductsProvider = SearchProductsProvider._();

final class SearchProductsProvider
    extends $FunctionalProvider<SearchProducts, SearchProducts, SearchProducts>
    with $Provider<SearchProducts> {
  const SearchProductsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchProductsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchProductsHash();

  @$internal
  @override
  $ProviderElement<SearchProducts> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SearchProducts create(Ref ref) {
    return searchProducts(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SearchProducts value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SearchProducts>(value),
    );
  }
}

String _$searchProductsHash() => r'e7a0bddb97037d8060018ebe2cf71717022599bf';

@ProviderFor(inventoryMovementRepository)
const inventoryMovementRepositoryProvider =
    InventoryMovementRepositoryProvider._();

final class InventoryMovementRepositoryProvider
    extends
        $FunctionalProvider<
          InventoryMovementRepository,
          InventoryMovementRepository,
          InventoryMovementRepository
        >
    with $Provider<InventoryMovementRepository> {
  const InventoryMovementRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inventoryMovementRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inventoryMovementRepositoryHash();

  @$internal
  @override
  $ProviderElement<InventoryMovementRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  InventoryMovementRepository create(Ref ref) {
    return inventoryMovementRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InventoryMovementRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InventoryMovementRepository>(value),
    );
  }
}

String _$inventoryMovementRepositoryHash() =>
    r'460bf1060744dfeccb272e2a0cd53d62b9119b3d';

@ProviderFor(getAllInventoryMovements)
const getAllInventoryMovementsProvider = GetAllInventoryMovementsProvider._();

final class GetAllInventoryMovementsProvider
    extends
        $FunctionalProvider<
          GetAllInventoryMovements,
          GetAllInventoryMovements,
          GetAllInventoryMovements
        >
    with $Provider<GetAllInventoryMovements> {
  const GetAllInventoryMovementsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getAllInventoryMovementsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getAllInventoryMovementsHash();

  @$internal
  @override
  $ProviderElement<GetAllInventoryMovements> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetAllInventoryMovements create(Ref ref) {
    return getAllInventoryMovements(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetAllInventoryMovements value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetAllInventoryMovements>(value),
    );
  }
}

String _$getAllInventoryMovementsHash() =>
    r'0741fe0c847a92d78c322083a6f500d5092918f1';

@ProviderFor(createInventoryMovement)
const createInventoryMovementProvider = CreateInventoryMovementProvider._();

final class CreateInventoryMovementProvider
    extends
        $FunctionalProvider<
          CreateInventoryMovement,
          CreateInventoryMovement,
          CreateInventoryMovement
        >
    with $Provider<CreateInventoryMovement> {
  const CreateInventoryMovementProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createInventoryMovementProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createInventoryMovementHash();

  @$internal
  @override
  $ProviderElement<CreateInventoryMovement> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CreateInventoryMovement create(Ref ref) {
    return createInventoryMovement(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreateInventoryMovement value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreateInventoryMovement>(value),
    );
  }
}

String _$createInventoryMovementHash() =>
    r'9892926c6f672a0c8e8eb5820ffb2a6aa12733d2';

@ProviderFor(updateInventoryMovement)
const updateInventoryMovementProvider = UpdateInventoryMovementProvider._();

final class UpdateInventoryMovementProvider
    extends
        $FunctionalProvider<
          UpdateInventoryMovement,
          UpdateInventoryMovement,
          UpdateInventoryMovement
        >
    with $Provider<UpdateInventoryMovement> {
  const UpdateInventoryMovementProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updateInventoryMovementProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updateInventoryMovementHash();

  @$internal
  @override
  $ProviderElement<UpdateInventoryMovement> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  UpdateInventoryMovement create(Ref ref) {
    return updateInventoryMovement(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpdateInventoryMovement value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpdateInventoryMovement>(value),
    );
  }
}

String _$updateInventoryMovementHash() =>
    r'ed8ba72410737ef3aea4c8b1e8a2c5dd029b6b46';

@ProviderFor(deleteInventoryMovement)
const deleteInventoryMovementProvider = DeleteInventoryMovementProvider._();

final class DeleteInventoryMovementProvider
    extends
        $FunctionalProvider<
          DeleteInventoryMovement,
          DeleteInventoryMovement,
          DeleteInventoryMovement
        >
    with $Provider<DeleteInventoryMovement> {
  const DeleteInventoryMovementProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deleteInventoryMovementProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deleteInventoryMovementHash();

  @$internal
  @override
  $ProviderElement<DeleteInventoryMovement> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DeleteInventoryMovement create(Ref ref) {
    return deleteInventoryMovement(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeleteInventoryMovement value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeleteInventoryMovement>(value),
    );
  }
}

String _$deleteInventoryMovementHash() =>
    r'1342e29e5fc1dfdb0a4bbcb76e52e7da81dfce35';

@ProviderFor(getInventoryMovementsByProduct)
const getInventoryMovementsByProductProvider =
    GetInventoryMovementsByProductProvider._();

final class GetInventoryMovementsByProductProvider
    extends
        $FunctionalProvider<
          GetInventoryMovementsByProduct,
          GetInventoryMovementsByProduct,
          GetInventoryMovementsByProduct
        >
    with $Provider<GetInventoryMovementsByProduct> {
  const GetInventoryMovementsByProductProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getInventoryMovementsByProductProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getInventoryMovementsByProductHash();

  @$internal
  @override
  $ProviderElement<GetInventoryMovementsByProduct> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetInventoryMovementsByProduct create(Ref ref) {
    return getInventoryMovementsByProduct(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetInventoryMovementsByProduct value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetInventoryMovementsByProduct>(
        value,
      ),
    );
  }
}

String _$getInventoryMovementsByProductHash() =>
    r'724847c12bd374da1dc2e97c51c0eb82ee883fe1';

@ProviderFor(getInventoryMovementsByWarehouse)
const getInventoryMovementsByWarehouseProvider =
    GetInventoryMovementsByWarehouseProvider._();

final class GetInventoryMovementsByWarehouseProvider
    extends
        $FunctionalProvider<
          GetInventoryMovementsByWarehouse,
          GetInventoryMovementsByWarehouse,
          GetInventoryMovementsByWarehouse
        >
    with $Provider<GetInventoryMovementsByWarehouse> {
  const GetInventoryMovementsByWarehouseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getInventoryMovementsByWarehouseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getInventoryMovementsByWarehouseHash();

  @$internal
  @override
  $ProviderElement<GetInventoryMovementsByWarehouse> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetInventoryMovementsByWarehouse create(Ref ref) {
    return getInventoryMovementsByWarehouse(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetInventoryMovementsByWarehouse value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetInventoryMovementsByWarehouse>(
        value,
      ),
    );
  }
}

String _$getInventoryMovementsByWarehouseHash() =>
    r'97bf413ae95ebf3a4943f1de8bd64f322704dfb9';

@ProviderFor(getInventoryMovementsByDateRange)
const getInventoryMovementsByDateRangeProvider =
    GetInventoryMovementsByDateRangeProvider._();

final class GetInventoryMovementsByDateRangeProvider
    extends
        $FunctionalProvider<
          GetInventoryMovementsByDateRange,
          GetInventoryMovementsByDateRange,
          GetInventoryMovementsByDateRange
        >
    with $Provider<GetInventoryMovementsByDateRange> {
  const GetInventoryMovementsByDateRangeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getInventoryMovementsByDateRangeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getInventoryMovementsByDateRangeHash();

  @$internal
  @override
  $ProviderElement<GetInventoryMovementsByDateRange> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetInventoryMovementsByDateRange create(Ref ref) {
    return getInventoryMovementsByDateRange(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetInventoryMovementsByDateRange value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetInventoryMovementsByDateRange>(
        value,
      ),
    );
  }
}

String _$getInventoryMovementsByDateRangeHash() =>
    r'b2b6d81024167c492e0952d2e59dcfd18a3e6cc0';

@ProviderFor(userRepository)
const userRepositoryProvider = UserRepositoryProvider._();

final class UserRepositoryProvider
    extends $FunctionalProvider<UserRepository, UserRepository, UserRepository>
    with $Provider<UserRepository> {
  const UserRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userRepositoryHash();

  @$internal
  @override
  $ProviderElement<UserRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UserRepository create(Ref ref) {
    return userRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserRepository>(value),
    );
  }
}

String _$userRepositoryHash() => r'300cb71d0b47bbe8549c1eaae7751c31efb7cc1f';

@ProviderFor(getAllUsers)
const getAllUsersProvider = GetAllUsersProvider._();

final class GetAllUsersProvider
    extends $FunctionalProvider<GetAllUsers, GetAllUsers, GetAllUsers>
    with $Provider<GetAllUsers> {
  const GetAllUsersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getAllUsersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getAllUsersHash();

  @$internal
  @override
  $ProviderElement<GetAllUsers> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GetAllUsers create(Ref ref) {
    return getAllUsers(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetAllUsers value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetAllUsers>(value),
    );
  }
}

String _$getAllUsersHash() => r'b305a9a9ca0f8d24052387567486e00ecd04fafe';

@ProviderFor(createUser)
const createUserProvider = CreateUserProvider._();

final class CreateUserProvider
    extends $FunctionalProvider<CreateUser, CreateUser, CreateUser>
    with $Provider<CreateUser> {
  const CreateUserProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createUserProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createUserHash();

  @$internal
  @override
  $ProviderElement<CreateUser> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CreateUser create(Ref ref) {
    return createUser(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreateUser value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreateUser>(value),
    );
  }
}

String _$createUserHash() => r'165a6032bcf8510db7f794aa287d2c6b35c810c8';

@ProviderFor(updateUser)
const updateUserProvider = UpdateUserProvider._();

final class UpdateUserProvider
    extends $FunctionalProvider<UpdateUser, UpdateUser, UpdateUser>
    with $Provider<UpdateUser> {
  const UpdateUserProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updateUserProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updateUserHash();

  @$internal
  @override
  $ProviderElement<UpdateUser> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UpdateUser create(Ref ref) {
    return updateUser(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpdateUser value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpdateUser>(value),
    );
  }
}

String _$updateUserHash() => r'662689f7e09c3417995a673e8b5ab2ec9d2ac4b2';

@ProviderFor(deleteUser)
const deleteUserProvider = DeleteUserProvider._();

final class DeleteUserProvider
    extends $FunctionalProvider<DeleteUser, DeleteUser, DeleteUser>
    with $Provider<DeleteUser> {
  const DeleteUserProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deleteUserProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deleteUserHash();

  @$internal
  @override
  $ProviderElement<DeleteUser> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DeleteUser create(Ref ref) {
    return deleteUser(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeleteUser value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeleteUser>(value),
    );
  }
}

String _$deleteUserHash() => r'75ab4530a0645fe2c2ac76bc69aa750a11d1259b';

@ProviderFor(hasUsersUseCase)
const hasUsersUseCaseProvider = HasUsersUseCaseProvider._();

final class HasUsersUseCaseProvider
    extends
        $FunctionalProvider<HasUsersUseCase, HasUsersUseCase, HasUsersUseCase>
    with $Provider<HasUsersUseCase> {
  const HasUsersUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hasUsersUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hasUsersUseCaseHash();

  @$internal
  @override
  $ProviderElement<HasUsersUseCase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  HasUsersUseCase create(Ref ref) {
    return hasUsersUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HasUsersUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HasUsersUseCase>(value),
    );
  }
}

String _$hasUsersUseCaseHash() => r'207dd61e8ac2406bdd7ca4ad578e88a6e3e01190';

@ProviderFor(permissionRepository)
const permissionRepositoryProvider = PermissionRepositoryProvider._();

final class PermissionRepositoryProvider
    extends
        $FunctionalProvider<
          PermissionRepository,
          PermissionRepository,
          PermissionRepository
        >
    with $Provider<PermissionRepository> {
  const PermissionRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'permissionRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$permissionRepositoryHash();

  @$internal
  @override
  $ProviderElement<PermissionRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PermissionRepository create(Ref ref) {
    return permissionRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PermissionRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PermissionRepository>(value),
    );
  }
}

String _$permissionRepositoryHash() =>
    r'ba1c758a97fb68c62d3fb8cb39a419ba963207b6';

@ProviderFor(userPermissionRepository)
const userPermissionRepositoryProvider = UserPermissionRepositoryProvider._();

final class UserPermissionRepositoryProvider
    extends
        $FunctionalProvider<
          UserPermissionRepository,
          UserPermissionRepository,
          UserPermissionRepository
        >
    with $Provider<UserPermissionRepository> {
  const UserPermissionRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userPermissionRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userPermissionRepositoryHash();

  @$internal
  @override
  $ProviderElement<UserPermissionRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  UserPermissionRepository create(Ref ref) {
    return userPermissionRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserPermissionRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserPermissionRepository>(value),
    );
  }
}

String _$userPermissionRepositoryHash() =>
    r'3b50fb2bb73cd2a79830430308a50f30b42a767f';

@ProviderFor(customerRepository)
const customerRepositoryProvider = CustomerRepositoryProvider._();

final class CustomerRepositoryProvider
    extends
        $FunctionalProvider<
          CustomerRepository,
          CustomerRepository,
          CustomerRepository
        >
    with $Provider<CustomerRepository> {
  const CustomerRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'customerRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$customerRepositoryHash();

  @$internal
  @override
  $ProviderElement<CustomerRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CustomerRepository create(Ref ref) {
    return customerRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CustomerRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CustomerRepository>(value),
    );
  }
}

String _$customerRepositoryHash() =>
    r'207d95ed89ced8e81d9e6099e7501c24e52a2303';

@ProviderFor(getCustomersUseCase)
const getCustomersUseCaseProvider = GetCustomersUseCaseProvider._();

final class GetCustomersUseCaseProvider
    extends
        $FunctionalProvider<
          GetCustomersUseCase,
          GetCustomersUseCase,
          GetCustomersUseCase
        >
    with $Provider<GetCustomersUseCase> {
  const GetCustomersUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getCustomersUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getCustomersUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetCustomersUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetCustomersUseCase create(Ref ref) {
    return getCustomersUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetCustomersUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetCustomersUseCase>(value),
    );
  }
}

String _$getCustomersUseCaseHash() =>
    r'90e6692db28342d15d0acc8c2993305b1c6aa4b2';

@ProviderFor(createCustomerUseCase)
const createCustomerUseCaseProvider = CreateCustomerUseCaseProvider._();

final class CreateCustomerUseCaseProvider
    extends
        $FunctionalProvider<
          CreateCustomerUseCase,
          CreateCustomerUseCase,
          CreateCustomerUseCase
        >
    with $Provider<CreateCustomerUseCase> {
  const CreateCustomerUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createCustomerUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createCustomerUseCaseHash();

  @$internal
  @override
  $ProviderElement<CreateCustomerUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CreateCustomerUseCase create(Ref ref) {
    return createCustomerUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreateCustomerUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreateCustomerUseCase>(value),
    );
  }
}

String _$createCustomerUseCaseHash() =>
    r'575e0c8ffc914f30f8b8429af65ceacf4f322c11';

@ProviderFor(updateCustomerUseCase)
const updateCustomerUseCaseProvider = UpdateCustomerUseCaseProvider._();

final class UpdateCustomerUseCaseProvider
    extends
        $FunctionalProvider<
          UpdateCustomerUseCase,
          UpdateCustomerUseCase,
          UpdateCustomerUseCase
        >
    with $Provider<UpdateCustomerUseCase> {
  const UpdateCustomerUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updateCustomerUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updateCustomerUseCaseHash();

  @$internal
  @override
  $ProviderElement<UpdateCustomerUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  UpdateCustomerUseCase create(Ref ref) {
    return updateCustomerUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpdateCustomerUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpdateCustomerUseCase>(value),
    );
  }
}

String _$updateCustomerUseCaseHash() =>
    r'19bc2997424e1025dfe262ac0958a4701a029b52';

@ProviderFor(deleteCustomerUseCase)
const deleteCustomerUseCaseProvider = DeleteCustomerUseCaseProvider._();

final class DeleteCustomerUseCaseProvider
    extends
        $FunctionalProvider<
          DeleteCustomerUseCase,
          DeleteCustomerUseCase,
          DeleteCustomerUseCase
        >
    with $Provider<DeleteCustomerUseCase> {
  const DeleteCustomerUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deleteCustomerUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deleteCustomerUseCaseHash();

  @$internal
  @override
  $ProviderElement<DeleteCustomerUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DeleteCustomerUseCase create(Ref ref) {
    return deleteCustomerUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeleteCustomerUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeleteCustomerUseCase>(value),
    );
  }
}

String _$deleteCustomerUseCaseHash() =>
    r'aac05be22287db5923add1026c643929eac72523';

@ProviderFor(searchCustomersUseCase)
const searchCustomersUseCaseProvider = SearchCustomersUseCaseProvider._();

final class SearchCustomersUseCaseProvider
    extends
        $FunctionalProvider<
          SearchCustomersUseCase,
          SearchCustomersUseCase,
          SearchCustomersUseCase
        >
    with $Provider<SearchCustomersUseCase> {
  const SearchCustomersUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchCustomersUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchCustomersUseCaseHash();

  @$internal
  @override
  $ProviderElement<SearchCustomersUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SearchCustomersUseCase create(Ref ref) {
    return searchCustomersUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SearchCustomersUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SearchCustomersUseCase>(value),
    );
  }
}

String _$searchCustomersUseCaseHash() =>
    r'be80aa7c71d0569f9076658f31b6c9512a33d103';

@ProviderFor(generateNextCustomerCodeUseCase)
const generateNextCustomerCodeUseCaseProvider =
    GenerateNextCustomerCodeUseCaseProvider._();

final class GenerateNextCustomerCodeUseCaseProvider
    extends
        $FunctionalProvider<
          GenerateNextCustomerCodeUseCase,
          GenerateNextCustomerCodeUseCase,
          GenerateNextCustomerCodeUseCase
        >
    with $Provider<GenerateNextCustomerCodeUseCase> {
  const GenerateNextCustomerCodeUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'generateNextCustomerCodeUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$generateNextCustomerCodeUseCaseHash();

  @$internal
  @override
  $ProviderElement<GenerateNextCustomerCodeUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GenerateNextCustomerCodeUseCase create(Ref ref) {
    return generateNextCustomerCodeUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GenerateNextCustomerCodeUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GenerateNextCustomerCodeUseCase>(
        value,
      ),
    );
  }
}

String _$generateNextCustomerCodeUseCaseHash() =>
    r'551db1bc5936022131f56675aa29316bb8ce10f2';

@ProviderFor(saleRepository)
const saleRepositoryProvider = SaleRepositoryProvider._();

final class SaleRepositoryProvider
    extends $FunctionalProvider<SaleRepository, SaleRepository, SaleRepository>
    with $Provider<SaleRepository> {
  const SaleRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saleRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saleRepositoryHash();

  @$internal
  @override
  $ProviderElement<SaleRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SaleRepository create(Ref ref) {
    return saleRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SaleRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SaleRepository>(value),
    );
  }
}

String _$saleRepositoryHash() => r'42e3886b205d2aaea015479432c0768b0d5147f4';

@ProviderFor(createSaleUseCase)
const createSaleUseCaseProvider = CreateSaleUseCaseProvider._();

final class CreateSaleUseCaseProvider
    extends
        $FunctionalProvider<
          CreateSaleUseCase,
          CreateSaleUseCase,
          CreateSaleUseCase
        >
    with $Provider<CreateSaleUseCase> {
  const CreateSaleUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createSaleUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createSaleUseCaseHash();

  @$internal
  @override
  $ProviderElement<CreateSaleUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CreateSaleUseCase create(Ref ref) {
    return createSaleUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreateSaleUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreateSaleUseCase>(value),
    );
  }
}

String _$createSaleUseCaseHash() => r'8383adf6cc1f027ea36f0ff243858a83b1b228c2';

@ProviderFor(getSalesUseCase)
const getSalesUseCaseProvider = GetSalesUseCaseProvider._();

final class GetSalesUseCaseProvider
    extends
        $FunctionalProvider<GetSalesUseCase, GetSalesUseCase, GetSalesUseCase>
    with $Provider<GetSalesUseCase> {
  const GetSalesUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getSalesUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getSalesUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetSalesUseCase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GetSalesUseCase create(Ref ref) {
    return getSalesUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetSalesUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetSalesUseCase>(value),
    );
  }
}

String _$getSalesUseCaseHash() => r'b8404b9c68a426df76866da8169c2d0562cc427a';

@ProviderFor(getSaleByIdUseCase)
const getSaleByIdUseCaseProvider = GetSaleByIdUseCaseProvider._();

final class GetSaleByIdUseCaseProvider
    extends
        $FunctionalProvider<
          GetSaleByIdUseCase,
          GetSaleByIdUseCase,
          GetSaleByIdUseCase
        >
    with $Provider<GetSaleByIdUseCase> {
  const GetSaleByIdUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getSaleByIdUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getSaleByIdUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetSaleByIdUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetSaleByIdUseCase create(Ref ref) {
    return getSaleByIdUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetSaleByIdUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetSaleByIdUseCase>(value),
    );
  }
}

String _$getSaleByIdUseCaseHash() =>
    r'6b492a9e9c8bb815c4434ba9911cc9a2435f02c1';

@ProviderFor(generateNextSaleNumberUseCase)
const generateNextSaleNumberUseCaseProvider =
    GenerateNextSaleNumberUseCaseProvider._();

final class GenerateNextSaleNumberUseCaseProvider
    extends
        $FunctionalProvider<
          GenerateNextSaleNumberUseCase,
          GenerateNextSaleNumberUseCase,
          GenerateNextSaleNumberUseCase
        >
    with $Provider<GenerateNextSaleNumberUseCase> {
  const GenerateNextSaleNumberUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'generateNextSaleNumberUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$generateNextSaleNumberUseCaseHash();

  @$internal
  @override
  $ProviderElement<GenerateNextSaleNumberUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GenerateNextSaleNumberUseCase create(Ref ref) {
    return generateNextSaleNumberUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GenerateNextSaleNumberUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GenerateNextSaleNumberUseCase>(
        value,
      ),
    );
  }
}

String _$generateNextSaleNumberUseCaseHash() =>
    r'961dbaf4e486457c812f9b381356b98b10dfece1';

@ProviderFor(cancelSaleUseCase)
const cancelSaleUseCaseProvider = CancelSaleUseCaseProvider._();

final class CancelSaleUseCaseProvider
    extends
        $FunctionalProvider<
          CancelSaleUseCase,
          CancelSaleUseCase,
          CancelSaleUseCase
        >
    with $Provider<CancelSaleUseCase> {
  const CancelSaleUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cancelSaleUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cancelSaleUseCaseHash();

  @$internal
  @override
  $ProviderElement<CancelSaleUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CancelSaleUseCase create(Ref ref) {
    return cancelSaleUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CancelSaleUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CancelSaleUseCase>(value),
    );
  }
}

String _$cancelSaleUseCaseHash() => r'9944252307a4ca1b2a7f8216c41b12ac65fb5bc7';

@ProviderFor(cashSessionRepository)
const cashSessionRepositoryProvider = CashSessionRepositoryProvider._();

final class CashSessionRepositoryProvider
    extends
        $FunctionalProvider<
          CashSessionRepository,
          CashSessionRepository,
          CashSessionRepository
        >
    with $Provider<CashSessionRepository> {
  const CashSessionRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cashSessionRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cashSessionRepositoryHash();

  @$internal
  @override
  $ProviderElement<CashSessionRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CashSessionRepository create(Ref ref) {
    return cashSessionRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CashSessionRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CashSessionRepository>(value),
    );
  }
}

String _$cashSessionRepositoryHash() =>
    r'27facafcaf569de253a084f81d5eea17d1b4be3d';

@ProviderFor(getCurrentSession)
const getCurrentSessionProvider = GetCurrentSessionProvider._();

final class GetCurrentSessionProvider
    extends
        $FunctionalProvider<
          GetCurrentSession,
          GetCurrentSession,
          GetCurrentSession
        >
    with $Provider<GetCurrentSession> {
  const GetCurrentSessionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getCurrentSessionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getCurrentSessionHash();

  @$internal
  @override
  $ProviderElement<GetCurrentSession> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetCurrentSession create(Ref ref) {
    return getCurrentSession(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetCurrentSession value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetCurrentSession>(value),
    );
  }
}

String _$getCurrentSessionHash() => r'32cb4df366931b14802aaa665b114d665ad3873d';

@ProviderFor(getCurrentCashSessionUseCase)
const getCurrentCashSessionUseCaseProvider =
    GetCurrentCashSessionUseCaseProvider._();

final class GetCurrentCashSessionUseCaseProvider
    extends
        $FunctionalProvider<
          GetCurrentCashSessionUseCase,
          GetCurrentCashSessionUseCase,
          GetCurrentCashSessionUseCase
        >
    with $Provider<GetCurrentCashSessionUseCase> {
  const GetCurrentCashSessionUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getCurrentCashSessionUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getCurrentCashSessionUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetCurrentCashSessionUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetCurrentCashSessionUseCase create(Ref ref) {
    return getCurrentCashSessionUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetCurrentCashSessionUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetCurrentCashSessionUseCase>(value),
    );
  }
}

String _$getCurrentCashSessionUseCaseHash() =>
    r'98544a12457218c3a7087521b443cd7737d465bf';

@ProviderFor(openCashSessionUseCase)
const openCashSessionUseCaseProvider = OpenCashSessionUseCaseProvider._();

final class OpenCashSessionUseCaseProvider
    extends
        $FunctionalProvider<
          OpenCashSessionUseCase,
          OpenCashSessionUseCase,
          OpenCashSessionUseCase
        >
    with $Provider<OpenCashSessionUseCase> {
  const OpenCashSessionUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'openCashSessionUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$openCashSessionUseCaseHash();

  @$internal
  @override
  $ProviderElement<OpenCashSessionUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  OpenCashSessionUseCase create(Ref ref) {
    return openCashSessionUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OpenCashSessionUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OpenCashSessionUseCase>(value),
    );
  }
}

String _$openCashSessionUseCaseHash() =>
    r'68b51296d4be6325f6e606e6009900ff914be8ee';

@ProviderFor(closeCashSessionUseCase)
const closeCashSessionUseCaseProvider = CloseCashSessionUseCaseProvider._();

final class CloseCashSessionUseCaseProvider
    extends
        $FunctionalProvider<
          CloseCashSessionUseCase,
          CloseCashSessionUseCase,
          CloseCashSessionUseCase
        >
    with $Provider<CloseCashSessionUseCase> {
  const CloseCashSessionUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'closeCashSessionUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$closeCashSessionUseCaseHash();

  @$internal
  @override
  $ProviderElement<CloseCashSessionUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CloseCashSessionUseCase create(Ref ref) {
    return closeCashSessionUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CloseCashSessionUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CloseCashSessionUseCase>(value),
    );
  }
}

String _$closeCashSessionUseCaseHash() =>
    r'e8034c2c4d3e82819d4b83c41a2faa31afd39824';

@ProviderFor(currentCashSession)
const currentCashSessionProvider = CurrentCashSessionProvider._();

final class CurrentCashSessionProvider
    extends $FunctionalProvider<AsyncValue<dynamic>, dynamic, FutureOr<dynamic>>
    with $FutureModifier<dynamic>, $FutureProvider<dynamic> {
  const CurrentCashSessionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentCashSessionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentCashSessionHash();

  @$internal
  @override
  $FutureProviderElement<dynamic> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<dynamic> create(Ref ref) {
    return currentCashSession(ref);
  }
}

String _$currentCashSessionHash() =>
    r'020890236b6c4f78961a49c79e957ea5124a4128';

@ProviderFor(purchaseRepository)
const purchaseRepositoryProvider = PurchaseRepositoryProvider._();

final class PurchaseRepositoryProvider
    extends
        $FunctionalProvider<
          PurchaseRepository,
          PurchaseRepository,
          PurchaseRepository
        >
    with $Provider<PurchaseRepository> {
  const PurchaseRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'purchaseRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$purchaseRepositoryHash();

  @$internal
  @override
  $ProviderElement<PurchaseRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PurchaseRepository create(Ref ref) {
    return purchaseRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PurchaseRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PurchaseRepository>(value),
    );
  }
}

String _$purchaseRepositoryHash() =>
    r'5de5f138cbc4d1e4d32947336eefb8a9119181e0';

@ProviderFor(getPurchasesUseCase)
const getPurchasesUseCaseProvider = GetPurchasesUseCaseProvider._();

final class GetPurchasesUseCaseProvider
    extends
        $FunctionalProvider<
          GetPurchasesUseCase,
          GetPurchasesUseCase,
          GetPurchasesUseCase
        >
    with $Provider<GetPurchasesUseCase> {
  const GetPurchasesUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getPurchasesUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getPurchasesUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetPurchasesUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetPurchasesUseCase create(Ref ref) {
    return getPurchasesUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetPurchasesUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetPurchasesUseCase>(value),
    );
  }
}

String _$getPurchasesUseCaseHash() =>
    r'8c55b8a426b11b2b7ccfa9e2056029f0ae4ad1e8';

@ProviderFor(getPurchaseByIdUseCase)
const getPurchaseByIdUseCaseProvider = GetPurchaseByIdUseCaseProvider._();

final class GetPurchaseByIdUseCaseProvider
    extends
        $FunctionalProvider<
          GetPurchaseByIdUseCase,
          GetPurchaseByIdUseCase,
          GetPurchaseByIdUseCase
        >
    with $Provider<GetPurchaseByIdUseCase> {
  const GetPurchaseByIdUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getPurchaseByIdUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getPurchaseByIdUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetPurchaseByIdUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetPurchaseByIdUseCase create(Ref ref) {
    return getPurchaseByIdUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetPurchaseByIdUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetPurchaseByIdUseCase>(value),
    );
  }
}

String _$getPurchaseByIdUseCaseHash() =>
    r'25ccbb63fb4bb3ab351b6d849e0c2057847d5b68';

@ProviderFor(createPurchaseUseCase)
const createPurchaseUseCaseProvider = CreatePurchaseUseCaseProvider._();

final class CreatePurchaseUseCaseProvider
    extends
        $FunctionalProvider<
          CreatePurchaseUseCase,
          CreatePurchaseUseCase,
          CreatePurchaseUseCase
        >
    with $Provider<CreatePurchaseUseCase> {
  const CreatePurchaseUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createPurchaseUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createPurchaseUseCaseHash();

  @$internal
  @override
  $ProviderElement<CreatePurchaseUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CreatePurchaseUseCase create(Ref ref) {
    return createPurchaseUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreatePurchaseUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreatePurchaseUseCase>(value),
    );
  }
}

String _$createPurchaseUseCaseHash() =>
    r'8d04eb3b1c5b0bae0411ad0b84f05c0d66a1eee4';

@ProviderFor(updatePurchaseUseCase)
const updatePurchaseUseCaseProvider = UpdatePurchaseUseCaseProvider._();

final class UpdatePurchaseUseCaseProvider
    extends
        $FunctionalProvider<
          UpdatePurchaseUseCase,
          UpdatePurchaseUseCase,
          UpdatePurchaseUseCase
        >
    with $Provider<UpdatePurchaseUseCase> {
  const UpdatePurchaseUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updatePurchaseUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updatePurchaseUseCaseHash();

  @$internal
  @override
  $ProviderElement<UpdatePurchaseUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  UpdatePurchaseUseCase create(Ref ref) {
    return updatePurchaseUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpdatePurchaseUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpdatePurchaseUseCase>(value),
    );
  }
}

String _$updatePurchaseUseCaseHash() =>
    r'a2c85efd8df5f369e8550192060cfb71f9a888c3';

@ProviderFor(deletePurchaseUseCase)
const deletePurchaseUseCaseProvider = DeletePurchaseUseCaseProvider._();

final class DeletePurchaseUseCaseProvider
    extends
        $FunctionalProvider<
          DeletePurchaseUseCase,
          DeletePurchaseUseCase,
          DeletePurchaseUseCase
        >
    with $Provider<DeletePurchaseUseCase> {
  const DeletePurchaseUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deletePurchaseUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deletePurchaseUseCaseHash();

  @$internal
  @override
  $ProviderElement<DeletePurchaseUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DeletePurchaseUseCase create(Ref ref) {
    return deletePurchaseUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeletePurchaseUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeletePurchaseUseCase>(value),
    );
  }
}

String _$deletePurchaseUseCaseHash() =>
    r'be05b66b079aa65b5c28d6916b1b474848b5d8d6';

@ProviderFor(receivePurchaseUseCase)
const receivePurchaseUseCaseProvider = ReceivePurchaseUseCaseProvider._();

final class ReceivePurchaseUseCaseProvider
    extends
        $FunctionalProvider<
          ReceivePurchaseUseCase,
          ReceivePurchaseUseCase,
          ReceivePurchaseUseCase
        >
    with $Provider<ReceivePurchaseUseCase> {
  const ReceivePurchaseUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'receivePurchaseUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$receivePurchaseUseCaseHash();

  @$internal
  @override
  $ProviderElement<ReceivePurchaseUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ReceivePurchaseUseCase create(Ref ref) {
    return receivePurchaseUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReceivePurchaseUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReceivePurchaseUseCase>(value),
    );
  }
}

String _$receivePurchaseUseCaseHash() =>
    r'a486676f272c5abf64f4b98b8a6daf60ac428a13';

@ProviderFor(cancelPurchaseUseCase)
const cancelPurchaseUseCaseProvider = CancelPurchaseUseCaseProvider._();

final class CancelPurchaseUseCaseProvider
    extends
        $FunctionalProvider<
          CancelPurchaseUseCase,
          CancelPurchaseUseCase,
          CancelPurchaseUseCase
        >
    with $Provider<CancelPurchaseUseCase> {
  const CancelPurchaseUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cancelPurchaseUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cancelPurchaseUseCaseHash();

  @$internal
  @override
  $ProviderElement<CancelPurchaseUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CancelPurchaseUseCase create(Ref ref) {
    return cancelPurchaseUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CancelPurchaseUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CancelPurchaseUseCase>(value),
    );
  }
}

String _$cancelPurchaseUseCaseHash() =>
    r'89775ae729bb82e1960ec589899b8bf4c75da364';

@ProviderFor(purchaseItemRepository)
const purchaseItemRepositoryProvider = PurchaseItemRepositoryProvider._();

final class PurchaseItemRepositoryProvider
    extends
        $FunctionalProvider<
          PurchaseItemRepository,
          PurchaseItemRepository,
          PurchaseItemRepository
        >
    with $Provider<PurchaseItemRepository> {
  const PurchaseItemRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'purchaseItemRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$purchaseItemRepositoryHash();

  @$internal
  @override
  $ProviderElement<PurchaseItemRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PurchaseItemRepository create(Ref ref) {
    return purchaseItemRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PurchaseItemRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PurchaseItemRepository>(value),
    );
  }
}

String _$purchaseItemRepositoryHash() =>
    r'0afd4ec57ad8578c286e50eb493d6fb7e1a9fc82';

@ProviderFor(getPurchaseItemsUseCase)
const getPurchaseItemsUseCaseProvider = GetPurchaseItemsUseCaseProvider._();

final class GetPurchaseItemsUseCaseProvider
    extends
        $FunctionalProvider<
          GetPurchaseItemsUseCase,
          GetPurchaseItemsUseCase,
          GetPurchaseItemsUseCase
        >
    with $Provider<GetPurchaseItemsUseCase> {
  const GetPurchaseItemsUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getPurchaseItemsUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getPurchaseItemsUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetPurchaseItemsUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetPurchaseItemsUseCase create(Ref ref) {
    return getPurchaseItemsUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetPurchaseItemsUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetPurchaseItemsUseCase>(value),
    );
  }
}

String _$getPurchaseItemsUseCaseHash() =>
    r'b298fa45952884376542019a65e974ce283e388b';

@ProviderFor(getPurchaseItemsByPurchaseIdUseCase)
const getPurchaseItemsByPurchaseIdUseCaseProvider =
    GetPurchaseItemsByPurchaseIdUseCaseProvider._();

final class GetPurchaseItemsByPurchaseIdUseCaseProvider
    extends
        $FunctionalProvider<
          GetPurchaseItemsByPurchaseIdUseCase,
          GetPurchaseItemsByPurchaseIdUseCase,
          GetPurchaseItemsByPurchaseIdUseCase
        >
    with $Provider<GetPurchaseItemsByPurchaseIdUseCase> {
  const GetPurchaseItemsByPurchaseIdUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getPurchaseItemsByPurchaseIdUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() =>
      _$getPurchaseItemsByPurchaseIdUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetPurchaseItemsByPurchaseIdUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetPurchaseItemsByPurchaseIdUseCase create(Ref ref) {
    return getPurchaseItemsByPurchaseIdUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetPurchaseItemsByPurchaseIdUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetPurchaseItemsByPurchaseIdUseCase>(
        value,
      ),
    );
  }
}

String _$getPurchaseItemsByPurchaseIdUseCaseHash() =>
    r'95d18283069c2299ca89f816051f2f2a1d970e53';

@ProviderFor(getPurchaseItemByIdUseCase)
const getPurchaseItemByIdUseCaseProvider =
    GetPurchaseItemByIdUseCaseProvider._();

final class GetPurchaseItemByIdUseCaseProvider
    extends
        $FunctionalProvider<
          GetPurchaseItemByIdUseCase,
          GetPurchaseItemByIdUseCase,
          GetPurchaseItemByIdUseCase
        >
    with $Provider<GetPurchaseItemByIdUseCase> {
  const GetPurchaseItemByIdUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getPurchaseItemByIdUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getPurchaseItemByIdUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetPurchaseItemByIdUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetPurchaseItemByIdUseCase create(Ref ref) {
    return getPurchaseItemByIdUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetPurchaseItemByIdUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetPurchaseItemByIdUseCase>(value),
    );
  }
}

String _$getPurchaseItemByIdUseCaseHash() =>
    r'2a409f95cb3777515adf0de539d8e4927ed49996';

@ProviderFor(getPurchaseItemsByProductIdUseCase)
const getPurchaseItemsByProductIdUseCaseProvider =
    GetPurchaseItemsByProductIdUseCaseProvider._();

final class GetPurchaseItemsByProductIdUseCaseProvider
    extends
        $FunctionalProvider<
          GetPurchaseItemsByProductIdUseCase,
          GetPurchaseItemsByProductIdUseCase,
          GetPurchaseItemsByProductIdUseCase
        >
    with $Provider<GetPurchaseItemsByProductIdUseCase> {
  const GetPurchaseItemsByProductIdUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getPurchaseItemsByProductIdUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() =>
      _$getPurchaseItemsByProductIdUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetPurchaseItemsByProductIdUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetPurchaseItemsByProductIdUseCase create(Ref ref) {
    return getPurchaseItemsByProductIdUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetPurchaseItemsByProductIdUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetPurchaseItemsByProductIdUseCase>(
        value,
      ),
    );
  }
}

String _$getPurchaseItemsByProductIdUseCaseHash() =>
    r'd5decd59de1be01496d6d88c495f227ea7ce2a4f';

@ProviderFor(createPurchaseItemUseCase)
const createPurchaseItemUseCaseProvider = CreatePurchaseItemUseCaseProvider._();

final class CreatePurchaseItemUseCaseProvider
    extends
        $FunctionalProvider<
          CreatePurchaseItemUseCase,
          CreatePurchaseItemUseCase,
          CreatePurchaseItemUseCase
        >
    with $Provider<CreatePurchaseItemUseCase> {
  const CreatePurchaseItemUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createPurchaseItemUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createPurchaseItemUseCaseHash();

  @$internal
  @override
  $ProviderElement<CreatePurchaseItemUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CreatePurchaseItemUseCase create(Ref ref) {
    return createPurchaseItemUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreatePurchaseItemUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreatePurchaseItemUseCase>(value),
    );
  }
}

String _$createPurchaseItemUseCaseHash() =>
    r'75d612162040cc1bad53789e78940397e1febb0b';

@ProviderFor(updatePurchaseItemUseCase)
const updatePurchaseItemUseCaseProvider = UpdatePurchaseItemUseCaseProvider._();

final class UpdatePurchaseItemUseCaseProvider
    extends
        $FunctionalProvider<
          UpdatePurchaseItemUseCase,
          UpdatePurchaseItemUseCase,
          UpdatePurchaseItemUseCase
        >
    with $Provider<UpdatePurchaseItemUseCase> {
  const UpdatePurchaseItemUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updatePurchaseItemUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updatePurchaseItemUseCaseHash();

  @$internal
  @override
  $ProviderElement<UpdatePurchaseItemUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  UpdatePurchaseItemUseCase create(Ref ref) {
    return updatePurchaseItemUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpdatePurchaseItemUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpdatePurchaseItemUseCase>(value),
    );
  }
}

String _$updatePurchaseItemUseCaseHash() =>
    r'61a3183d1287e2bc0ef5690b4f4852087ab04367';

@ProviderFor(deletePurchaseItemUseCase)
const deletePurchaseItemUseCaseProvider = DeletePurchaseItemUseCaseProvider._();

final class DeletePurchaseItemUseCaseProvider
    extends
        $FunctionalProvider<
          DeletePurchaseItemUseCase,
          DeletePurchaseItemUseCase,
          DeletePurchaseItemUseCase
        >
    with $Provider<DeletePurchaseItemUseCase> {
  const DeletePurchaseItemUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deletePurchaseItemUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deletePurchaseItemUseCaseHash();

  @$internal
  @override
  $ProviderElement<DeletePurchaseItemUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DeletePurchaseItemUseCase create(Ref ref) {
    return deletePurchaseItemUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeletePurchaseItemUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeletePurchaseItemUseCase>(value),
    );
  }
}

String _$deletePurchaseItemUseCaseHash() =>
    r'2682581ea5c013d29ae7be3b3fa0fdb6f2137470';

@ProviderFor(getPurchaseItemsByDateRangeUseCase)
const getPurchaseItemsByDateRangeUseCaseProvider =
    GetPurchaseItemsByDateRangeUseCaseProvider._();

final class GetPurchaseItemsByDateRangeUseCaseProvider
    extends
        $FunctionalProvider<
          GetPurchaseItemsByDateRangeUseCase,
          GetPurchaseItemsByDateRangeUseCase,
          GetPurchaseItemsByDateRangeUseCase
        >
    with $Provider<GetPurchaseItemsByDateRangeUseCase> {
  const GetPurchaseItemsByDateRangeUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getPurchaseItemsByDateRangeUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() =>
      _$getPurchaseItemsByDateRangeUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetPurchaseItemsByDateRangeUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetPurchaseItemsByDateRangeUseCase create(Ref ref) {
    return getPurchaseItemsByDateRangeUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetPurchaseItemsByDateRangeUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetPurchaseItemsByDateRangeUseCase>(
        value,
      ),
    );
  }
}

String _$getPurchaseItemsByDateRangeUseCaseHash() =>
    r'139c6e681c5af73c1bb3d8fa074c69902f710174';

@ProviderFor(getRecentPurchaseItemsUseCase)
const getRecentPurchaseItemsUseCaseProvider =
    GetRecentPurchaseItemsUseCaseProvider._();

final class GetRecentPurchaseItemsUseCaseProvider
    extends
        $FunctionalProvider<
          GetRecentPurchaseItemsUseCase,
          GetRecentPurchaseItemsUseCase,
          GetRecentPurchaseItemsUseCase
        >
    with $Provider<GetRecentPurchaseItemsUseCase> {
  const GetRecentPurchaseItemsUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getRecentPurchaseItemsUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getRecentPurchaseItemsUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetRecentPurchaseItemsUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetRecentPurchaseItemsUseCase create(Ref ref) {
    return getRecentPurchaseItemsUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetRecentPurchaseItemsUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetRecentPurchaseItemsUseCase>(
        value,
      ),
    );
  }
}

String _$getRecentPurchaseItemsUseCaseHash() =>
    r'b12abfd99f33e59a7a5eb0b8223f71ed0022a271';

@ProviderFor(adjustInventory)
const adjustInventoryProvider = AdjustInventoryProvider._();

final class AdjustInventoryProvider
    extends
        $FunctionalProvider<
          AdjustInventoryUseCase,
          AdjustInventoryUseCase,
          AdjustInventoryUseCase
        >
    with $Provider<AdjustInventoryUseCase> {
  const AdjustInventoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adjustInventoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adjustInventoryHash();

  @$internal
  @override
  $ProviderElement<AdjustInventoryUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AdjustInventoryUseCase create(Ref ref) {
    return adjustInventory(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AdjustInventoryUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AdjustInventoryUseCase>(value),
    );
  }
}

String _$adjustInventoryHash() => r'5ba3058aa57b4cb06e90ec0f03d1782e8625ca76';

@ProviderFor(transferInventory)
const transferInventoryProvider = TransferInventoryProvider._();

final class TransferInventoryProvider
    extends
        $FunctionalProvider<
          TransferInventoryUseCase,
          TransferInventoryUseCase,
          TransferInventoryUseCase
        >
    with $Provider<TransferInventoryUseCase> {
  const TransferInventoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transferInventoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transferInventoryHash();

  @$internal
  @override
  $ProviderElement<TransferInventoryUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TransferInventoryUseCase create(Ref ref) {
    return transferInventory(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TransferInventoryUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TransferInventoryUseCase>(value),
    );
  }
}

String _$transferInventoryHash() => r'd97a74e84d6173fa3beb448e7a3f22ba0fd74077';

@ProviderFor(adjustInventoryBatchUseCase)
const adjustInventoryBatchUseCaseProvider =
    AdjustInventoryBatchUseCaseProvider._();

final class AdjustInventoryBatchUseCaseProvider
    extends
        $FunctionalProvider<
          AdjustInventoryBatchUseCase,
          AdjustInventoryBatchUseCase,
          AdjustInventoryBatchUseCase
        >
    with $Provider<AdjustInventoryBatchUseCase> {
  const AdjustInventoryBatchUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adjustInventoryBatchUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adjustInventoryBatchUseCaseHash();

  @$internal
  @override
  $ProviderElement<AdjustInventoryBatchUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AdjustInventoryBatchUseCase create(Ref ref) {
    return adjustInventoryBatchUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AdjustInventoryBatchUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AdjustInventoryBatchUseCase>(value),
    );
  }
}

String _$adjustInventoryBatchUseCaseHash() =>
    r'ec46648cb45628f24b9d893d93113751d473093f';
