// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_di.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(stockValidatorService)
const stockValidatorServiceProvider = StockValidatorServiceProvider._();

final class StockValidatorServiceProvider
    extends
        $FunctionalProvider<
          StockValidatorService,
          StockValidatorService,
          StockValidatorService
        >
    with $Provider<StockValidatorService> {
  const StockValidatorServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'stockValidatorServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$stockValidatorServiceHash();

  @$internal
  @override
  $ProviderElement<StockValidatorService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  StockValidatorService create(Ref ref) {
    return stockValidatorService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StockValidatorService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StockValidatorService>(value),
    );
  }
}

String _$stockValidatorServiceHash() =>
    r'f37d240b9e261776615c8d769044168fffa33ad3';

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

@ProviderFor(deleteInventoryByVariant)
const deleteInventoryByVariantProvider = DeleteInventoryByVariantProvider._();

final class DeleteInventoryByVariantProvider
    extends
        $FunctionalProvider<
          DeleteInventoryByVariant,
          DeleteInventoryByVariant,
          DeleteInventoryByVariant
        >
    with $Provider<DeleteInventoryByVariant> {
  const DeleteInventoryByVariantProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deleteInventoryByVariantProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deleteInventoryByVariantHash();

  @$internal
  @override
  $ProviderElement<DeleteInventoryByVariant> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DeleteInventoryByVariant create(Ref ref) {
    return deleteInventoryByVariant(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeleteInventoryByVariant value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeleteInventoryByVariant>(value),
    );
  }
}

String _$deleteInventoryByVariantHash() =>
    r'457687b928dbc525201211e56ee104dc0f04ac20';

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
