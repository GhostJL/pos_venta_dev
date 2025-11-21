import 'package:flutter/material.dart';
import 'package:posventa/data/datasources/database_helper.dart';

/// Debug utility to check database contents
class DatabaseDebugger {
  static Future<void> printDatabaseContents() async {
    final db = await DatabaseHelper.instance.database;

    debugPrint('=== DATABASE DEBUG ===');

    // Check Products
    final products = await db.query(DatabaseHelper.tableProducts);
    debugPrint('Products count: ${products.length}');
    for (var product in products) {
      debugPrint('  Product: id=${product['id']}, name=${product['name']}');
    }

    // Check Warehouses
    final warehouses = await db.query(DatabaseHelper.tableWarehouses);
    debugPrint('Warehouses count: ${warehouses.length}');
    for (var warehouse in warehouses) {
      debugPrint(
        '  Warehouse: id=${warehouse['id']}, name=${warehouse['name']}',
      );
    }

    // Check Inventory
    final inventory = await db.query(DatabaseHelper.tableInventory);
    debugPrint('Inventory count: ${inventory.length}');
    for (var item in inventory) {
      debugPrint(
        '  Inventory: id=${item['id']}, product_id=${item['product_id']}, warehouse_id=${item['warehouse_id']}',
      );
    }

    debugPrint('=== END DEBUG ===');
  }
}
