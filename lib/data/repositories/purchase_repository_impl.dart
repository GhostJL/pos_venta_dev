import 'package:posventa/data/datasources/database_helper.dart';
import 'package:posventa/data/models/purchase_item_model.dart';
import 'package:posventa/data/models/purchase_model.dart';
import 'package:posventa/domain/entities/purchase.dart';
import 'package:posventa/domain/entities/purchase_item.dart';
import 'package:posventa/domain/repositories/purchase_repository.dart';

class PurchaseRepositoryImpl implements PurchaseRepository {
  final DatabaseHelper _databaseHelper;

  PurchaseRepositoryImpl(this._databaseHelper);

  @override
  Future<List<Purchase>> getPurchases() async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery('''
      SELECT p.*, s.name as supplier_name
      FROM ${DatabaseHelper.tablePurchases} p
      LEFT JOIN ${DatabaseHelper.tableSuppliers} s ON p.supplier_id = s.id
      ORDER BY p.created_at DESC
    ''');

    final List<Purchase> purchases = [];
    for (final row in result) {
      final purchaseModel = PurchaseModel.fromJson(row);
      final itemsResult = await db.query(
        DatabaseHelper.tablePurchaseItems,
        where: 'purchase_id = ?',
        whereArgs: [purchaseModel.id],
      );
      final items = itemsResult
          .map((i) => PurchaseItemModel.fromJson(i))
          .toList();
      purchases.add(purchaseModel.copyWith(items: items));
    }

    return purchases;
  }

  @override
  Future<Purchase?> getPurchaseById(int id) async {
    final db = await _databaseHelper.database;

    // Get purchase details
    final purchaseResult = await db.rawQuery(
      '''
      SELECT p.*, s.name as supplier_name
      FROM ${DatabaseHelper.tablePurchases} p
      LEFT JOIN ${DatabaseHelper.tableSuppliers} s ON p.supplier_id = s.id
      WHERE p.id = ?
    ''',
      [id],
    );

    if (purchaseResult.isEmpty) return null;

    final purchaseData = purchaseResult.first;

    // Get purchase items
    final itemsResult = await db.rawQuery(
      '''
      SELECT pi.*, pr.name as product_name
      FROM ${DatabaseHelper.tablePurchaseItems} pi
      LEFT JOIN ${DatabaseHelper.tableProducts} pr ON pi.product_id = pr.id
      WHERE pi.purchase_id = ?
    ''',
      [id],
    );

    final List<PurchaseItem> items = itemsResult
        .map((json) => PurchaseItemModel.fromJson(json))
        .toList();
    return PurchaseModel.fromJson(purchaseData).copyWith(items: items);
  }

  @override
  Future<int> createPurchase(Purchase purchase) async {
    final db = await _databaseHelper.database;
    return await db.transaction((txn) async {
      final purchaseModel = PurchaseModel.fromEntity(purchase);
      final purchaseId = await txn.insert(
        DatabaseHelper.tablePurchases,
        purchaseModel.toMap()..remove('id'),
      );

      for (final item in purchase.items) {
        final itemModel = PurchaseItemModel.fromEntity(item);
        await txn.insert(
          DatabaseHelper.tablePurchaseItems,
          itemModel.toMap()
            ..remove('id')
            ..['purchase_id'] = purchaseId,
        );
      }
      return purchaseId;
    });
  }

  @override
  Future<void> updatePurchase(Purchase purchase) async {
    final db = await _databaseHelper.database;
    await db.transaction((txn) async {
      final purchaseModel = PurchaseModel.fromEntity(purchase);
      await txn.update(
        DatabaseHelper.tablePurchases,
        purchaseModel.toMap(),
        where: 'id = ?',
        whereArgs: [purchase.id],
      );

      await txn.delete(
        DatabaseHelper.tablePurchaseItems,
        where: 'purchase_id = ?',
        whereArgs: [purchase.id],
      );

      for (final item in purchase.items) {
        final itemModel = PurchaseItemModel.fromEntity(item);
        await txn.insert(
          DatabaseHelper.tablePurchaseItems,
          itemModel.toMap()
            ..remove('id')
            ..['purchase_id'] = purchase.id,
        );
      }
    });
  }

  @override
  Future<void> deletePurchase(int id) async {
    final db = await _databaseHelper.database;
    await db.delete(
      DatabaseHelper.tablePurchases,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> receivePurchase(int purchaseId, int receivedBy) async {
    final db = await _databaseHelper.database;

    await db.transaction((txn) async {
      // 1. Get purchase details
      final purchaseResult = await txn.query(
        DatabaseHelper.tablePurchases,
        where: 'id = ?',
        whereArgs: [purchaseId],
      );

      if (purchaseResult.isEmpty) {
        throw Exception('Purchase not found');
      }

      final purchase = purchaseResult.first;
      final warehouseId = purchase['warehouse_id'] as int;

      // 2. Get purchase items
      final itemsResult = await txn.query(
        DatabaseHelper.tablePurchaseItems,
        where: 'purchase_id = ?',
        whereArgs: [purchaseId],
      );

      // 3. Process each item
      for (final item in itemsResult) {
        final productId = item['product_id'] as int;
        final quantity = item['quantity'] as double;
        final unitCostCents = item['unit_cost_cents'] as int;
        final lotNumber = item['lot_number'] as String?;

        // 3a. Get current inventory
        final inventoryResult = await txn.query(
          DatabaseHelper.tableInventory,
          where: 'product_id = ? AND warehouse_id = ?',
          whereArgs: [productId, warehouseId],
        );

        double quantityBefore = 0;

        if (inventoryResult.isEmpty) {
          // Create new inventory record
          await txn.insert(DatabaseHelper.tableInventory, {
            'product_id': productId,
            'warehouse_id': warehouseId,
            'quantity_on_hand': quantity,
            'quantity_reserved': 0,
            'lot_number': lotNumber,
            'updated_at': DateTime.now().toIso8601String(),
          });
        } else {
          // Update existing inventory
          quantityBefore = (inventoryResult.first['quantity_on_hand'] as num)
              .toDouble();
          await txn.rawUpdate(
            '''
            UPDATE ${DatabaseHelper.tableInventory}
            SET quantity_on_hand = quantity_on_hand + ?,
                updated_at = ?
            WHERE product_id = ? AND warehouse_id = ?
          ''',
            [
              quantity,
              DateTime.now().toIso8601String(),
              productId,
              warehouseId,
            ],
          );
        }

        final quantityAfter = quantityBefore + quantity;

        // 3b. Create inventory movement (Kardex)
        await txn.insert(DatabaseHelper.tableInventoryMovements, {
          'product_id': productId,
          'warehouse_id': warehouseId,
          'movement_type': 'purchase',
          'quantity': quantity,
          'quantity_before': quantityBefore,
          'quantity_after': quantityAfter,
          'reference_type': 'purchase',
          'reference_id': purchaseId,
          'lot_number': lotNumber,
          'reason': 'Purchase received',
          'performed_by': receivedBy,
          'movement_date': DateTime.now().toIso8601String(),
        });

        // 3c. Update product cost (Last Cost / LIFO policy)
        await txn.update(
          DatabaseHelper.tableProducts,
          {
            'cost_price_cents': unitCostCents,
            'updated_at': DateTime.now().toIso8601String(),
          },
          where: 'id = ?',
          whereArgs: [productId],
        );
      }

      // 4. Update purchase status
      await txn.update(
        DatabaseHelper.tablePurchases,
        {
          'status': 'completed',
          'received_date': DateTime.now().toIso8601String(),
          'received_by': receivedBy,
        },
        where: 'id = ?',
        whereArgs: [purchaseId],
      );
    });
  }
}
