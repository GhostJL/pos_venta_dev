import 'package:posventa/data/datasources/database_helper.dart';
import 'package:posventa/data/repositories/warehouse_repository_impl.dart';
import 'package:posventa/domain/repositories/warehouse_repository.dart';
import 'package:posventa/domain/use_cases/create_warehouse.dart';
import 'package:posventa/domain/use_cases/delete_warehouse.dart';
import 'package:posventa/domain/use_cases/get_all_warehouses.dart';
import 'package:posventa/domain/use_cases/update_warehouse.dart';
import 'package:posventa/domain/repositories/inventory_repository.dart';
import 'package:posventa/data/repositories/inventory_repository_impl.dart';
import 'package:posventa/domain/use_cases/get_all_inventory.dart';
import 'package:posventa/domain/use_cases/create_inventory.dart';
import 'package:posventa/domain/use_cases/update_inventory.dart';
import 'package:posventa/domain/use_cases/delete_inventory.dart';
import 'package:posventa/domain/use_cases/get_inventory_by_product.dart';
import 'package:posventa/domain/repositories/product_repository.dart';
import 'package:posventa/data/repositories/product_repository_impl.dart';
import 'package:posventa/domain/use_cases/get_all_products.dart';
import 'package:posventa/domain/use_cases/create_product.dart';
import 'package:posventa/domain/use_cases/update_product.dart';
import 'package:posventa/domain/use_cases/delete_product.dart';
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
