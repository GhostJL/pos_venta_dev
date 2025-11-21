import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import 'package:posventa/data/datasources/database_helper.dart';
import 'package:posventa/data/repositories/purchase_repository_impl.dart';
import 'package:posventa/domain/entities/purchase.dart';
import 'package:posventa/domain/entities/purchase_item.dart';

void main() {
  // Initialize FFI
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Database db;
  late PurchaseRepositoryImpl purchaseRepository;

  setUp(() async {
    db = await DatabaseHelper.instance.database;

    // Clear tables
    await db.delete(DatabaseHelper.tableInventoryMovements);
    await db.delete(DatabaseHelper.tableInventory);
    await db.delete(DatabaseHelper.tablePurchaseItems);
    await db.delete(DatabaseHelper.tablePurchases);
    await db.delete(DatabaseHelper.tableSaleItemTaxes);
    await db.delete(DatabaseHelper.tableSaleItems);
    await db.delete(DatabaseHelper.tableSalePayments);
    await db.delete(DatabaseHelper.tableSales);
    await db.delete(DatabaseHelper.tableProductTaxes);
    await db.delete(DatabaseHelper.tableProducts);
    await db.delete(DatabaseHelper.tableSuppliers);
    await db.delete(DatabaseHelper.tableWarehouses);
    await db.delete(DatabaseHelper.tableUsers);
    await db.delete(DatabaseHelper.tableCategories);
    await db.delete(DatabaseHelper.tableDepartments);

    purchaseRepository = PurchaseRepositoryImpl(DatabaseHelper.instance);

    // Seed Data
    await db.insert('users', {
      'id': 1,
      'username': 'admin',
      'password_hash': 'hash',
      'role': 'admin',
      'first_name': 'Admin',
      'last_name': 'User',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });

    await db.insert('warehouses', {
      'id': 1,
      'name': 'Main Warehouse',
      'code': 'MAIN',
      'is_main': 1,
    });

    await db.insert('suppliers', {
      'id': 1,
      'name': 'Test Supplier',
      'code': 'SUP001',
    });

    await db.insert('departments', {'id': 1, 'name': 'General', 'code': 'GEN'});
    await db.insert('categories', {
      'id': 1,
      'name': 'General',
      'code': 'GEN',
      'department_id': 1,
    });

    // Product with initial cost 500
    await db.insert('products', {
      'id': 1,
      'code': 'P001',
      'name': 'Test Product',
      'sale_price_cents': 2000,
      'cost_price_cents': 500,
      'department_id': 1,
      'category_id': 1,
    });

    // Initial Inventory: 10 units
    await db.insert('inventory', {
      'product_id': 1,
      'warehouse_id': 1,
      'quantity_on_hand': 10.0,
    });
  });

  test(
    'Purchase Reception Flow: Updates Cost, Inventory, and Creates Movement',
    () async {
      // 1. Create a Purchase (Pending)
      // We are buying 50 units at cost 800 (different from initial 500)
      final purchase = Purchase(
        purchaseNumber: 'PUR-001',
        supplierId: 1,
        warehouseId: 1,
        subtotalCents: 40000,
        taxCents: 0,
        totalCents: 40000,
        status: PurchaseStatus.pending,
        purchaseDate: DateTime.now(),
        createdAt: DateTime.now(),
        requestedBy: 1,
        items: [
          PurchaseItem(
            productId: 1,
            quantity: 50,
            unitOfMeasure: 'pieza',
            unitCostCents: 800, // New Cost
            subtotalCents: 40000,
            totalCents: 40000,
            createdAt: DateTime.now(),
          ),
        ],
      );

      final purchaseId = await purchaseRepository.createPurchase(purchase);

      // 2. Receive Purchase
      await purchaseRepository.receivePurchase(purchaseId, 1);

      // 3. Verify Product Cost Update (Rule: Update Cost)
      final product = await db.query(
        'products',
        where: 'id = ?',
        whereArgs: [1],
      );
      expect(
        product.first['cost_price_cents'],
        800,
        reason: 'Product cost should be updated to last purchase cost',
      );

      // 4. Verify Inventory Update (Rule: Add Quantity)
      final inventory = await db.query(
        'inventory',
        where: 'product_id = ? AND warehouse_id = ?',
        whereArgs: [1, 1],
      );
      // Initial 10 + Received 50 = 60
      expect(
        inventory.first['quantity_on_hand'],
        60.0,
        reason: 'Inventory quantity should increase by purchase amount',
      );

      // 5. Verify Kardex Movement (Rule: Insert Movement)
      final movements = await db.query(
        'inventory_movements',
        where: "movement_type = 'purchase' AND reference_id = ?",
        whereArgs: [purchaseId],
      );

      expect(
        movements.length,
        1,
        reason: 'Should create exactly one movement record',
      );
      final movement = movements.first;
      expect(
        movement['quantity'],
        50.0,
        reason: 'Movement quantity should be positive',
      );
      expect(
        movement['quantity_before'],
        10.0,
        reason: 'Quantity before should match pre-reception stock',
      );
      expect(
        movement['quantity_after'],
        60.0,
        reason: 'Quantity after should match post-reception stock',
      );
      expect(
        movement['performed_by'],
        1,
        reason: 'Performed by should match user ID',
      );

      // 6. Verify Purchase Status
      final updatedPurchase = await db.query(
        'purchases',
        where: 'id = ?',
        whereArgs: [purchaseId],
      );
      expect(
        updatedPurchase.first['status'],
        'completed',
        reason: 'Purchase status should be completed',
      );
    },
  );
}
