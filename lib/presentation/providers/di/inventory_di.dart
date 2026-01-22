import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:posventa/domain/repositories/warehouse_repository.dart';
import 'package:posventa/data/repositories/warehouse_repository_impl.dart';
import 'package:posventa/domain/use_cases/warehouse/create_warehouse.dart';
import 'package:posventa/domain/use_cases/warehouse/delete_warehouse.dart';
import 'package:posventa/domain/use_cases/warehouse/get_all_warehouses.dart';
import 'package:posventa/domain/use_cases/warehouse/update_warehouse.dart';
import 'package:posventa/domain/repositories/inventory_repository.dart';
import 'package:posventa/data/repositories/inventory_repository_impl.dart';
import 'package:posventa/domain/use_cases/inventory/get_all_inventory.dart';
import 'package:posventa/domain/use_cases/inventory/create_inventory.dart';
import 'package:posventa/domain/use_cases/inventory/update_inventory.dart';
import 'package:posventa/domain/use_cases/inventory/delete_inventory.dart';
import 'package:posventa/domain/use_cases/inventory/get_inventory_by_product.dart';
import 'package:posventa/domain/use_cases/inventory/delete_inventory_by_variant.dart';
import 'package:posventa/domain/use_cases/inventory/reset_inventory_use_case.dart';
import 'package:posventa/domain/repositories/inventory_lot_repository.dart';
import 'package:posventa/data/repositories/inventory_lot_repository_impl.dart';
import 'package:posventa/domain/repositories/inventory_movement_repository.dart';
import 'package:posventa/data/repositories/inventory_movement_repository_impl.dart';
import 'package:posventa/domain/use_cases/inventory_movement/get_all_inventory_movements.dart';
import 'package:posventa/domain/use_cases/inventory_movement/create_inventory_movement.dart';
import 'package:posventa/domain/use_cases/inventory_movement/update_inventory_movement.dart';
import 'package:posventa/domain/use_cases/inventory_movement/delete_inventory_movement.dart';
import 'package:posventa/domain/use_cases/inventory_movement/get_inventory_movements_by_product.dart';
import 'package:posventa/domain/use_cases/inventory_movement/get_inventory_movements_by_warehouse.dart';
import 'package:posventa/domain/use_cases/inventory_movement/get_inventory_movements_by_date_range.dart';
import 'package:posventa/presentation/providers/di/core_di.dart';
import 'package:posventa/domain/services/stock_validator_service.dart';
import 'package:posventa/domain/services/stock_synchronizer.dart';
import 'package:posventa/presentation/providers/di/product_di.dart';

part 'inventory_di.g.dart';

// --- Stock Validator ---

@riverpod
StockValidatorService stockValidatorService(ref) =>
    StockValidatorService(ref.watch(inventoryRepositoryProvider));

@riverpod
StockSynchronizer stockSynchronizer(ref) => StockSynchronizer(
  ref.watch(inventoryRepositoryProvider),
  ref.watch(productRepositoryProvider),
);

// --- Warehouse Providers ---

@riverpod
WarehouseRepository warehouseRepository(ref) =>
    WarehouseRepositoryImpl(ref.watch(appDatabaseProvider));

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

// --- Inventory Lot Providers ---

@riverpod
InventoryLotRepository inventoryLotRepository(ref) =>
    InventoryLotRepositoryImpl(ref.watch(appDatabaseProvider));

// --- Inventory Providers ---

@riverpod
InventoryRepository inventoryRepository(ref) =>
    InventoryRepositoryImpl(ref.watch(appDatabaseProvider));

@riverpod
GetAllInventory getAllInventory(ref) =>
    GetAllInventory(ref.watch(inventoryRepositoryProvider));

@riverpod
CreateInventory createInventory(ref) =>
    CreateInventory(ref.watch(inventoryRepositoryProvider));

@riverpod
UpdateInventory updateInventory(ref) =>
    UpdateInventory(ref.watch(inventoryRepositoryProvider));

@riverpod
DeleteInventory deleteInventory(ref) =>
    DeleteInventory(ref.watch(inventoryRepositoryProvider));

@riverpod
GetInventoryByProduct getInventoryByProduct(ref) =>
    GetInventoryByProduct(ref.watch(inventoryRepositoryProvider));

@riverpod
DeleteInventoryByVariant deleteInventoryByVariant(ref) =>
    DeleteInventoryByVariant(ref.watch(inventoryRepositoryProvider));

@riverpod
ResetInventoryUseCase resetInventoryUseCase(ref) =>
    ResetInventoryUseCase(ref.watch(inventoryRepositoryProvider));

// --- Inventory Movement Providers ---

@riverpod
InventoryMovementRepository inventoryMovementRepository(ref) =>
    InventoryMovementRepositoryImpl(ref.watch(appDatabaseProvider));

@riverpod
GetAllInventoryMovements getAllInventoryMovements(ref) =>
    GetAllInventoryMovements(ref.watch(inventoryMovementRepositoryProvider));

@riverpod
CreateInventoryMovement createInventoryMovement(ref) =>
    CreateInventoryMovement(ref.watch(inventoryMovementRepositoryProvider));

@riverpod
UpdateInventoryMovement updateInventoryMovement(ref) =>
    UpdateInventoryMovement(ref.watch(inventoryMovementRepositoryProvider));

@riverpod
DeleteInventoryMovement deleteInventoryMovement(ref) =>
    DeleteInventoryMovement(ref.watch(inventoryMovementRepositoryProvider));

@riverpod
GetInventoryMovementsByProduct getInventoryMovementsByProduct(ref) =>
    GetInventoryMovementsByProduct(
      ref.watch(inventoryMovementRepositoryProvider),
    );

@riverpod
GetInventoryMovementsByWarehouse getInventoryMovementsByWarehouse(ref) =>
    GetInventoryMovementsByWarehouse(
      ref.watch(inventoryMovementRepositoryProvider),
    );

@riverpod
GetInventoryMovementsByDateRange getInventoryMovementsByDateRange(ref) =>
    GetInventoryMovementsByDateRange(
      ref.watch(inventoryMovementRepositoryProvider),
    );
