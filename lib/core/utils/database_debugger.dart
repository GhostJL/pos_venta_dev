import 'package:flutter/material.dart';
import 'package:posventa/data/datasources/local/database/app_database.dart';

/// Debug utility to check database contents
class DatabaseDebugger {
  static Future<void> printDatabaseContents(AppDatabase db) async {
    debugPrint('=== DATABASE DEBUG ===');

    // Check Products
    final products = await db.select(db.products).get();
    debugPrint('Products count: ${products.length}');
    for (var product in products) {
      debugPrint('  Product: id=${product.id}, name=${product.name}');
    }

    // Check Warehouses
    final warehouses = await db.select(db.warehouses).get();
    debugPrint('Warehouses count: ${warehouses.length}');
    for (var warehouse in warehouses) {
      debugPrint('  Warehouse: id=${warehouse.id}, name=${warehouse.name}');
    }

    // Check Inventory
    final inventory = await db.select(db.inventory).get();
    debugPrint('Inventory count: ${inventory.length}');
    for (var item in inventory) {
      debugPrint(
        '  Inventory: id=${item.id}, product_id=${item.productId}, warehouse_id=${item.warehouseId}',
      );
    }

    debugPrint('=== END DEBUG ===');
  }
}
