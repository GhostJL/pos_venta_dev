import 'package:drift/drift.dart';
import 'package:posventa/data/datasources/local/database/app_database.dart'
    as drift_db;
import 'package:posventa/domain/entities/sale_return.dart';
import 'package:posventa/domain/entities/sale_return_item.dart';
import 'package:posventa/domain/entities/inventory_movement.dart';
import 'package:posventa/domain/repositories/sale_return_repository.dart';

class SaleReturnRepositoryImpl implements SaleReturnRepository {
  final drift_db.AppDatabase db;

  SaleReturnRepositoryImpl(this.db);

  @override
  Future<List<SaleReturn>> getSaleReturns({
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  }) async {
    final q = db.select(db.saleReturns).join([
      leftOuterJoin(db.sales, db.sales.id.equalsExp(db.saleReturns.saleId)),
      leftOuterJoin(
        db.customers,
        db.customers.id.equalsExp(db.saleReturns.customerId),
      ),
      leftOuterJoin(
        db.users,
        db.users.id.equalsExp(db.saleReturns.processedBy),
      ),
    ]);

    if (startDate != null) {
      q.where(db.saleReturns.returnDate.isBiggerOrEqualValue(startDate));
    }
    if (endDate != null) {
      q.where(db.saleReturns.returnDate.isSmallerOrEqualValue(endDate));
    }

    q.orderBy([
      OrderingTerm.desc(db.saleReturns.returnDate),
      OrderingTerm.desc(db.saleReturns.id),
    ]);

    if (limit != null) {
      q.limit(limit, offset: offset);
    }

    final rows = await q.get();
    final returns = <SaleReturn>[];

    for (final row in rows) {
      final returnRow = row.readTable(db.saleReturns);
      final saleRow = row.readTableOrNull(db.sales);
      final customerRow = row.readTableOrNull(db.customers);
      final userRow = row.readTableOrNull(db.users);

      final items = await _getSaleReturnItems(returnRow.id);

      returns.add(
        SaleReturn(
          id: returnRow.id,
          returnNumber: returnRow.returnNumber,
          saleId: returnRow.saleId,
          warehouseId: returnRow.warehouseId,
          customerId: returnRow.customerId,
          processedBy: returnRow.processedBy,
          subtotalCents: returnRow.subtotalCents,
          taxCents: returnRow.taxCents,
          totalCents: returnRow.totalCents,
          refundMethod: RefundMethod.fromCode(returnRow.refundMethod),
          reason: returnRow.reason,
          notes: returnRow.notes,
          status: returnRow.status == 'completed'
              ? SaleReturnStatus.completed
              : SaleReturnStatus.cancelled,
          returnDate: returnRow.returnDate,
          createdAt: returnRow.createdAt,
          items: items,
          saleNumber: saleRow?.saleNumber,
          customerName: customerRow != null
              ? '${customerRow.firstName} ${customerRow.lastName}'
              : null,
          processedByName: userRow != null
              ? '${userRow.firstName} ${userRow.lastName}'
              : null,
        ),
      );
    }
    return returns;
  }

  Future<List<SaleReturnItem>> _getSaleReturnItems(int returnId) async {
    final q = db.select(db.saleReturnItems).join([
      leftOuterJoin(
        db.products,
        db.products.id.equalsExp(db.saleReturnItems.productId),
      ),
    ])..where(db.saleReturnItems.saleReturnId.equals(returnId));

    final rows = await q.get();

    return rows.map((row) {
      final itemRow = row.readTable(db.saleReturnItems);
      final productRow = row.readTableOrNull(db.products);

      return SaleReturnItem(
        id: itemRow.id,
        saleReturnId: itemRow.saleReturnId,
        saleItemId: itemRow.saleItemId,
        productId: itemRow.productId,
        quantity: itemRow.quantity,
        unitPriceCents: itemRow.unitPriceCents,
        subtotalCents: itemRow.subtotalCents,
        taxCents: itemRow.taxCents,
        totalCents: itemRow.totalCents,
        reason: itemRow.reason,
        createdAt: itemRow.createdAt,
        productName: productRow?.name,
        productCode: productRow?.code,
      );
    }).toList();
  }

  @override
  Stream<List<SaleReturn>> getSaleReturnsStream({
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  }) {
    return db.saleReturns.all().watch().asyncMap(
      (_) => getSaleReturns(
        startDate: startDate,
        endDate: endDate,
        limit: limit,
        offset: offset,
      ),
    );
  }

  @override
  Future<SaleReturn?> getSaleReturnById(int id) async {
    final q = db.select(db.saleReturns).join([
      leftOuterJoin(db.sales, db.sales.id.equalsExp(db.saleReturns.saleId)),
      leftOuterJoin(
        db.customers,
        db.customers.id.equalsExp(db.saleReturns.customerId),
      ),
      leftOuterJoin(
        db.users,
        db.users.id.equalsExp(db.saleReturns.processedBy),
      ),
    ])..where(db.saleReturns.id.equals(id));

    final row = await q.getSingleOrNull();

    if (row == null) return null;

    final returnRow = row.readTable(db.saleReturns);
    final saleRow = row.readTableOrNull(db.sales);
    final customerRow = row.readTableOrNull(db.customers);
    final userRow = row.readTableOrNull(db.users);

    final items = await _getSaleReturnItems(returnRow.id);

    return SaleReturn(
      id: returnRow.id,
      returnNumber: returnRow.returnNumber,
      saleId: returnRow.saleId,
      warehouseId: returnRow.warehouseId,
      customerId: returnRow.customerId,
      processedBy: returnRow.processedBy,
      subtotalCents: returnRow.subtotalCents,
      taxCents: returnRow.taxCents,
      totalCents: returnRow.totalCents,
      refundMethod: RefundMethod.fromCode(returnRow.refundMethod),
      reason: returnRow.reason,
      notes: returnRow.notes,
      status: returnRow.status == 'completed'
          ? SaleReturnStatus.completed
          : SaleReturnStatus.cancelled,
      returnDate: returnRow.returnDate,
      createdAt: returnRow.createdAt,
      items: items,
      saleNumber: saleRow?.saleNumber,
      customerName: customerRow != null
          ? '${customerRow.firstName} ${customerRow.lastName}'
          : null,
      processedByName: userRow != null
          ? '${userRow.firstName} ${userRow.lastName}'
          : null,
    );
  }

  @override
  Future<SaleReturn?> getSaleReturnByNumber(String returnNumber) async {
    final row = await (db.select(
      db.saleReturns,
    )..where((t) => t.returnNumber.equals(returnNumber))).getSingleOrNull();
    if (row != null) {
      return getSaleReturnById(row.id);
    }
    return null;
  }

  @override
  Future<int> createSaleReturn(SaleReturn saleReturn) async {
    return db.transaction(() async {
      // 1. Insert Return
      final returnId = await db
          .into(db.saleReturns)
          .insert(
            drift_db.SaleReturnsCompanion.insert(
              returnNumber: saleReturn.returnNumber,
              saleId: saleReturn.saleId,
              warehouseId: saleReturn.warehouseId,
              customerId: Value(saleReturn.customerId),
              processedBy: saleReturn.processedBy,
              subtotalCents: saleReturn.subtotalCents,
              taxCents: Value(saleReturn.taxCents),
              totalCents: saleReturn.totalCents,
              refundMethod: saleReturn.refundMethod.code,
              reason: saleReturn.reason,
              notes: Value(saleReturn.notes),
              status: Value(saleReturn.status.name),
              returnDate: saleReturn.returnDate,
              createdAt: Value(saleReturn.createdAt),
            ),
          );

      // 2. Insert Items
      for (final item in saleReturn.items) {
        await db
            .into(db.saleReturnItems)
            .insert(
              drift_db.SaleReturnItemsCompanion.insert(
                saleReturnId: returnId,
                saleItemId: item.saleItemId,
                productId: item.productId,
                quantity: item.quantity,
                unitPriceCents: item.unitPriceCents,
                subtotalCents: item.subtotalCents,
                taxCents: Value(item.taxCents),
                totalCents: item.totalCents,
                reason: Value(item.reason),
                createdAt: Value(item.createdAt),
              ),
            );

        // 3. Create Inventory Movement
        await _createInventoryMovement(
          item,
          saleReturn.warehouseId,
          saleReturn.processedBy,
          returnId,
          saleReturn.reason,
        );
      }

      // 4. Create Cash Movement if needed
      if (saleReturn.refundMethod == RefundMethod.cash) {
        await _createCashMovement(saleReturn, returnId);
      }

      // 5. Check if fully returned
      final saleItems = await (db.select(
        db.saleItems,
      )..where((t) => t.saleId.equals(saleReturn.saleId))).get();

      final returnedRows =
          await (db.select(db.saleReturnItems).join([
                innerJoin(
                  db.saleReturns,
                  db.saleReturns.id.equalsExp(db.saleReturnItems.saleReturnId),
                ),
              ])..where(
                db.saleReturns.saleId.equals(saleReturn.saleId) &
                    db.saleReturns.status.equals('completed'),
              ))
              .get();

      // Calculate total returned per sale Item
      final returnedQty = <int, double>{};
      for (final row in returnedRows) {
        final returnItem = row.readTable(db.saleReturnItems);
        returnedQty[returnItem.saleItemId] =
            (returnedQty[returnItem.saleItemId] ?? 0.0) + returnItem.quantity;
      }

      bool isFullyReturned = true;
      for (final saleItem in saleItems) {
        final returned = returnedQty[saleItem.id] ?? 0.0;
        if (returned < saleItem.quantity) {
          isFullyReturned = false;
          break;
        }
      }

      if (isFullyReturned) {
        await (db.update(db.sales)
              ..where((t) => t.id.equals(saleReturn.saleId)))
            .write(drift_db.SalesCompanion(status: Value('returned')));
      }

      return returnId;
    });
  }

  Future<void> _createInventoryMovement(
    SaleReturnItem item,
    int warehouseId,
    int performedBy,
    int returnId,
    String reason,
  ) async {
    // Check variant multiplier
    final saleItem = await (db.select(
      db.saleItems,
    )..where((t) => t.id.equals(item.saleItemId))).getSingle();
    double quantityToRestore = item.quantity;

    if (saleItem.variantId != null) {
      final variant = await (db.select(
        db.productVariants,
      )..where((t) => t.id.equals(saleItem.variantId!))).getSingleOrNull();
      if (variant != null) {
        quantityToRestore = item.quantity * variant.quantity;
      }
    }

    // Update Inventory
    final inventory =
        await (db.select(db.inventory)
              ..where(
                (t) =>
                    t.productId.equals(item.productId) &
                    t.warehouseId.equals(warehouseId),
              )
              ..limit(1))
            .getSingleOrNull();

    double quantityBefore = inventory?.quantityOnHand ?? 0.0;

    if (inventory == null) {
      await db
          .into(db.inventory)
          .insert(
            drift_db.InventoryCompanion.insert(
              productId: item.productId,
              warehouseId: warehouseId,
              quantityOnHand: Value(quantityToRestore),
              updatedAt: Value(DateTime.now()),
              quantityReserved: Value(0.0), // Provide default
            ),
          );
    } else {
      await (db.update(
        db.inventory,
      )..where((t) => t.id.equals(inventory.id))).write(
        drift_db.InventoryCompanion(
          quantityOnHand: Value(inventory.quantityOnHand + quantityToRestore),
          updatedAt: Value(DateTime.now()),
        ),
      );
    }

    await db
        .into(db.inventoryMovements)
        .insert(
          drift_db.InventoryMovementsCompanion.insert(
            productId: item.productId,
            warehouseId: warehouseId,
            movementType: MovementType.returnMovement.value,
            quantity: quantityToRestore,
            quantityBefore: quantityBefore,
            quantityAfter: quantityBefore + quantityToRestore,
            referenceType: Value('sale_return'),
            referenceId: Value(returnId),
            reason: Value(reason),
            performedBy: performedBy,
            movementDate: Value(DateTime.now()),
          ),
        );

    // Restore Lots logic (LIFO-ish restoration to sale_item_lots)
    double remainingToRestore = item.quantity;

    final lotDeductions =
        await (db.select(db.saleItemLots)
              ..where((t) => t.saleItemId.equals(item.saleItemId))
              ..orderBy([(t) => OrderingTerm.desc(t.id)]))
            .get();

    for (final deduction in lotDeductions) {
      if (remainingToRestore <= 0) break;

      final quantityOriginallyDeducted = deduction.quantityDeducted;
      final amountToRestoreToThisLot =
          remainingToRestore < quantityOriginallyDeducted
          ? remainingToRestore
          : quantityOriginallyDeducted;

      if (amountToRestoreToThisLot > 0) {
        // Restore to Lot
        final lotToUpdate = await (db.select(
          db.inventoryLots,
        )..where((t) => t.id.equals(deduction.lotId))).getSingle();

        await (db.update(
          db.inventoryLots,
        )..where((t) => t.id.equals(deduction.lotId))).write(
          drift_db.InventoryLotsCompanion(
            quantity: Value(lotToUpdate.quantity + amountToRestoreToThisLot),
          ),
        );

        // Update tracking
        if (amountToRestoreToThisLot >= quantityOriginallyDeducted) {
          await (db.delete(
            db.saleItemLots,
          )..where((t) => t.id.equals(deduction.id))).go();
        } else {
          await (db.update(
            db.saleItemLots,
          )..where((t) => t.id.equals(deduction.id))).write(
            drift_db.SaleItemLotsCompanion(
              quantityDeducted: Value(
                quantityOriginallyDeducted - amountToRestoreToThisLot,
              ),
            ),
          );
        }
        remainingToRestore -= amountToRestoreToThisLot;
      }
    }
  }

  Future<void> _createCashMovement(SaleReturn saleReturn, int returnId) async {
    final session =
        await (db.select(db.cashSessions)
              ..where(
                (t) =>
                    t.warehouseId.equals(saleReturn.warehouseId) &
                    t.status.equals('open'),
              )
              ..limit(1))
            .getSingleOrNull();

    if (session == null) {
      throw Exception(
        'No hay sesión de caja abierta en esta sucursal. '
        'Abre una sesión de caja antes de procesar devoluciones.',
      );
    }

    // Create Movement
    await db
        .into(db.cashMovements)
        .insert(
          drift_db.CashMovementsCompanion.insert(
            cashSessionId: session.id,
            movementType: 'egreso',
            amountCents: saleReturn.totalCents,
            reason: 'Devolución',
            description: Value(
              'Devolución ${saleReturn.returnNumber} - ${saleReturn.reason}',
            ),
            performedBy: saleReturn.processedBy,
            movementDate: Value(DateTime.now()),
          ),
        );

    // Update Session Balance
    final currentExpected =
        session.expectedBalanceCents ?? session.openingBalanceCents;
    await (db.update(
      db.cashSessions,
    )..where((t) => t.id.equals(session.id))).write(
      drift_db.CashSessionsCompanion(
        expectedBalanceCents: Value(currentExpected - saleReturn.totalCents),
      ),
    );
  }

  @override
  Future<String> generateNextReturnNumber() async {
    final now = DateTime.now();
    final datePrefix =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';

    final query = db.select(db.saleReturns)
      ..where((t) => t.returnNumber.like('DEV-$datePrefix-%'))
      ..orderBy([(t) => OrderingTerm.desc(t.returnNumber)])
      ..limit(1);

    final row = await query.getSingleOrNull();
    int nextSequence = 1;
    if (row != null) {
      final parts = row.returnNumber.split('-');
      if (parts.length == 3) {
        nextSequence = (int.tryParse(parts[2]) ?? 0) + 1;
      }
    }
    return 'DEV-$datePrefix-${nextSequence.toString().padLeft(4, '0')}';
  }

  @override
  Future<bool> canReturnSale(int saleId) async {
    final sale = await (db.select(
      db.sales,
    )..where((t) => t.id.equals(saleId))).getSingleOrNull();
    return sale?.status == 'completed';
  }

  @override
  Future<Map<int, double>> getReturnedQuantities(int saleId) async {
    final returnedRows =
        await (db.select(db.saleReturnItems).join([
              innerJoin(
                db.saleReturns,
                db.saleReturns.id.equalsExp(db.saleReturnItems.saleReturnId),
              ),
            ])..where(
              db.saleReturns.saleId.equals(saleId) &
                  db.saleReturns.status.equals('completed'),
            ))
            .get();

    final returnedQty = <int, double>{};
    for (final row in returnedRows) {
      final returnItem = row.readTable(db.saleReturnItems);
      returnedQty[returnItem.saleItemId] =
          (returnedQty[returnItem.saleItemId] ?? 0.0) + returnItem.quantity;
    }
    return returnedQty;
  }

  @override
  Future<bool> isSaleFullyReturned(int saleId) async {
    final saleItems = await (db.select(
      db.saleItems,
    )..where((t) => t.saleId.equals(saleId))).get();
    if (saleItems.isEmpty) return false;

    final returnedQty = await getReturnedQuantities(saleId);

    for (final item in saleItems) {
      final returned = returnedQty[item.id] ?? 0.0;
      if (returned < item.quantity) return false;
    }

    return true;
  }

  @override
  Future<Map<String, dynamic>> getReturnsStats({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // 1. Total Count and Amount
    final totalQuery = db.selectOnly(db.saleReturns)
      ..addColumns([db.saleReturns.id.count(), db.saleReturns.totalCents.sum()])
      ..where(
        db.saleReturns.returnDate.isBetweenValues(startDate, endDate) &
            db.saleReturns.status.equals('completed'),
      );

    final totalResult = await totalQuery.getSingle();
    final totalCount = totalResult.read(db.saleReturns.id.count()) ?? 0;
    final totalAmount = totalResult.read(db.saleReturns.totalCents.sum()) ?? 0;

    // 2. Returns by Reason (Group By)
    final reasonQuery = db.selectOnly(db.saleReturns)
      ..addColumns([
        db.saleReturns.reason,
        db.saleReturns.id.count(),
        db.saleReturns.totalCents.sum(),
      ])
      ..where(
        db.saleReturns.returnDate.isBetweenValues(startDate, endDate) &
            db.saleReturns.status.equals('completed'),
      )
      ..groupBy([db.saleReturns.reason])
      ..orderBy([OrderingTerm.desc(db.saleReturns.totalCents.sum())]);

    final reasonResults = await reasonQuery.get();
    final reasons = reasonResults
        .map(
          (row) => {
            'reason': row.read(db.saleReturns.reason),
            'count': row.read(db.saleReturns.id.count()),
            'total_amount': row.read(db.saleReturns.totalCents.sum()),
          },
        )
        .toList();

    // 3. Top Products
    // Complex join + aggregate
    final productQuery =
        db.selectOnly(db.saleReturnItems).join([
            innerJoin(
              db.saleReturns,
              db.saleReturns.id.equalsExp(db.saleReturnItems.saleReturnId),
            ),
            leftOuterJoin(
              db.products,
              db.products.id.equalsExp(db.saleReturnItems.productId),
            ),
          ])
          ..addColumns([
            db.products.name,
            db.saleReturnItems.quantity.sum(),
            db.saleReturnItems.totalCents.sum(),
          ])
          ..where(
            db.saleReturns.returnDate.isBetweenValues(startDate, endDate) &
                db.saleReturns.status.equals('completed'),
          )
          ..groupBy([db.saleReturnItems.productId])
          ..orderBy([OrderingTerm.desc(db.saleReturnItems.totalCents.sum())])
          ..limit(5);

    final productRows = await productQuery.get();
    final topProducts = productRows
        .map(
          (row) => {
            'product_name': row.read(db.products.name),
            'total_quantity': row.read(db.saleReturnItems.quantity.sum()),
            'total_amount': row.read(db.saleReturnItems.totalCents.sum()),
          },
        )
        .toList();

    return {
      'totalCount': totalCount,
      'totalAmount': totalAmount,
      'byReason': reasons,
      'topProducts': topProducts,
    };
  }
}
