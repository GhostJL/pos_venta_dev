import 'package:posventa/data/datasources/database_helper.dart';
import 'package:posventa/data/models/sale_item_model.dart';
import 'package:posventa/data/models/sale_model.dart';
import 'package:posventa/data/models/sale_item_tax_model.dart';
import 'package:posventa/data/models/sale_payment_model.dart';
import 'package:posventa/domain/entities/sale.dart';
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
  Future<int> createSale(Sale sale) async {
    final db = await _databaseHelper.database;
    final saleId = await db.transaction((txn) async {
      // 1. Insert Sale
      final saleModel = SaleModel.fromEntity(sale);
      final saleId = await txn.insert(
        DatabaseHelper.tableSales,
        saleModel.toMap(),
      );

      // 2. Insert Items
      for (final item in sale.items) {
        final itemModel = SaleItemModel.fromEntity(item);
        // Ensure saleId is set
        final itemMap = itemModel.toMap();
        itemMap['sale_id'] = saleId;
        final saleItemId = await txn.insert(
          DatabaseHelper.tableSaleItems,
          itemMap,
        );

        // Insert Item Taxes
        for (final tax in item.taxes) {
          final taxModel = SaleItemTaxModel.fromEntity(tax);
          final taxMap = taxModel.toMap();
          taxMap['sale_item_id'] = saleItemId;
          await txn.insert(DatabaseHelper.tableSaleItemTaxes, taxMap);
        }

        // Update Inventory (Decrease stock)
        // Check if inventory exists
        final inventoryResult = await txn.query(
          DatabaseHelper.tableInventory,
          where: 'product_id = ? AND warehouse_id = ?',
          whereArgs: [item.productId, sale.warehouseId],
        );

        double quantityBefore = 0;
        if (inventoryResult.isNotEmpty) {
          quantityBefore = (inventoryResult.first['quantity_on_hand'] as num)
              .toDouble();
        } else {
          // Create if not exists (though ideally it should exist)
          await txn.insert(DatabaseHelper.tableInventory, {
            'product_id': item.productId,
            'warehouse_id': sale.warehouseId,
            'quantity_on_hand': 0,
            'quantity_reserved': 0,
            'updated_at': DateTime.now().toIso8601String(),
          });
        }

        await txn.rawUpdate(
          '''
          UPDATE ${DatabaseHelper.tableInventory}
          SET quantity_on_hand = quantity_on_hand - ?,
              updated_at = ?
          WHERE product_id = ? AND warehouse_id = ?
        ''',
          [
            item.quantity,
            DateTime.now().toIso8601String(),
            item.productId,
            sale.warehouseId,
          ],
        );

        // Record Movement (Sale)
        await txn.insert(DatabaseHelper.tableInventoryMovements, {
          'product_id': item.productId,
          'warehouse_id': sale.warehouseId,
          'movement_type': 'sale',
          'quantity': -item.quantity, // Negative for sale
          'quantity_before': quantityBefore,
          'quantity_after': quantityBefore - item.quantity,
          'reference_type': 'sale',
          'reference_id': saleId,
          'reason': 'Sale #$saleId',
          'performed_by': sale.cashierId,
          'movement_date': DateTime.now().toIso8601String(),
        });
      }

      // 3. Insert Payments
      for (final payment in sale.payments) {
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
  Future<void> cancelSale(int saleId, int userId, String reason) async {
    final db = await _databaseHelper.database;
    await db.transaction((txn) async {
      // 1. Update Sale Status
      await txn.update(
        DatabaseHelper.tableSales,
        {
          'status': SaleStatus.cancelled.name,
          'cancelled_by': userId,
          'cancelled_at': DateTime.now().toIso8601String(),
          'cancellation_reason': reason,
        },
        where: 'id = ?',
        whereArgs: [saleId],
      );

      // 2. Restore Inventory
      final items = await txn.query(
        DatabaseHelper.tableSaleItems,
        where: 'sale_id = ?',
        whereArgs: [saleId],
      );

      // We need the warehouse ID from the sale
      final saleResult = await txn.query(
        DatabaseHelper.tableSales,
        columns: ['warehouse_id'],
        where: 'id = ?',
        whereArgs: [saleId],
      );
      final warehouseId = saleResult.first['warehouse_id'] as int;

      for (final item in items) {
        final productId = item['product_id'] as int;
        final quantity = item['quantity'] as double;

        // Get current inventory
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
          [quantity, DateTime.now().toIso8601String(), productId, warehouseId],
        );

        // Record Movement (Return/Cancel)
        await txn.insert(DatabaseHelper.tableInventoryMovements, {
          'product_id': productId,
          'warehouse_id': warehouseId,
          'movement_type': 'return',
          'quantity': quantity, // Positive for return
          'quantity_before': quantityBefore,
          'quantity_after': quantityBefore + quantity,
          'reference_type': 'sale',
          'reference_id': saleId,
          'reason': reason.isNotEmpty ? reason : 'Sale Cancelled',
          'performed_by': userId,
          'movement_date': DateTime.now().toIso8601String(),
        });
      }
    });
    _databaseHelper.notifyTableChanged(DatabaseHelper.tableSales);
    _databaseHelper.notifyTableChanged(DatabaseHelper.tableInventory);
  }

  @override
  Future<String> generateNextSaleNumber() async {
    final db = await _databaseHelper.database;
    // Simple sequential number: S-000001
    final result = await db.rawQuery(
      'SELECT MAX(id) as max_id FROM ${DatabaseHelper.tableSales}',
    );
    int nextId = 1;
    if (result.isNotEmpty && result.first['max_id'] != null) {
      nextId = (result.first['max_id'] as int) + 1;
    }
    return 'S-${nextId.toString().padLeft(6, '0')}';
  }
}
