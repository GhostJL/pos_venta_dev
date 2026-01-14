import 'package:drift/drift.dart';
import 'package:posventa/data/datasources/local/database/app_database.dart'
    as drift_db;
import 'package:posventa/data/models/sale_item_model.dart';
import 'package:posventa/data/models/sale_model.dart';
import 'package:posventa/data/models/sale_item_tax_model.dart';
import 'package:posventa/data/models/sale_payment_model.dart';
import 'package:posventa/domain/entities/sale.dart';
import 'package:posventa/domain/entities/sale_transaction.dart';
import 'package:posventa/domain/repositories/sale_repository.dart';

class SaleRepositoryImpl implements SaleRepository {
  final drift_db.AppDatabase db;

  SaleRepositoryImpl(this.db);

  @override
  Future<List<Sale>> getSales({
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
    int? cashierId,
    int? customerId,
    bool onlyUnpaid = false,
  }) async {
    final q = db.select(db.sales).join([
      leftOuterJoin(
        db.customers,
        db.customers.id.equalsExp(db.sales.customerId),
      ),
    ]);

    if (onlyUnpaid) {
      q.where(db.sales.paymentStatus.equals('paid').not());
    }

    if (startDate != null) {
      q.where(db.sales.saleDate.isBiggerOrEqualValue(startDate));
    }
    if (endDate != null) {
      q.where(db.sales.saleDate.isSmallerOrEqualValue(endDate));
    }
    if (cashierId != null) {
      q.where(db.sales.cashierId.equals(cashierId));
    }
    if (customerId != null) {
      q.where(db.sales.customerId.equals(customerId));
    }

    q.orderBy([OrderingTerm.desc(db.sales.saleDate)]);

    if (limit != null) {
      q.limit(limit, offset: offset);
    }

    final rows = await q.get();
    final sales = <Sale>[];

    for (final row in rows) {
      final saleRow = row.readTable(db.sales);
      final customerRow = row.readTableOrNull(db.customers);

      // Load items for each sale
      final items = await _getSaleItems(saleRow.id);
      final payments = await _getSalePayments(saleRow.id);

      sales.add(
        SaleModel(
          id: saleRow.id,
          saleNumber: saleRow.saleNumber,
          warehouseId: saleRow.warehouseId,
          customerId: saleRow.customerId,
          cashierId: saleRow.cashierId,
          subtotalCents: saleRow.subtotalCents,
          discountCents: saleRow.discountCents,
          taxCents: saleRow.taxCents,
          totalCents: saleRow.totalCents,
          amountPaidCents: saleRow.amountPaidCents,
          balanceCents: saleRow.balanceCents,
          paymentStatus: saleRow.paymentStatus,
          status: SaleStatus.values.firstWhere(
            (e) => e.name == saleRow.status,
            orElse: () => SaleStatus.completed,
          ),
          saleDate: saleRow.saleDate,
          createdAt: saleRow.createdAt,
          cancelledBy: saleRow.cancelledBy,
          cancelledAt: saleRow.cancelledAt,
          cancellationReason: saleRow.cancellationReason,
          items: items,
          payments: payments,
          customerName: customerRow != null
              ? '${customerRow.firstName} ${customerRow.lastName}'
              : null,
        ),
      );
    }
    return sales;
  }

  Future<List<SaleItemModel>> _getSaleItems(int saleId) async {
    final query = db.select(db.saleItems).join([
      leftOuterJoin(
        db.products,
        db.products.id.equalsExp(db.saleItems.productId),
      ),
    ])..where(db.saleItems.saleId.equals(saleId));

    final rows = await query.get();
    final items = <SaleItemModel>[];

    for (final row in rows) {
      final itemRow = row.readTable(db.saleItems);
      final productRow = row.readTableOrNull(db.products);

      // Get taxes for item
      final taxesRows = await (db.select(
        db.saleItemTaxes,
      )..where((t) => t.saleItemId.equals(itemRow.id))).get();
      final taxes = taxesRows
          .map(
            (t) => SaleItemTaxModel(
              id: t.id,
              saleItemId: t.saleItemId,
              taxRateId: t.taxRateId,
              taxName: t.taxName,
              taxRate: t.taxRate,
              taxAmountCents: t.taxAmountCents,
            ),
          )
          .toList();

      items.add(
        SaleItemModel(
          id: itemRow.id,
          saleId: itemRow.saleId,
          productId: itemRow.productId,
          variantId: itemRow.variantId,
          quantity: itemRow.quantity,
          unitOfMeasure: itemRow.unitOfMeasure,
          unitPriceCents: itemRow.unitPriceCents,
          discountCents: itemRow.discountCents,
          subtotalCents: itemRow.subtotalCents,
          taxCents: itemRow.taxCents,
          totalCents: itemRow.totalCents,
          costPriceCents: itemRow.costPriceCents,
          lotId: itemRow.lotId,
          productName: productRow?.name,
          taxes: taxes,
        ),
      );
    }
    return items;
  }

  Future<List<SalePaymentModel>> _getSalePayments(int saleId) async {
    final rows = await (db.select(
      db.salePayments,
    )..where((t) => t.saleId.equals(saleId))).get();
    return rows
        .map(
          (row) => SalePaymentModel(
            id: row.id,
            saleId: row.saleId,
            paymentMethod: row.paymentMethod,
            amountCents: row.amountCents,
            referenceNumber: row.referenceNumber,
            paymentDate: row.paymentDate,
            receivedBy: row.receivedBy,
          ),
        )
        .toList();
  }

  @override
  Future<int> countSales({
    DateTime? startDate,
    DateTime? endDate,
    int? cashierId,
    int? customerId,
    bool onlyUnpaid = false,
  }) async {
    final q = db.selectOnly(db.sales)..addColumns([db.sales.id.count()]);

    if (onlyUnpaid) {
      q.where(db.sales.paymentStatus.equals('paid').not());
    }

    if (startDate != null) {
      q.where(db.sales.saleDate.isBiggerOrEqualValue(startDate));
    }
    if (endDate != null) {
      q.where(db.sales.saleDate.isSmallerOrEqualValue(endDate));
    }
    if (cashierId != null) {
      q.where(db.sales.cashierId.equals(cashierId));
    }

    final result = await q.getSingle();
    return result.read(db.sales.id.count()) ?? 0;
  }

  @override
  Future<Sale?> getSaleById(int id) async {
    final row = await (db.select(db.sales).join([
      leftOuterJoin(
        db.customers,
        db.customers.id.equalsExp(db.sales.customerId),
      ),
    ])..where(db.sales.id.equals(id))).getSingleOrNull();

    if (row == null) return null;

    final saleRow = row.readTable(db.sales);
    final customerRow = row.readTableOrNull(db.customers);

    final items = await _getSaleItems(saleRow.id);
    final payments = await _getSalePayments(saleRow.id);

    return SaleModel(
      id: saleRow.id,
      saleNumber: saleRow.saleNumber,
      warehouseId: saleRow.warehouseId,
      customerId: saleRow.customerId,
      cashierId: saleRow.cashierId,
      subtotalCents: saleRow.subtotalCents,
      discountCents: saleRow.discountCents,
      taxCents: saleRow.taxCents,
      totalCents: saleRow.totalCents,
      amountPaidCents: saleRow.amountPaidCents,
      balanceCents: saleRow.balanceCents,
      paymentStatus: saleRow.paymentStatus,
      status: SaleStatus.values.firstWhere(
        (e) => e.name == saleRow.status,
        orElse: () => SaleStatus.completed,
      ),
      saleDate: saleRow.saleDate,
      createdAt: saleRow.createdAt,
      cancelledBy: saleRow.cancelledBy,
      cancelledAt: saleRow.cancelledAt,
      cancellationReason: saleRow.cancellationReason,
      items: items,
      payments: payments,
      customerName: customerRow != null
          ? '${customerRow.firstName} ${customerRow.lastName}'
          : null,
    );
  }

  @override
  Future<Sale?> getSaleByNumber(String saleNumber) async {
    final row = await (db.select(
      db.sales,
    )..where((t) => t.saleNumber.equals(saleNumber))).getSingleOrNull();
    if (row != null) {
      return getSaleById(row.id);
    }
    return null;
  }

  @override
  Stream<List<Sale>> getSalesStream({
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
    int? cashierId,
    int? customerId,
    bool onlyUnpaid = false,
  }) {
    // Basic stream implementation watching the sales table
    // For more complex querying relative to filters, we might need to re-query
    final query = db.select(db.sales);
    // Note: Join streams in Drift are more complex.
    // To simplify, we'll just yield the results of getSales whenever tables change.

    return db.sales.all().watch().asyncMap(
      (_) => getSales(
        startDate: startDate,
        endDate: endDate,
        limit: limit,
        offset: offset,
        cashierId: cashierId,
        customerId: customerId,
        onlyUnpaid: onlyUnpaid,
      ),
    );
  }

  @override
  Stream<Sale?> getSaleByIdStream(int id) {
    return (db.select(
      db.sales,
    )..where((t) => t.id.equals(id))).watchSingleOrNull().asyncMap((row) async {
      if (row == null) return null;
      return await getSaleById(id);
    });
  }

  @override
  Future<int> executeSaleTransaction(SaleTransaction transaction) async {
    return db.transaction(() async {
      // 1. Insert Sale
      // Calculate totals from payments to ensure consistency
      int calculatedAmountPaid = 0;
      for (final p in transaction.sale.payments) {
        calculatedAmountPaid += p.amountCents;
      }
      final calculatedBalance =
          transaction.sale.totalCents - calculatedAmountPaid;
      final calculatedPaymentStatus = calculatedBalance <= 0
          ? 'paid'
          : (calculatedAmountPaid > 0 ? 'partial' : 'unpaid');

      final saleId = await db
          .into(db.sales)
          .insert(
            drift_db.SalesCompanion.insert(
              saleNumber: transaction.sale.saleNumber,
              warehouseId: transaction.sale.warehouseId,
              customerId: Value(transaction.sale.customerId),
              cashierId: transaction.sale.cashierId,
              subtotalCents: transaction.sale.subtotalCents,
              discountCents: Value(transaction.sale.discountCents),
              taxCents: Value(transaction.sale.taxCents),
              totalCents: transaction.sale.totalCents,
              amountPaidCents: Value(calculatedAmountPaid),
              balanceCents: Value(calculatedBalance),
              paymentStatus: Value(calculatedPaymentStatus),
              status: Value(transaction.sale.status.name),
              saleDate: transaction.sale.saleDate,
              createdAt: Value(transaction.sale.createdAt),
            ),
          );

      final Map<int, int> saleItemIdMap = {};

      // 2. Insert Items and Taxes
      for (int i = 0; i < transaction.sale.items.length; i++) {
        final item = transaction.sale.items[i];
        final saleItemId = await db
            .into(db.saleItems)
            .insert(
              drift_db.SaleItemsCompanion.insert(
                saleId: saleId,
                productId: item.productId,
                variantId: Value(item.variantId),
                quantity: item.quantity,
                unitOfMeasure: item.unitOfMeasure,
                unitPriceCents: item.unitPriceCents,
                discountCents: Value(item.discountCents),
                subtotalCents: item.subtotalCents,
                taxCents: Value(item.taxCents),
                totalCents: item.totalCents,
                costPriceCents: item.costPriceCents,
                lotId: Value(item.lotId),
                createdAt: Value(DateTime.now()),
              ),
            );

        saleItemIdMap[i] = saleItemId;

        for (final tax in item.taxes) {
          await db
              .into(db.saleItemTaxes)
              .insert(
                drift_db.SaleItemTaxesCompanion.insert(
                  saleItemId: saleItemId,
                  taxRateId: tax.taxRateId,
                  taxName: tax.taxName,
                  taxRate: tax.taxRate,
                  taxAmountCents: tax.taxAmountCents,
                ),
              );
        }
      }

      // 3. Process Lot Deductions
      for (int i = 0; i < transaction.lotDeductions.length; i++) {
        final itemDeduction = transaction.lotDeductions[i];
        final saleItemId = saleItemIdMap[i]!;
        int? primaryLotId;

        for (final deduction in itemDeduction.deductions) {
          // Update lot quantity
          // Use custom query for atomic update or just read-modify-write if transaction lock is active
          // Drift transaction block works as a transaction, so we can read-modify-write safely-ish,
          // but SQL is better for concurrency.
          await db.customUpdate(
            'UPDATE inventory_lots SET quantity = quantity - ? WHERE id = ?',
            variables: [
              Variable.withReal(deduction.quantityToDeduct),
              Variable.withInt(deduction.lotId),
            ],
            updates: {db.inventoryLots},
          );

          await db
              .into(db.saleItemLots)
              .insert(
                drift_db.SaleItemLotsCompanion.insert(
                  saleItemId: saleItemId,
                  lotId: deduction.lotId,
                  quantityDeducted: deduction.quantityToDeduct,
                  createdAt: Value(DateTime.now()),
                ),
              );

          primaryLotId ??= deduction.lotId;
        }

        if (primaryLotId != null) {
          await (db.update(db.saleItems)..where((t) => t.id.equals(saleItemId)))
              .write(drift_db.SaleItemsCompanion(lotId: Value(primaryLotId)));
        }
      }

      // 4. Update Inventory
      for (final adj in transaction.inventoryAdjustments) {
        await db.customUpdate(
          'UPDATE inventory SET quantity_on_hand = quantity_on_hand - ?, updated_at = ? WHERE product_id = ? AND warehouse_id = ?',
          variables: [
            Variable.withReal(adj.quantityToDeduct),
            Variable.withString(
              DateTime.now().toIso8601String(),
            ), // using string for consistency if Drift doesn't auto-convert in custom update
            Variable.withInt(adj.productId),
            Variable.withInt(adj.warehouseId),
          ],
          updates: {db.inventory},
        );
      }

      // 5. Record Movements
      for (final mov in transaction.movements) {
        final invRow =
            await (db.select(db.inventory)..where(
                  (t) =>
                      t.productId.equals(mov.productId) &
                      t.warehouseId.equals(mov.warehouseId),
                ))
                .getSingleOrNull();

        double currentQty = invRow?.quantityOnHand ?? 0.0;

        await db
            .into(db.inventoryMovements)
            .insert(
              drift_db.InventoryMovementsCompanion.insert(
                productId: mov.productId,
                warehouseId: mov.warehouseId,
                movementType: mov.movementType.value,
                quantity: mov.quantity,
                quantityBefore:
                    currentQty +
                    mov.quantity, // Corrected: Before was Current (Already Deducted) + Sold
                quantityAfter: currentQty,
                referenceType: Value(mov.referenceType),
                referenceId: Value(saleId),
                reason: Value(mov.reason),
                performedBy: mov.performedBy,
                movementDate: Value(mov.movementDate),
              ),
            );
      }

      // 6. Insert Payments
      for (final payment in transaction.sale.payments) {
        await db
            .into(db.salePayments)
            .insert(
              drift_db.SalePaymentsCompanion.insert(
                saleId: saleId,
                paymentMethod: payment.paymentMethod,
                amountCents: payment.amountCents,
                receivedBy: payment.receivedBy,
                referenceNumber: Value(payment.referenceNumber),
                paymentDate: Value(payment.paymentDate),
              ),
            );
      }

      // 7. Update Customer Credit (if applicable)

      if (transaction.creditUpdate != null) {
        final update = transaction.creditUpdate!;
        final operator = update.isIncrement ? '+' : '-';

        await db.customUpdate(
          'UPDATE customers SET credit_used_cents = credit_used_cents $operator ? WHERE id = ?',
          variables: [
            Variable.withInt(update.amountCents),
            Variable.withInt(update.customerId),
          ],
          updates: {db.customers},
        );
      }

      return saleId;
    });
  }

  @override
  Future<void> executeSaleCancellation(
    SaleCancellationTransaction transaction,
  ) async {
    return db.transaction(() async {
      // 1. Update Sale Status
      await (db.update(
        db.sales,
      )..where((t) => t.id.equals(transaction.saleId))).write(
        drift_db.SalesCompanion(
          status: Value(SaleStatus.cancelled.name),
          cancelledBy: Value(transaction.userId),
          cancelledAt: Value(transaction.cancelledAt),
          cancellationReason: Value(transaction.reason),
        ),
      );

      // 2. Restore Lots
      if (transaction.restoreInventory) {
        final lotDeductions = await (db.select(db.saleItemLots).join([
          innerJoin(
            db.saleItems,
            db.saleItems.id.equalsExp(db.saleItemLots.saleItemId),
          ),
        ])..where(db.saleItems.saleId.equals(transaction.saleId))).get();

        for (final row in lotDeductions) {
          final deduction = row.readTable(db.saleItemLots);
          await db.customUpdate(
            'UPDATE inventory_lots SET quantity = quantity + ? WHERE id = ?',
            variables: [
              Variable.withReal(deduction.quantityDeducted),
              Variable.withInt(deduction.lotId),
            ],
            updates: {db.inventoryLots},
          );
        }
      }

      // 3. Restore Inventory
      if (transaction.restoreInventory) {
        final sale = await (db.select(
          db.sales,
        )..where((t) => t.id.equals(transaction.saleId))).getSingle();
        final items = await (db.select(
          db.saleItems,
        )..where((t) => t.saleId.equals(transaction.saleId))).get();

        for (final item in items) {
          double quantityToRestore = item.quantity;

          if (item.variantId != null) {
            final variant = await (db.select(
              db.productVariants,
            )..where((t) => t.id.equals(item.variantId!))).getSingleOrNull();
            if (variant != null) {
              quantityToRestore = item.quantity * variant.quantity;
            }
          }

          // Update Inventory
          await db.customUpdate(
            'UPDATE inventory SET quantity_on_hand = quantity_on_hand + ?, updated_at = ? WHERE product_id = ? AND warehouse_id = ?',
            variables: [
              Variable.withReal(quantityToRestore),
              Variable.withString(DateTime.now().toIso8601String()),
              Variable.withInt(item.productId),
              Variable.withInt(sale.warehouseId),
            ],
            updates: {db.inventory},
          );

          // Get current qty for movement record
          final invRow =
              await (db.select(db.inventory)..where(
                    (t) =>
                        t.productId.equals(item.productId) &
                        t.warehouseId.equals(sale.warehouseId),
                  ))
                  .getSingle();

          await db
              .into(db.inventoryMovements)
              .insert(
                drift_db.InventoryMovementsCompanion.insert(
                  productId: item.productId,
                  warehouseId: sale.warehouseId,
                  movementType: 'return',
                  quantity: quantityToRestore,
                  quantityBefore: invRow.quantityOnHand - quantityToRestore,
                  quantityAfter: invRow.quantityOnHand,
                  referenceType: Value('sale_cancellation'),
                  referenceId: Value(sale.id),
                  reason: Value('Sale cancelled: ${transaction.reason}'),
                  performedBy: transaction.userId,
                  movementDate: Value(transaction.cancelledAt),
                ),
              );
        }
      }
    });
  }

  @override
  Future<String> generateNextSaleNumber() async {
    final query = db.select(db.sales)
      ..orderBy([(t) => OrderingTerm.desc(t.id)])
      ..limit(1);
    final row = await query.getSingleOrNull();

    if (row == null) {
      return 'SALE-00001';
    }

    final lastNumber = row.saleNumber;
    try {
      final numberPart = int.parse(lastNumber.split('-').last);
      final nextNumber = numberPart + 1;
      return 'SALE-${nextNumber.toString().padLeft(5, '0')}';
    } catch (_) {
      // Fallback if format is weird
      return 'SALE-${(row.id + 1).toString().padLeft(5, '0')}';
    }
  }
}
