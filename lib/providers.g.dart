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
