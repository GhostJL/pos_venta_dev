import 'package:posventa/data/datasources/database_helper.dart';
import 'package:posventa/data/models/sale_item_model.dart';
import 'package:posventa/data/models/sale_model.dart';
import 'package:posventa/data/models/sale_item_tax_model.dart';
import 'package:posventa/data/models/sale_payment_model.dart';
import 'package:posventa/domain/entities/sale.dart';
import 'package:posventa/domain/entities/sale_transaction.dart';
import 'package:posventa/domain/repositories/sale_repository.dart';

class SaleRepositoryImpl implements SaleRepository {
  final DatabaseHelper _databaseHelper;

  SaleRepositoryImpl(this._databaseHelper);

  @override
  Future<List<Sale>> getSales({
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  }) async {
    final db = await _databaseHelper.database;

    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (startDate != null) {
      whereClause += 'sale_date >= ?';
      whereArgs.add(startDate.toIso8601String());
    }

    if (endDate != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'sale_date <= ?';
      whereArgs.add(endDate.toIso8601String());
    }

    final result = await db.rawQuery('''
      SELECT s.*, c.first_name || ' ' || c.last_name as customer_name
      FROM ${DatabaseHelper.tableSales} s
      LEFT JOIN ${DatabaseHelper.tableCustomers} c ON s.customer_id = c.id
      ${whereClause.isNotEmpty ? 'WHERE $whereClause' : ''}
      ORDER BY s.sale_date DESC
      ${limit != null ? 'LIMIT $limit' : ''}
      ${offset != null ? 'OFFSET $offset' : ''}
    ''', whereArgs);

    // Load items for each sale
    final sales = <Sale>[];
    for (final saleData in result) {
      final saleId = saleData['id'] as int;

      // Get items
      final itemsResult = await db.rawQuery(
        '''
        SELECT si.*, p.name as product_name
        FROM ${DatabaseHelper.tableSaleItems} si
        LEFT JOIN ${DatabaseHelper.tableProducts} p ON si.product_id = p.id
        WHERE si.sale_id = ?
      ''',
        [saleId],
      );

      final items = <SaleItemModel>[];
      for (final itemData in itemsResult) {
        final itemId = itemData['id'] as int;
        final taxesResult = await db.query(
          DatabaseHelper.tableSaleItemTaxes,
          where: 'sale_item_id = ?',
          whereArgs: [itemId],
        );
        final taxes = taxesResult
            .map((e) => SaleItemTaxModel.fromJson(e))
            .toList();
        items.add(SaleItemModel.fromJson(itemData).copyWith(taxes: taxes));
      }

      final sale = SaleModel.fromJson(saleData).copyWith(items: items);
      sales.add(sale);
    }

    return sales;
  }

  @override
  Future<Sale?> getSaleById(int id) async {
    final db = await _databaseHelper.database;

    // Get Sale
    final saleResult = await db.rawQuery(
      '''
      SELECT s.*, c.first_name || ' ' || c.last_name as customer_name
      FROM ${DatabaseHelper.tableSales} s
      LEFT JOIN ${DatabaseHelper.tableCustomers} c ON s.customer_id = c.id
      WHERE s.id = ?
    ''',
      [id],
    );

    if (saleResult.isEmpty) return null;

    final saleData = saleResult.first;

    // Get Items
    final itemsResult = await db.rawQuery(
      '''
      SELECT si.*, p.name as product_name
      FROM ${DatabaseHelper.tableSaleItems} si
      LEFT JOIN ${DatabaseHelper.tableProducts} p ON si.product_id = p.id
      WHERE si.sale_id = ?
    ''',
      [id],
    );

    final items = <SaleItemModel>[];
    for (final itemData in itemsResult) {
      final itemId = itemData['id'] as int;
      final taxesResult = await db.query(
        DatabaseHelper.tableSaleItemTaxes,
        where: 'sale_item_id = ?',
        whereArgs: [itemId],
      );
      final taxes = taxesResult
          .map((e) => SaleItemTaxModel.fromJson(e))
          .toList();
      items.add(SaleItemModel.fromJson(itemData).copyWith(taxes: taxes));
    }

    // Get Payments
    final paymentsResult = await db.query(
      DatabaseHelper.tableSalePayments,
      where: 'sale_id = ?',
      whereArgs: [id],
    );

    final payments = paymentsResult
        .map((e) => SalePaymentModel.fromJson(e))
        .toList();

    return SaleModel.fromJson(
      saleData,
    ).copyWith(items: items, payments: payments);
  }

  @override
  Future<Sale?> getSaleByNumber(String saleNumber) async {
    final db = await _databaseHelper.database;
    final result = await db.query(
      DatabaseHelper.tableSales,
      where: 'sale_number = ?',
      whereArgs: [saleNumber],
    );

    if (result.isNotEmpty) {
      return getSaleById(result.first['id'] as int);
    }
    return null;
  }

  @override
  Stream<List<Sale>> getSalesStream({
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  }) async* {
    // Yield initial data
    yield await getSales(
      startDate: startDate,
      endDate: endDate,
      limit: limit,
      offset: offset,
    );

    // Listen for updates
    await for (final table in _databaseHelper.tableUpdateStream) {
      if (table == DatabaseHelper.tableSales ||
          table == DatabaseHelper.tableSaleItems) {
        yield await getSales(
          startDate: startDate,
          endDate: endDate,
          limit: limit,
          offset: offset,
        );
      }
    }
  }

  @override
  Future<int> executeSaleTransaction(SaleTransaction transaction) async {
    final db = await _databaseHelper.database;

    final saleId = await db.transaction((txn) async {
      // 1. Insert Sale
      final saleModel = SaleModel.fromEntity(transaction.sale);
      final saleId = await txn.insert(
        DatabaseHelper.tableSales,
        saleModel.toMap(),
      );

      // 2. Insert Items and Taxes
      final Map<int, int> saleItemIdMap =
          {}; // Map original item index to DB ID

      for (int i = 0; i < transaction.sale.items.length; i++) {
        final item = transaction.sale.items[i];
        final itemModel = SaleItemModel.fromEntity(item);
        final itemMap = itemModel.toMap();
        itemMap['sale_id'] = saleId;

        final saleItemId = await txn.insert(
          DatabaseHelper.tableSaleItems,
          itemMap,
        );

        saleItemIdMap[i] = saleItemId;

        // Insert Item Taxes
        for (final tax in item.taxes) {
          final taxModel = SaleItemTaxModel.fromEntity(tax);
          final taxMap = taxModel.toMap();
          taxMap['sale_item_id'] = saleItemId;
          await txn.insert(DatabaseHelper.tableSaleItemTaxes, taxMap);
        }
      }

      // 3. Process Lot Deductions (prepared by Use Case)
      for (int i = 0; i < transaction.lotDeductions.length; i++) {
        final itemDeduction = transaction.lotDeductions[i];
        final saleItemId = saleItemIdMap[i]!;
        int? primaryLotId;

        for (final deduction in itemDeduction.deductions) {
          // Update lot quantity
          await txn.rawUpdate(
            '''
            UPDATE ${DatabaseHelper.tableInventoryLots}
            SET quantity = quantity - ?
            WHERE id = ?
            ''',
            [deduction.quantityToDeduct, deduction.lotId],
          );

          // Track lot deduction for restoration
          await txn.insert(DatabaseHelper.tableSaleItemLots, {
            'sale_item_id': saleItemId,
            'lot_id': deduction.lotId,
            'quantity_deducted': deduction.quantityToDeduct,
            'created_at': DateTime.now().toIso8601String(),
          });

          // Store first lot as primary
          primaryLotId ??= deduction.lotId;
        }

        // Update sale_item with primary lot_id
        if (primaryLotId != null) {
          await txn.update(
            DatabaseHelper.tableSaleItems,
            {'lot_id': primaryLotId},
            where: 'id = ?',
            whereArgs: [saleItemId],
          );
        }
      }

      // 4. Update Inventory (prepared by Use Case)
      for (final adj in transaction.inventoryAdjustments) {
        await txn.rawUpdate(
          '''
          UPDATE ${DatabaseHelper.tableInventory}
          SET quantity_on_hand = quantity_on_hand - ?,
              updated_at = ?
          WHERE product_id = ? AND warehouse_id = ?
          ''',
          [
            adj.quantityToDeduct,
            DateTime.now().toIso8601String(),
            adj.productId,
            adj.warehouseId,
          ],
        );
      }

      // 5. Record Movements (prepared by Use Case)
      for (final mov in transaction.movements) {
        // Get current stock for accurate before/after
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

        await txn.insert(DatabaseHelper.tableInventoryMovements, {
          'product_id': mov.productId,
          'warehouse_id': mov.warehouseId,
          'movement_type': mov.movementType.value,
          'quantity': mov.quantity,
          'quantity_before': currentQty - mov.quantity, // Before deduction
          'quantity_after': currentQty,
          'reference_type': mov.referenceType,
          'reference_id': saleId,
          'reason': mov.reason,
          'performed_by': mov.performedBy,
          'movement_date': mov.movementDate.toIso8601String(),
        });
      }

      // 6. Insert Payments
      for (final payment in transaction.sale.payments) {
        final paymentModel = SalePaymentModel.fromEntity(payment);
        final paymentMap = paymentModel.toMap();
        paymentMap['sale_id'] = saleId;
        await txn.insert(DatabaseHelper.tableSalePayments, paymentMap);
      }

      return saleId;
    });

    _databaseHelper.notifyTableChanged(DatabaseHelper.tableSales);
    _databaseHelper.notifyTableChanged(DatabaseHelper.tableInventory);
    return saleId;
  }

  @override
  Future<void> executeSaleCancellation(
    SaleCancellationTransaction transaction,
  ) async {
    final db = await _databaseHelper.database;

    await db.transaction((txn) async {
      // 1. Update Sale Status
      await txn.update(
        DatabaseHelper.tableSales,
        {
          'status': SaleStatus.cancelled.name,
          'cancelled_by': transaction.userId,
          'cancelled_at': transaction.cancelledAt.toIso8601String(),
          'cancellation_reason': transaction.reason,
        },
        where: 'id = ?',
        whereArgs: [transaction.saleId],
      );

      // 2. Restore Lots
      final lotDeductions = await txn.query(
        DatabaseHelper.tableSaleItemLots,
        where:
            'sale_item_id IN (SELECT id FROM ${DatabaseHelper.tableSaleItems} WHERE sale_id = ?)',
        whereArgs: [transaction.saleId],
      );

      for (final deduction in lotDeductions) {
        final lotId = deduction['lot_id'] as int;
        final quantityDeducted = (deduction['quantity_deducted'] as num)
            .toDouble();

        await txn.rawUpdate(
          '''
          UPDATE ${DatabaseHelper.tableInventoryLots}
          SET quantity = quantity + ?
          WHERE id = ?
          ''',
          [quantityDeducted, lotId],
        );
      }

      // 3. Restore Inventory
      final items = await txn.query(
        DatabaseHelper.tableSaleItems,
        where: 'sale_id = ?',
        whereArgs: [transaction.saleId],
      );

      final saleResult = await txn.query(
        DatabaseHelper.tableSales,
        columns: ['warehouse_id'],
        where: 'id = ?',
        whereArgs: [transaction.saleId],
      );

      if (saleResult.isEmpty) return;

      final warehouseId = saleResult.first['warehouse_id'] as int;

      for (final item in items) {
        final productId = item['product_id'] as int;
        final variantId = item['variant_id'] as int?;
        final quantity = (item['quantity'] as num).toDouble();

        double quantityToRestore = quantity;
        if (variantId != null) {
          final variantResult = await txn.query(
            DatabaseHelper.tableProductVariants,
            columns: ['quantity'],
            where: 'id = ?',
            whereArgs: [variantId],
          );
          if (variantResult.isNotEmpty) {
            final variantQuantity = (variantResult.first['quantity'] as num)
                .toDouble();
            quantityToRestore = quantity * variantQuantity;
          }
        }

        final inventoryResult = await txn.query(
          DatabaseHelper.tableInventory,
          where: 'product_id = ? AND warehouse_id = ?',
          whereArgs: [productId, warehouseId],
        );

        double quantityBefore = 0;
        if (inventoryResult.isNotEmpty) {
          quantityBefore = (inventoryResult.first['quantity_on_hand'] as num)
              .toDouble();
        }

        await txn.rawUpdate(
          '''
          UPDATE ${DatabaseHelper.tableInventory}
          SET quantity_on_hand = quantity_on_hand + ?,
              updated_at = ?
          WHERE product_id = ? AND warehouse_id = ?
          ''',
          [
            quantityToRestore,
            DateTime.now().toIso8601String(),
            productId,
            warehouseId,
          ],
        );

        await txn.insert(DatabaseHelper.tableInventoryMovements, {
          'product_id': productId,
          'warehouse_id': warehouseId,
          'movement_type': 'return',
          'quantity': quantityToRestore,
          'quantity_before': quantityBefore,
          'quantity_after': quantityBefore + quantityToRestore,
          'reference_type': 'sale_cancellation',
          'reference_id': transaction.saleId,
          'reason': 'Sale cancelled: ${transaction.reason}',
          'performed_by': transaction.userId,
          'movement_date': transaction.cancelledAt.toIso8601String(),
        });
      }
    });

    _databaseHelper.notifyTableChanged(DatabaseHelper.tableSales);
    _databaseHelper.notifyTableChanged(DatabaseHelper.tableInventory);
  }

  @override
  Future<String> generateNextSaleNumber() async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery('''
      SELECT sale_number FROM ${DatabaseHelper.tableSales}
      ORDER BY id DESC
      LIMIT 1
    ''');

    if (result.isEmpty) {
      return 'SALE-00001';
    }

    final lastNumber = result.first['sale_number'] as String;
    final numberPart = int.parse(lastNumber.split('-').last);
    final nextNumber = numberPart + 1;

    return 'SALE-${nextNumber.toString().padLeft(5, '0')}';
  }

  @override
  Stream<Sale?> getSaleByIdStream(int id) async* {
    yield await getSaleById(id);

    await for (final table in _databaseHelper.tableUpdateStream) {
      if (table == DatabaseHelper.tableSales ||
          table == DatabaseHelper.tableSaleItems ||
          table == DatabaseHelper.tableSaleReturns) {
        yield await getSaleById(id);
      }
    }
  }
}
