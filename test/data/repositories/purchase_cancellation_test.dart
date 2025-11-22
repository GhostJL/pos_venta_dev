import 'package:flutter_test/flutter_test.dart';
import 'package:posventa/data/datasources/database_helper.dart';
import 'package:posventa/data/repositories/purchase_repository_impl.dart';
import 'package:posventa/domain/entities/purchase.dart';
import 'package:posventa/domain/entities/purchase_item.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late PurchaseRepositoryImpl purchaseRepository;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    await DatabaseHelper().resetDatabase();
    purchaseRepository = PurchaseRepositoryImpl(DatabaseHelper());
  });

  test(
    'Purchase Cancellation Flow: Reverses Inventory and Updates Status',
    () async {
      // 1. Create a Purchase
      final purchase = Purchase(
        purchaseNumber: 'PUR-CANCEL-001',
        supplierId: 1, // Assuming seed data exists or we need to create it
        warehouseId: 1,
        subtotalCents: 10000,
        totalCents: 11600,
        purchaseDate: DateTime.now(),
        requestedBy: 1,
        createdAt: DateTime.now(),
        items: [
          PurchaseItem(
            productId: 1,
            quantity: 10,
            unitOfMeasure: 'pieza',
            unitCostCents: 1000,
            subtotalCents: 10000,
            taxCents: 1600,
            totalCents: 11600,
            createdAt: DateTime.now(),
          ),
        ],
      );

      // We need to ensure dependencies (Supplier, Warehouse, Product, User) exist.
      // The resetDatabase() might clear them. We should probably use the existing seed data logic or insert them manually.
      final db = await DatabaseHelper().database;
      await db.insert('users', {
        'username': 'admin',
        'password_hash': 'hash',
        'role': 'admin',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
      await db.insert('warehouses', {
        'name': 'Main',
        'code': 'MAIN',
        'created_at': DateTime.now().toIso8601String(),
      });
      await db.insert('suppliers', {
        'name': 'Supplier',
        'code': 'SUP',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
      await db.insert('departments', {'name': 'Dept', 'code': 'DEPT'});
      await db.insert('categories', {
        'name': 'Cat',
        'code': 'CAT',
        'department_id': 1,
      });
      await db.insert('products', {
        'name': 'Product 1',
        'code': 'PROD1',
        'sale_price_cents': 2000,
        'department_id': 1,
        'category_id': 1,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      final purchaseId = await purchaseRepository.createPurchase(purchase);

      // 2. Receive Partial Quantity (5 items)
      // We need to get the item ID
      final createdPurchase = await purchaseRepository.getPurchaseById(
        purchaseId,
      );
      final itemId = createdPurchase!.items.first.id!;

      await purchaseRepository.receivePurchase(purchaseId, {itemId: 5.0}, 1);

      // Verify Inventory increased by 5
      var inventory = await db.query(
        'inventory',
        where: 'product_id = ?',
        whereArgs: [1],
      );
      expect(inventory.first['quantity_on_hand'], 5.0);

      // 3. Cancel Purchase
      await purchaseRepository.cancelPurchase(purchaseId, 1);

      // 4. Verify Status is Cancelled
      final cancelledPurchase = await purchaseRepository.getPurchaseById(
        purchaseId,
      );
      expect(cancelledPurchase!.status, PurchaseStatus.cancelled);

      // 5. Verify Inventory is Reversed (Should be 0)
      inventory = await db.query(
        'inventory',
        where: 'product_id = ?',
        whereArgs: [1],
      );
      expect(inventory.first['quantity_on_hand'], 0.0);

      // 6. Verify Adjustment Movement
      final movements = await db.query(
        'inventory_movements',
        where: 'reference_id = ? AND movement_type = ?',
        whereArgs: [purchaseId, 'adjustment'],
      );
      expect(movements.length, 1);
      expect(movements.first['quantity'], -5.0);
      expect(movements.first['reason'], 'Cancelación de Compra');
    },
  );
}
