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
