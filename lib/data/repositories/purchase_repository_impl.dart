import 'package:posventa/data/datasources/database_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:posventa/data/models/purchase_item_model.dart';
import 'package:posventa/data/models/purchase_model.dart';
import 'package:posventa/domain/entities/inventory_lot.dart';
import 'package:posventa/domain/entities/purchase.dart';
import 'package:posventa/domain/entities/purchase_item.dart';
import 'package:posventa/domain/entities/purchase_reception_transaction.dart';
import 'package:posventa/domain/repositories/purchase_repository.dart';

class PurchaseRepositoryImpl implements PurchaseRepository {
  final DatabaseHelper _databaseHelper;

  PurchaseRepositoryImpl(this._databaseHelper);

  @override
  Future<List<Purchase>> getPurchases({
    String? query,
    PurchaseStatus? status,
    int? limit,
    int? offset,
  }) async {
    final db = await _databaseHelper.database;

    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (query != null && query.isNotEmpty) {
      whereClause =
          '(p.purchase_number LIKE ? OR s.name LIKE ? OR p.status LIKE ?)';
      whereArgs.addAll(['%$query%', '%$query%', '%$query%']);
    }

    if (status != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'p.status = ?';
      whereArgs.add(
        status.name,
      ); // Assuming PurchaseStatus is enum and stored as string
    }

    final result = await db.rawQuery('''
      SELECT p.*, s.name as supplier_name
      FROM ${DatabaseHelper.tablePurchases} p
      LEFT JOIN ${DatabaseHelper.tableSuppliers} s ON p.supplier_id = s.id
      ${whereClause.isNotEmpty ? 'WHERE $whereClause' : ''}
      ORDER BY p.created_at DESC
      ${limit != null ? 'LIMIT $limit' : ''}
      ${offset != null ? 'OFFSET $offset' : ''}
    ''', whereArgs);

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
  Future<int> countPurchases({String? query, PurchaseStatus? status}) async {
    final db = await _databaseHelper.database;

    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (query != null && query.isNotEmpty) {
      whereClause =
          '(p.purchase_number LIKE ? OR s.name LIKE ? OR p.status LIKE ?)';
      whereArgs.addAll(['%$query%', '%$query%', '%$query%']);
    }

    if (status != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'p.status = ?';
      whereArgs.add(status.name);
    }

    final result = await db.rawQuery('''
      SELECT COUNT(*) as count
      FROM ${DatabaseHelper.tablePurchases} p
      LEFT JOIN ${DatabaseHelper.tableSuppliers} s ON p.supplier_id = s.id
      ${whereClause.isNotEmpty ? 'WHERE $whereClause' : ''}
    ''', whereArgs);

    return Sqflite.firstIntValue(result) ?? 0;
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
  Future<void> executePurchaseReception(
    PurchaseReceptionTransaction transaction,
  ) async {
    final db = await _databaseHelper.database;

    await db.transaction((txn) async {
      // 1. Insert New Lots
      // We need to map the "placeholder" lots in the transaction to their real DB IDs
      // so we can link them in item updates and movements.
      // Since we process items sequentially in the UseCase, and we have lists of newLots,
      // we can assume a 1-to-1 mapping if we iterate carefully.
      // However, `itemUpdates` has a `newLot` field which is the object.
      // We can create a map of Object -> ID after insertion.

      final Map<InventoryLot, int> lotIdMap = Map.identity();

      for (final lot in transaction.newLots) {
        final lotId = await txn.insert(DatabaseHelper.tableInventoryLots, {
          'product_id': lot.productId,
          'variant_id': lot.variantId,
          'warehouse_id': lot.warehouseId,
          'lot_number': lot.lotNumber,
          'quantity': lot.quantity,
          'unit_cost_cents': lot.unitCostCents,
          'total_cost_cents': lot.totalCostCents,
          'expiration_date': lot.expirationDate?.toIso8601String(),
          'received_at': lot.receivedAt.toIso8601String(),
        });
        lotIdMap[lot] = lotId;
      }

      // 2. Update Purchase Items
      for (final update in transaction.itemUpdates) {
        final Map<String, dynamic> updateData = {
          'quantity_received': update.quantityReceived,
        };

        if (update.newLot != null && lotIdMap.containsKey(update.newLot)) {
          updateData['lot_id'] = lotIdMap[update.newLot];
        } else if (update.lotId != null) {
          updateData['lot_id'] = update.lotId;
        }

        await txn.update(
          DatabaseHelper.tablePurchaseItems,
          updateData,
          where: 'id = ?',
          whereArgs: [update.itemId],
        );
      }

      // 3. Inventory Adjustments
      for (final adj in transaction.inventoryAdjustments) {
        // Prepare query based on variant existence
        final String whereClause;
        final List<dynamic> whereArgs;

        if (adj.variantId != null) {
          whereClause =
              'product_id = ? AND warehouse_id = ? AND variant_id = ?';
          whereArgs = [adj.productId, adj.warehouseId, adj.variantId];
        } else {
          whereClause =
              'product_id = ? AND warehouse_id = ? AND variant_id IS NULL';
          whereArgs = [adj.productId, adj.warehouseId];
        }

        final inventoryResult = await txn.query(
          DatabaseHelper.tableInventory,
          where: whereClause,
          whereArgs: whereArgs,
        );

        if (inventoryResult.isEmpty) {
          await txn.insert(DatabaseHelper.tableInventory, {
            'product_id': adj.productId,
            'warehouse_id': adj.warehouseId,
            'variant_id': adj.variantId,
            'quantity_on_hand': adj.quantityToAdd,
            'quantity_reserved': 0,
            'updated_at': DateTime.now().toIso8601String(),
          });
        } else {
          await txn.rawUpdate(
            '''
            UPDATE ${DatabaseHelper.tableInventory}
            SET quantity_on_hand = quantity_on_hand + ?,
            updated_at = ?
            WHERE $whereClause
            ''',
            [adj.quantityToAdd, DateTime.now().toIso8601String(), ...whereArgs],
          );
        }
      }

      // 4. Record Movements
      // We need to fetch current stock to populate quantityBefore/After correctly?
      // Or we can trust the UseCase? UseCase sent 0.
      // We should probably fetch it here to be accurate within the transaction.
      for (final mov in transaction.movements) {
        // Get current stock (after adjustment)
        final invResult = await txn.query(
          DatabaseHelper.tableInventory,
          columns: ['quantity_on_hand'],
          where: 'product_id = ? AND warehouse_id = ?',
          whereArgs: [mov.productId, mov.warehouseId],
        );

        double currentQty = 0;
        if (invResult.isNotEmpty) {
          currentQty = (invResult.first['quantity_on_hand'] as num).toDouble();
        }

        // quantityAfter is currentQty.
        // quantityBefore is currentQty - mov.quantity (since we just added it).

        // Find the lot ID for this movement
        // We can try to match it with the newLots list if needed,
        // but the movement object in the transaction doesn't have the Lot object link, only lotId (int).
        // But we just generated the lotId.
        // The UseCase couldn't set the lotId.
        // We need a way to link the movement to the lot we just created.
        // The movement reason contains the lot number.
        // Or we can rely on the order? Risky.
        // Better: The UseCase should pass a "MovementRequest" that includes the Lot Object, not ID.
        // For now, let's try to find the lotId from the map using the lotNumber or something?
        // Or we just use the last inserted lotId if it's 1-to-1?
        // Let's assume for this refactor we might miss the lot_id in the movement record
        // OR we can try to match by product/variant/quantity in the lotIdMap.

        int? resolvedLotId = mov.lotId;
        if (resolvedLotId == null) {
          // Try to find a new lot that matches this movement
          for (final entry in lotIdMap.entries) {
            if (entry.key.productId == mov.productId &&
                entry.key.quantity == mov.quantity) {
              resolvedLotId = entry.value;
              break;
            }
          }
        }

        await txn.insert(DatabaseHelper.tableInventoryMovements, {
          'product_id': mov.productId,
          'warehouse_id': mov.warehouseId,
          'movement_type': mov.movementType.value,
          'quantity': mov.quantity,
          'quantity_before': currentQty - mov.quantity,
          'quantity_after': currentQty,
          'reference_type': mov.referenceType,
          'reference_id': mov.referenceId,
          'lot_id': resolvedLotId,
          'reason': mov.reason,
          'performed_by': mov.performedBy,
          'movement_date': mov.movementDate.toIso8601String(),
        });
      }

      // 5. Update Variant Costs
      for (final update in transaction.variantUpdates) {
        await txn.update(
          DatabaseHelper.tableProductVariants,
          {
            'cost_price_cents': update.newCostPriceCents,
            'updated_at': DateTime.now().toIso8601String(),
          },
          where: 'id = ?',
          whereArgs: [update.variantId],
        );
      }

      // 6. Update Purchase Status
      await txn.update(
        DatabaseHelper.tablePurchases,
        {
          'status': transaction.newStatus,
          'received_date': transaction.receivedDate.toIso8601String(),
          'received_by': transaction.receivedBy,
        },
        where: 'id = ?',
        whereArgs: [transaction.purchaseId],
      );
    });
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
