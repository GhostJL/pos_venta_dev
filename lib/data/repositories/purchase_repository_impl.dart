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
  Future<void> receivePurchase(
    int purchaseId,
    Map<int, double> receivedQuantities,
    int receivedBy,
  ) async {
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

      bool allItemsCompleted = true;

      // 3. Process each item
      for (final item in itemsResult) {
        final itemId = item['id'] as int;
        final productId = item['product_id'] as int;
        final variantId = item['variant_id'] as int?;
        final quantityOrdered = item['quantity'] as double;
        final quantityReceivedSoFar =
            (item['quantity_received'] as num?)?.toDouble() ?? 0.0;
        final unitCostCents = item['unit_cost_cents'] as int;
        final expirationDate = item['expiration_date'] as String?;

        // Skip if no quantity to receive for this item
        if (!receivedQuantities.containsKey(itemId) ||
            receivedQuantities[itemId]! <= 0) {
          if (quantityReceivedSoFar < quantityOrdered) {
            allItemsCompleted = false;
          }
          continue;
        }

        final quantityToReceive = receivedQuantities[itemId]!;

        // Validate quantity
        if (quantityReceivedSoFar + quantityToReceive > quantityOrdered) {
          throw Exception(
            'Cannot receive more than ordered. Item ID: $itemId, Ordered: $quantityOrdered, Received: $quantityReceivedSoFar, Trying to receive: $quantityToReceive',
          );
        }

        // 3a. Create inventory lot
        final lotNumber = _generateLotNumber();
        final totalCostCents = (unitCostCents * quantityToReceive).toInt();

        final lotId = await txn.insert(DatabaseHelper.tableInventoryLots, {
          'product_id': productId,
          'variant_id': variantId,
          'warehouse_id': warehouseId,
          'lot_number': lotNumber,
          'quantity': quantityToReceive,
          'unit_cost_cents': unitCostCents,
          'total_cost_cents': totalCostCents,
          'expiration_date': expirationDate,
          'received_at': DateTime.now().toIso8601String(),
        });

        // 3b. Update purchase item with lot_id and quantity_received
        await txn.update(
          DatabaseHelper.tablePurchaseItems,
          {
            'quantity_received': quantityReceivedSoFar + quantityToReceive,
            'lot_id': lotId,
          },
          where: 'id = ?',
          whereArgs: [itemId],
        );

        // Check if this item is now fully received
        if (quantityReceivedSoFar + quantityToReceive < quantityOrdered) {
          allItemsCompleted = false;
        }

        // 3c. Get current inventory
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
            'quantity_on_hand': quantityToReceive,
            'quantity_reserved': 0,
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
              quantityToReceive,
              DateTime.now().toIso8601String(),
              productId,
              warehouseId,
            ],
          );
        }

        final quantityAfter = quantityBefore + quantityToReceive;

        // 3d. Create inventory movement (Kardex)
        await txn.insert(DatabaseHelper.tableInventoryMovements, {
          'product_id': productId,
          'warehouse_id': warehouseId,
          'movement_type': 'purchase',
          'quantity': quantityToReceive,
          'quantity_before': quantityBefore,
          'quantity_after': quantityAfter,
          'reference_type': 'purchase',
          'reference_id': purchaseId,
          'lot_id': lotId,
          'reason': 'Purchase received - Lot: $lotNumber',
          'performed_by': receivedBy,
          'movement_date': DateTime.now().toIso8601String(),
        });

        // 3e. Update product variant cost (Last Cost / LIFO policy)
        // Update the main variant's cost (first variant by ID)
        await txn.rawUpdate(
          '''
          UPDATE ${DatabaseHelper.tableProductVariants}
          SET cost_price_cents = ?,
              updated_at = ?
          WHERE product_id = ?
            AND id = (
              SELECT MIN(id) 
              FROM ${DatabaseHelper.tableProductVariants} 
              WHERE product_id = ?
            )
          ''',
          [
            unitCostCents,
            DateTime.now().toIso8601String(),
            productId,
            productId,
          ],
        );
      }

      // 4. Update purchase status
      final newStatus = allItemsCompleted ? 'completed' : 'partial';

      // Only update status if it changed or if it's the first reception
      await txn.update(
        DatabaseHelper.tablePurchases,
        {
          'status': newStatus,
          'received_date': DateTime.now()
              .toIso8601String(), // Update received date to latest reception
          'received_by': receivedBy,
        },
        where: 'id = ?',
        whereArgs: [purchaseId],
      );
    });
  }

  String _generateLotNumber() {
    final now = DateTime.now();
    final dateStr = now.toIso8601String().substring(0, 10).replaceAll('-', '');
    final timeStr = now.toIso8601String().substring(11, 19).replaceAll(':', '');
    return 'LOT-$dateStr-$timeStr';
  }

  @override
  Future<void> cancelPurchase(int purchaseId, int userId) async {
    final db = await _databaseHelper.database;
    await db.transaction((txn) async {
      // 1. Get purchase items to reverse inventory
      final itemsResult = await txn.query(
        DatabaseHelper.tablePurchaseItems,
        where: 'purchase_id = ?',
        whereArgs: [purchaseId],
      );

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

      // 2. Reverse inventory for received items
      for (final item in itemsResult) {
        final quantityReceived = item['quantity_received'] as double;
        final productId = item['product_id'] as int;

        if (quantityReceived > 0) {
          // Deduct from inventory
          await txn.rawUpdate(
            '''
            UPDATE ${DatabaseHelper.tableInventory}
            SET quantity_on_hand = quantity_on_hand - ?
            WHERE product_id = ? AND warehouse_id = ?
          ''',
            [quantityReceived, productId, warehouseId],
          );

          // Create adjustment movement
          // Get current stock for movement record
          final inventoryResult = await txn.query(
            DatabaseHelper.tableInventory,
            where: 'product_id = ? AND warehouse_id = ?',
            whereArgs: [productId, warehouseId],
          );

          final currentStock = inventoryResult.isNotEmpty
              ? (inventoryResult.first['quantity_on_hand'] as double)
              : 0.0;

          await txn.insert(DatabaseHelper.tableInventoryMovements, {
            'product_id': productId,
            'warehouse_id': warehouseId,
            'movement_type': 'adjustment', // Using adjustment for cancellation
            'quantity': -quantityReceived,
            'quantity_before': currentStock + quantityReceived,
            'quantity_after': currentStock,
            'reference_type': 'purchase_cancellation',
            'reference_id': purchaseId,
            'reason': 'Cancelación de Compra',
            'performed_by': userId,
            'movement_date': DateTime.now().toIso8601String(),
          });
        }
      }

      // 3. Update purchase status
      await txn.update(
        DatabaseHelper.tablePurchases,
        {'status': 'cancelled', 'cancelled_by': userId},
        where: 'id = ?',
        whereArgs: [purchaseId],
      );
    });
  }
}
