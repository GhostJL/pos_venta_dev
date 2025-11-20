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

String _$createSaleUseCaseHash() => r'3db622103744c3ce938942a65c887ad2610100da';

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
