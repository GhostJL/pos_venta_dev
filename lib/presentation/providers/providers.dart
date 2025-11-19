import 'package:posventa/data/datasources/database_helper.dart';
import 'package:posventa/data/repositories/warehouse_repository_impl.dart';
import 'package:posventa/domain/repositories/warehouse_repository.dart';
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
import 'package:posventa/domain/repositories/product_repository.dart';
import 'package:posventa/data/repositories/product_repository_impl.dart';
import 'package:posventa/domain/use_cases/product/get_all_products.dart';
import 'package:posventa/domain/use_cases/product/create_product.dart';
import 'package:posventa/domain/use_cases/product/update_product.dart';
import 'package:posventa/domain/use_cases/product/delete_product.dart';
import 'package:posventa/domain/repositories/inventory_movement_repository.dart';
import 'package:posventa/data/repositories/inventory_movement_repository_impl.dart';
import 'package:posventa/domain/use_cases/inventory_movement/get_all_inventory_movements.dart';
import 'package:posventa/domain/use_cases/inventory_movement/create_inventory_movement.dart';
import 'package:posventa/domain/use_cases/inventory_movement/update_inventory_movement.dart';
import 'package:posventa/domain/use_cases/inventory_movement/delete_inventory_movement.dart';
import 'package:posventa/domain/use_cases/inventory_movement/get_inventory_movements_by_product.dart';
import 'package:posventa/domain/use_cases/inventory_movement/get_inventory_movements_by_warehouse.dart';
import 'package:posventa/domain/use_cases/inventory_movement/get_inventory_movements_by_date_range.dart';
import 'package:posventa/domain/repositories/user_repository.dart';
import 'package:posventa/data/repositories/auth_repository_impl.dart';
import 'package:posventa/domain/use_cases/user/get_all_users.dart';
import 'package:posventa/domain/use_cases/user/create_user.dart';
import 'package:posventa/domain/use_cases/user/update_user.dart';
import 'package:posventa/domain/use_cases/user/delete_user.dart';
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

// Inventory Providers
@riverpod
InventoryRepository inventoryRepository(ref) =>
    InventoryRepositoryImpl(ref.watch(databaseHelperProvider));

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

// Product Providers
@riverpod
ProductRepository productRepository(ref) =>
    ProductRepositoryImpl(ref.watch(databaseHelperProvider));

@riverpod
GetAllProducts getAllProducts(ref) =>
    GetAllProducts(ref.watch(productRepositoryProvider));

@riverpod
CreateProduct createProduct(ref) =>
    CreateProduct(ref.watch(productRepositoryProvider));

@riverpod
UpdateProduct updateProduct(ref) =>
    UpdateProduct(ref.watch(productRepositoryProvider));

@riverpod
DeleteProduct deleteProduct(ref) =>
    DeleteProduct(ref.watch(productRepositoryProvider));

// Inventory Movement Providers
@riverpod
InventoryMovementRepository inventoryMovementRepository(ref) =>
    InventoryMovementRepositoryImpl(ref.watch(databaseHelperProvider));

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

// User Providers
@riverpod
UserRepository userRepository(ref) =>
    AuthRepositoryImpl(ref.watch(databaseHelperProvider));

@riverpod
GetAllUsers getAllUsers(ref) => GetAllUsers(ref.watch(userRepositoryProvider));

@riverpod
CreateUser createUser(ref) => CreateUser(ref.watch(userRepositoryProvider));

@riverpod
UpdateUser updateUser(ref) => UpdateUser(ref.watch(userRepositoryProvider));

@riverpod
DeleteUser deleteUser(ref) => DeleteUser(ref.watch(userRepositoryProvider));
