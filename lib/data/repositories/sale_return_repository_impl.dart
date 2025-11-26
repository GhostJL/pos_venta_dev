import 'package:posventa/data/datasources/database_helper.dart';
import 'package:posventa/domain/entities/sale_return.dart';
import 'package:posventa/domain/entities/sale_return_item.dart';
import 'package:posventa/domain/entities/inventory_movement.dart';
import 'package:posventa/domain/repositories/sale_return_repository.dart';
import 'package:sqflite/sqflite.dart';

class SaleReturnRepositoryImpl implements SaleReturnRepository {
  final DatabaseHelper _dbHelper;

  SaleReturnRepositoryImpl(this._dbHelper);

  @override
  Future<List<SaleReturn>> getSaleReturns({
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  }) async {
    final db = await _dbHelper.database;

    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (startDate != null) {
      whereClause += 'sr.return_date >= ?';
      whereArgs.add(startDate.toIso8601String());
    }

    if (endDate != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'sr.return_date <= ?';
      whereArgs.add(endDate.toIso8601String());
    }

    final query =
        '''
      SELECT 
        sr.*,
        s.sale_number,
        c.first_name || ' ' || c.last_name as customer_name,
        u.first_name || ' ' || u.last_name as processed_by_name
      FROM ${DatabaseHelper.tableSaleReturns} sr
      LEFT JOIN ${DatabaseHelper.tableSales} s ON sr.sale_id = s.id
      LEFT JOIN ${DatabaseHelper.tableCustomers} c ON sr.customer_id = c.id
      LEFT JOIN ${DatabaseHelper.tableUsers} u ON sr.processed_by = u.id
      ${whereClause.isNotEmpty ? 'WHERE $whereClause' : ''}
      ORDER BY sr.return_date DESC, sr.id DESC
      ${limit != null ? 'LIMIT $limit' : ''}
      ${offset != null ? 'OFFSET $offset' : ''}
    ''';

    final results = await db.rawQuery(query, whereArgs);

    final returns = <SaleReturn>[];
    for (final row in results) {
      final saleReturn = _mapToSaleReturn(row);
      // Load items for each return
      final items = await _getSaleReturnItems(db, saleReturn.id!);
      returns.add(
        SaleReturn(
          id: saleReturn.id,
          returnNumber: saleReturn.returnNumber,
          saleId: saleReturn.saleId,
          warehouseId: saleReturn.warehouseId,
          customerId: saleReturn.customerId,
          processedBy: saleReturn.processedBy,
          subtotalCents: saleReturn.subtotalCents,
          taxCents: saleReturn.taxCents,
          totalCents: saleReturn.totalCents,
          refundMethod: saleReturn.refundMethod,
          reason: saleReturn.reason,
          notes: saleReturn.notes,
          status: saleReturn.status,
          returnDate: saleReturn.returnDate,
          createdAt: saleReturn.createdAt,
          items: items,
          saleNumber: row['sale_number'] as String?,
          customerName: row['customer_name'] as String?,
          processedByName: row['processed_by_name'] as String?,
        ),
      );
    }

    return returns;
  }

  @override
  Stream<List<SaleReturn>> getSaleReturnsStream({
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  }) async* {
    yield await getSaleReturns(
      startDate: startDate,
      endDate: endDate,
      limit: limit,
      offset: offset,
    );

    await for (final table in _dbHelper.tableUpdateStream) {
      if (table == DatabaseHelper.tableSaleReturns ||
          table == DatabaseHelper.tableSaleReturnItems) {
        yield await getSaleReturns(
          startDate: startDate,
          endDate: endDate,
          limit: limit,
          offset: offset,
        );
      }
    }
  }

  @override
  Future<SaleReturn?> getSaleReturnById(int id) async {
    final db = await _dbHelper.database;

    final results = await db.rawQuery(
      '''
      SELECT 
        sr.*,
        s.sale_number,
        c.first_name || ' ' || c.last_name as customer_name,
        u.first_name || ' ' || u.last_name as processed_by_name
      FROM ${DatabaseHelper.tableSaleReturns} sr
      LEFT JOIN ${DatabaseHelper.tableSales} s ON sr.sale_id = s.id
      LEFT JOIN ${DatabaseHelper.tableCustomers} c ON sr.customer_id = c.id
      LEFT JOIN ${DatabaseHelper.tableUsers} u ON sr.processed_by = u.id
      WHERE sr.id = ?
    ''',
      [id],
    );

    if (results.isEmpty) return null;

    final row = results.first;
    final saleReturn = _mapToSaleReturn(row);
    final items = await _getSaleReturnItems(db, id);

    return SaleReturn(
      id: saleReturn.id,
      returnNumber: saleReturn.returnNumber,
      saleId: saleReturn.saleId,
      warehouseId: saleReturn.warehouseId,
      customerId: saleReturn.customerId,
      processedBy: saleReturn.processedBy,
      subtotalCents: saleReturn.subtotalCents,
      taxCents: saleReturn.taxCents,
      totalCents: saleReturn.totalCents,
      refundMethod: saleReturn.refundMethod,
      reason: saleReturn.reason,
      notes: saleReturn.notes,
      status: saleReturn.status,
      returnDate: saleReturn.returnDate,
      createdAt: saleReturn.createdAt,
      items: items,
      saleNumber: row['sale_number'] as String?,
      customerName: row['customer_name'] as String?,
      processedByName: row['processed_by_name'] as String?,
    );
  }

  @override
  Future<SaleReturn?> getSaleReturnByNumber(String returnNumber) async {
    final db = await _dbHelper.database;

    final results = await db.query(
      DatabaseHelper.tableSaleReturns,
      where: 'return_number = ?',
      whereArgs: [returnNumber],
    );

    if (results.isEmpty) return null;

    final saleReturn = _mapToSaleReturn(results.first);
    final items = await _getSaleReturnItems(db, saleReturn.id!);

    return SaleReturn(
      id: saleReturn.id,
      returnNumber: saleReturn.returnNumber,
      saleId: saleReturn.saleId,
      warehouseId: saleReturn.warehouseId,
      customerId: saleReturn.customerId,
      processedBy: saleReturn.processedBy,
      subtotalCents: saleReturn.subtotalCents,
      taxCents: saleReturn.taxCents,
      totalCents: saleReturn.totalCents,
      refundMethod: saleReturn.refundMethod,
      reason: saleReturn.reason,
      notes: saleReturn.notes,
      status: saleReturn.status,
      returnDate: saleReturn.returnDate,
      createdAt: saleReturn.createdAt,
      items: items,
    );
  }

  @override
  Future<int> createSaleReturn(SaleReturn saleReturn) async {
    final db = await _dbHelper.database;

    final returnId = await db.transaction((txn) async {
      // 1. Insert sale return
      final returnId = await txn.insert(DatabaseHelper.tableSaleReturns, {
        'return_number': saleReturn.returnNumber,
        'sale_id': saleReturn.saleId,
        'warehouse_id': saleReturn.warehouseId,
        'customer_id': saleReturn.customerId,
        'processed_by': saleReturn.processedBy,
        'subtotal_cents': saleReturn.subtotalCents,
        'tax_cents': saleReturn.taxCents,
        'total_cents': saleReturn.totalCents,
        'refund_method': saleReturn.refundMethod.code,
        'reason': saleReturn.reason,
        'notes': saleReturn.notes,
        'status': saleReturn.status.name,
        'return_date': saleReturn.returnDate.toIso8601String(),
        'created_at': saleReturn.createdAt.toIso8601String(),
      });

      // 2. Insert sale return items
      for (final item in saleReturn.items) {
        await txn.insert(DatabaseHelper.tableSaleReturnItems, {
          'sale_return_id': returnId,
          'sale_item_id': item.saleItemId,
          'product_id': item.productId,
          'quantity': item.quantity,
          'unit_price_cents': item.unitPriceCents,
          'subtotal_cents': item.subtotalCents,
          'tax_cents': item.taxCents,
          'total_cents': item.totalCents,
          'reason': item.reason,
          'created_at': item.createdAt.toIso8601String(),
        });

        // 3. Create inventory movement for each item
        await _createInventoryMovement(
          txn,
          item,
          saleReturn.warehouseId,
          saleReturn.processedBy,
          returnId,
          saleReturn.reason,
        );
      }

      // 4. Create cash movement if refund method is cash
      if (saleReturn.refundMethod == RefundMethod.cash) {
        await _createCashMovement(txn, saleReturn, returnId);
      }

      return returnId;
    });

    _dbHelper.notifyTableChanged(DatabaseHelper.tableSaleReturns);
    _dbHelper.notifyTableChanged(DatabaseHelper.tableInventory);
    _dbHelper.notifyTableChanged(DatabaseHelper.tableCashSessions);
    _dbHelper.notifyTableChanged(DatabaseHelper.tableSales);

    return returnId;
  }

  Future<void> _createInventoryMovement(
    Transaction txn,
    SaleReturnItem item,
    int warehouseId,
    int performedBy,
    int returnId,
    String reason,
  ) async {
    // Get current inventory
    final inventoryResults = await txn.query(
      DatabaseHelper.tableInventory,
      where: 'product_id = ? AND warehouse_id = ?',
      whereArgs: [item.productId, warehouseId],
    );

    double quantityBefore = 0;
    if (inventoryResults.isNotEmpty) {
      quantityBefore = inventoryResults.first['quantity_on_hand'] as double;
    }

    final quantityAfter = quantityBefore + item.quantity;

    // Insert inventory movement
    await txn.insert(DatabaseHelper.tableInventoryMovements, {
      'product_id': item.productId,
      'warehouse_id': warehouseId,
      'movement_type': MovementType.returnMovement.value,
      'quantity': item.quantity,
      'quantity_before': quantityBefore,
      'quantity_after': quantityAfter,
      'reference_type': 'sale_return',
      'reference_id': returnId,
      'reason': reason,
      'performed_by': performedBy,
      'movement_date': DateTime.now().toIso8601String(),
    });

    // Update inventory
    if (inventoryResults.isEmpty) {
      // Create new inventory record
      await txn.insert(DatabaseHelper.tableInventory, {
        'product_id': item.productId,
        'warehouse_id': warehouseId,
        'quantity_on_hand': item.quantity,
        'quantity_reserved': 0,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } else {
      // Update existing inventory
      await txn.update(
        DatabaseHelper.tableInventory,
        {
          'quantity_on_hand': quantityAfter,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'product_id = ? AND warehouse_id = ?',
        whereArgs: [item.productId, warehouseId],
      );
    }
  }

  Future<void> _createCashMovement(
    Transaction txn,
    SaleReturn saleReturn,
    int returnId,
  ) async {
    // Get active cash session for the warehouse
    final sessionResults = await txn.query(
      DatabaseHelper.tableCashSessions,
      where: 'warehouse_id = ? AND status = ?',
      whereArgs: [saleReturn.warehouseId, 'open'],
    );

    if (sessionResults.isEmpty) {
      throw Exception(
        'No hay sesión de caja abierta en esta sucursal. '
        'Abre una sesión de caja antes de procesar devoluciones.',
      );
    }

    final session = sessionResults.first;
    final sessionId = session['id'] as int;
    final currentBalance =
        (session['expected_balance_cents'] as int?) ??
        (session['opening_balance_cents'] as int);

    // Insert cash movement (egreso/outflow)
    await txn.insert(DatabaseHelper.tableCashMovements, {
      'cash_session_id': sessionId,
      'movement_type': 'egreso',
      'amount_cents': saleReturn.totalCents,
      'reason': 'Devolución',
      'description':
          'Devolución ${saleReturn.returnNumber} - ${saleReturn.reason}',
      'performed_by': saleReturn.processedBy,
      'movement_date': DateTime.now().toIso8601String(),
    });

    // Update expected balance of cash session
    await txn.update(
      DatabaseHelper.tableCashSessions,
      {'expected_balance_cents': currentBalance - saleReturn.totalCents},
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }

  @override
  Future<String> generateNextReturnNumber() async {
    final db = await _dbHelper.database;
    final now = DateTime.now();
    final datePrefix =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';

    final results = await db.rawQuery('''
      SELECT return_number 
      FROM ${DatabaseHelper.tableSaleReturns}
      WHERE return_number LIKE 'DEV-$datePrefix-%'
      ORDER BY return_number DESC
      LIMIT 1
    ''');

    int nextSequence = 1;
    if (results.isNotEmpty) {
      final lastNumber = results.first['return_number'] as String;
      final parts = lastNumber.split('-');
      if (parts.length == 3) {
        nextSequence = (int.tryParse(parts[2]) ?? 0) + 1;
      }
    }

    return 'DEV-$datePrefix-${nextSequence.toString().padLeft(4, '0')}';
  }

  @override
  Future<bool> canReturnSale(int saleId) async {
    final db = await _dbHelper.database;

    final results = await db.query(
      DatabaseHelper.tableSales,
      where: 'id = ?',
      whereArgs: [saleId],
    );

    if (results.isEmpty) return false;

    final sale = results.first;
    final status = sale['status'] as String;

    // Can only return completed sales
    return status == 'completed';
  }

  @override
  Future<Map<int, double>> getReturnedQuantities(int saleId) async {
    final db = await _dbHelper.database;

    final results = await db.rawQuery(
      '''
      SELECT 
        sri.sale_item_id,
        SUM(sri.quantity) as total_returned
      FROM ${DatabaseHelper.tableSaleReturnItems} sri
      INNER JOIN ${DatabaseHelper.tableSaleReturns} sr ON sri.sale_return_id = sr.id
      WHERE sr.sale_id = ? AND sr.status = 'completed'
      GROUP BY sri.sale_item_id
    ''',
      [saleId],
    );

    final returnedQty = <int, double>{};
    for (final row in results) {
      final saleItemId = row['sale_item_id'] as int;
      final totalReturned = row['total_returned'] as double;
      returnedQty[saleItemId] = totalReturned;
    }

    return returnedQty;
  }

  @override
  Future<Map<String, dynamic>> getReturnsStats({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final db = await _dbHelper.database;
    final startStr = startDate.toIso8601String();
    final endStr = endDate.toIso8601String();

    // 1. Total Returns and Amount
    final totalResults = await db.rawQuery(
      '''
      SELECT 
        COUNT(*) as count,
        SUM(total_cents) as total_amount
      FROM ${DatabaseHelper.tableSaleReturns}
      WHERE return_date BETWEEN ? AND ? AND status = 'completed'
    ''',
      [startStr, endStr],
    );

    final totalCount = (totalResults.first['count'] as int?) ?? 0;
    final totalAmount = (totalResults.first['total_amount'] as int?) ?? 0;

    // 2. Returns by Reason
    final reasonResults = await db.rawQuery(
      '''
      SELECT 
        reason,
        COUNT(*) as count,
        SUM(total_cents) as total_amount
      FROM ${DatabaseHelper.tableSaleReturns}
      WHERE return_date BETWEEN ? AND ? AND status = 'completed'
      GROUP BY reason
      ORDER BY total_amount DESC
    ''',
      [startStr, endStr],
    );

    // 3. Top Returned Products
    final productResults = await db.rawQuery(
      '''
      SELECT 
        p.name as product_name,
        SUM(sri.quantity) as total_quantity,
        SUM(sri.total_cents) as total_amount
      FROM ${DatabaseHelper.tableSaleReturnItems} sri
      JOIN ${DatabaseHelper.tableSaleReturns} sr ON sri.sale_return_id = sr.id
      LEFT JOIN ${DatabaseHelper.tableProducts} p ON sri.product_id = p.id
      WHERE sr.return_date BETWEEN ? AND ? AND sr.status = 'completed'
      GROUP BY sri.product_id
      ORDER BY total_amount DESC
      LIMIT 5
    ''',
      [startStr, endStr],
    );

    return {
      'totalCount': totalCount,
      'totalAmount': totalAmount,
      'byReason': reasonResults,
      'topProducts': productResults,
    };
  }

  Future<List<SaleReturnItem>> _getSaleReturnItems(
    Database db,
    int returnId,
  ) async {
    final results = await db.rawQuery(
      '''
      SELECT 
        sri.*,
        p.name as product_name,
        p.code as product_code
      FROM ${DatabaseHelper.tableSaleReturnItems} sri
      LEFT JOIN ${DatabaseHelper.tableProducts} p ON sri.product_id = p.id
      WHERE sri.sale_return_id = ?
      ORDER BY sri.id
    ''',
      [returnId],
    );

    return results.map((row) => _mapToSaleReturnItem(row)).toList();
  }

  SaleReturn _mapToSaleReturn(Map<String, dynamic> row) {
    return SaleReturn(
      id: row['id'] as int,
      returnNumber: row['return_number'] as String,
      saleId: row['sale_id'] as int,
      warehouseId: row['warehouse_id'] as int,
      customerId: row['customer_id'] as int?,
      processedBy: row['processed_by'] as int,
      subtotalCents: row['subtotal_cents'] as int,
      taxCents: row['tax_cents'] as int,
      totalCents: row['total_cents'] as int,
      refundMethod: RefundMethod.fromCode(row['refund_method'] as String),
      reason: row['reason'] as String,
      notes: row['notes'] as String?,
      status: row['status'] == 'completed'
          ? SaleReturnStatus.completed
          : SaleReturnStatus.cancelled,
      returnDate: DateTime.parse(row['return_date'] as String),
      createdAt: DateTime.parse(row['created_at'] as String),
    );
  }

  SaleReturnItem _mapToSaleReturnItem(Map<String, dynamic> row) {
    return SaleReturnItem(
      id: row['id'] as int,
      saleReturnId: row['sale_return_id'] as int,
      saleItemId: row['sale_item_id'] as int,
      productId: row['product_id'] as int,
      quantity: row['quantity'] as double,
      unitPriceCents: row['unit_price_cents'] as int,
      subtotalCents: row['subtotal_cents'] as int,
      taxCents: row['tax_cents'] as int,
      totalCents: row['total_cents'] as int,
      reason: row['reason'] as String?,
      createdAt: DateTime.parse(row['created_at'] as String),
      productName: row['product_name'] as String?,
      productCode: row['product_code'] as String?,
    );
  }
}
