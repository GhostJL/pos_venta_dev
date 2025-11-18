import 'package:posventa/data/datasources/database_helper.dart';
import 'package:posventa/data/repositories/warehouse_repository_impl.dart';
import 'package:posventa/domain/repositories/warehouse_repository.dart';
import 'package:posventa/domain/use_cases/create_warehouse.dart';
import 'package:posventa/domain/use_cases/delete_warehouse.dart';
import 'package:posventa/domain/use_cases/get_all_warehouses.dart';
import 'package:posventa/domain/use_cases/update_warehouse.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

@riverpod
DatabaseHelper databaseHelper(ref) => DatabaseHelper.instance;

@riverpod
WarehouseRepository warehouseRepository(ref) =>
    WarehouseRepositoryImpl(ref.watch(databaseHelperProvider));

@riverpod
GetAllWarehouses getAllWarehouses(ref) =>
    GetAllWarehouses(ref.watch(warehouseRepositoryProvider));

@riverpod
CreateWarehouse createWarehouse(ref) =>
    CreateWarehouse(ref.watch(warehouseRepositoryProvider));

@riverpod
UpdateWarehouse updateWarehouse(ref) =>
    UpdateWarehouse(ref.watch(warehouseRepositoryProvider));

@riverpod
DeleteWarehouse deleteWarehouse(ref) =>
    DeleteWarehouse(ref.watch(warehouseRepositoryProvider));
