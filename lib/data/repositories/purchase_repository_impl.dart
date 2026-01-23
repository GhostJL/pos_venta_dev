import 'package:drift/drift.dart';
import 'package:posventa/data/datasources/local/database/app_database.dart'
    as drift_db;
import 'package:posventa/data/models/purchase_item_model.dart';
import 'package:posventa/data/models/purchase_model.dart';
import 'package:posventa/domain/entities/inventory_lot.dart';
import 'package:posventa/domain/entities/inventory_movement.dart';
import 'package:posventa/domain/entities/purchase.dart';
import 'package:posventa/domain/entities/purchase_reception_transaction.dart';
import 'package:posventa/domain/repositories/purchase_repository.dart';

class PurchaseRepositoryImpl implements PurchaseRepository {
  final drift_db.AppDatabase db;

  PurchaseRepositoryImpl(this.db);

  @override
  Future<List<Purchase>> getPurchases({
    String? query,
    PurchaseStatus? status,
    int? limit,
    int? offset,
  }) async {
    final q = db.select(db.purchases).join([
      leftOuterJoin(
        db.suppliers,
        db.suppliers.id.equalsExp(db.purchases.supplierId),
      ),
    ]);

    if (query != null && query.isNotEmpty) {
      final search = '%$query%';
      q.where(
        db.purchases.purchaseNumber.like(search) |
            db.suppliers.name.like(search) |
            db.purchases.status.like(search),
      );
    }

    if (status != null) {
      q.where(db.purchases.status.equals(status.name));
    }

    q.orderBy([OrderingTerm.desc(db.purchases.createdAt)]);

    if (limit != null) {
      q.limit(limit, offset: offset);
    }

    final rows = await q.get();
    final purchases = <Purchase>[];

    for (final row in rows) {
      final purchaseRow = row.readTable(db.purchases);
      final supplierRow = row.readTableOrNull(db.suppliers);

      // Load items
      final itemsRows = await (db.select(
        db.purchaseItems,
      )..where((t) => t.purchaseId.equals(purchaseRow.id))).get();
      final items = itemsRows
          .map(
            (i) => PurchaseItemModel(
              id: i.id,
              purchaseId: i.purchaseId,
              productId: i.productId,
              variantId: i.variantId,
              quantity: i.quantity,
              quantityReceived: i.quantityReceived,
              unitOfMeasure: i.unitOfMeasure,
              unitCostCents: i.unitCostCents,
              subtotalCents: i.subtotalCents,
              taxCents: i.taxCents,
              totalCents: i.totalCents,
              lotId: i.lotId,
              expirationDate: i.expirationDate,
              createdAt: i.createdAt,
            ),
          )
          .toList();

      purchases.add(
        PurchaseModel(
          id: purchaseRow.id,
          purchaseNumber: purchaseRow.purchaseNumber,
          supplierId: purchaseRow.supplierId,
          warehouseId: purchaseRow.warehouseId,
          subtotalCents: purchaseRow.subtotalCents,
          taxCents: purchaseRow.taxCents,
          totalCents: purchaseRow.totalCents,
          status: PurchaseStatus.values.firstWhere(
            (e) => e.name == purchaseRow.status,
            orElse: () => PurchaseStatus.pending,
          ),
          purchaseDate: purchaseRow.purchaseDate,
          receivedDate: purchaseRow.receivedDate,
          supplierInvoiceNumber: purchaseRow.supplierInvoiceNumber,
          requestedBy: purchaseRow.requestedBy,
          receivedBy: purchaseRow.receivedBy,
          cancelledBy: purchaseRow.cancelledBy,
          createdAt: purchaseRow.createdAt,
          items: items,
          supplierName: supplierRow?.name,
        ),
      );
    }
    return purchases;
  }

  @override
  Future<int> countPurchases({String? query, PurchaseStatus? status}) async {
    final q = db.selectOnly(db.purchases).join([
      leftOuterJoin(
        db.suppliers,
        db.suppliers.id.equalsExp(db.purchases.supplierId),
      ),
    ]);
    q.addColumns([db.purchases.id.count()]);

    if (query != null && query.isNotEmpty) {
      final search = '%$query%';
      q.where(
        db.purchases.purchaseNumber.like(search) |
            db.suppliers.name.like(search) |
            db.purchases.status.like(search),
      );
    }

    if (status != null) {
      q.where(db.purchases.status.equals(status.name));
    }

    final result = await q.getSingle();
    return result.read(db.purchases.id.count()) ?? 0;
  }

  @override
  Future<Purchase?> getPurchaseById(int id) async {
    final q = db.select(db.purchases).join([
      leftOuterJoin(
        db.suppliers,
        db.suppliers.id.equalsExp(db.purchases.supplierId),
      ),
    ])..where(db.purchases.id.equals(id));

    final row = await q.getSingleOrNull();
    if (row == null) return null;

    final purchaseRow = row.readTable(db.purchases);
    final supplierRow = row.readTableOrNull(db.suppliers);

    // Get Items
    // Define alias for linked variants
    final linkedVariants = db.productVariants.createAlias('linked_variants');

    final itemsRows = await (db.select(db.purchaseItems).join([
      leftOuterJoin(
        db.products,
        db.products.id.equalsExp(db.purchaseItems.productId),
      ),
      leftOuterJoin(
        db.productVariants,
        db.productVariants.id.equalsExp(db.purchaseItems.variantId),
      ),
      leftOuterJoin(
        linkedVariants,
        linkedVariants.id.equalsExp(db.productVariants.linkedVariantId),
      ),
    ])..where(db.purchaseItems.purchaseId.equals(id))).get();

    final items = itemsRows.map((iRow) {
      final item = iRow.readTable(db.purchaseItems);
      final product = iRow.readTableOrNull(db.products);
      final variant = iRow.readTableOrNull(db.productVariants);
      final linkedVariant = iRow.readTableOrNull(linkedVariants);

      return PurchaseItemModel(
        id: item.id,
        purchaseId: item.purchaseId,
        productId: item.productId,
        variantId: item.variantId,
        quantity: item.quantity,
        quantityReceived: item.quantityReceived,
        unitOfMeasure: item.unitOfMeasure,
        unitCostCents: item.unitCostCents,
        subtotalCents: item.subtotalCents,
        taxCents: item.taxCents,
        totalCents: item.totalCents,
        lotId: item.lotId,
        expirationDate: item.expirationDate,
        createdAt: item.createdAt,
        productName: product?.name,
        variantName: variant?.variantName,
        linkedVariantName: linkedVariant?.variantName,
      );
    }).toList();

    return PurchaseModel(
      id: purchaseRow.id,
      purchaseNumber: purchaseRow.purchaseNumber,
      supplierId: purchaseRow.supplierId,
      warehouseId: purchaseRow.warehouseId,
      subtotalCents: purchaseRow.subtotalCents,
      taxCents: purchaseRow.taxCents,
      totalCents: purchaseRow.totalCents,
      status: PurchaseStatus.values.firstWhere(
        (e) => e.name == purchaseRow.status,
        orElse: () => PurchaseStatus.pending,
      ),
      purchaseDate: purchaseRow.purchaseDate,
      receivedDate: purchaseRow.receivedDate,
      supplierInvoiceNumber: purchaseRow.supplierInvoiceNumber,
      requestedBy: purchaseRow.requestedBy,
      receivedBy: purchaseRow.receivedBy,
      cancelledBy: purchaseRow.cancelledBy,
      createdAt: purchaseRow.createdAt,
      items: items,
      supplierName: supplierRow?.name,
    );
  }

  @override
  Future<int> createPurchase(Purchase purchase) async {
    return await db.transaction(() async {
      final purchaseId = await db
          .into(db.purchases)
          .insert(
            drift_db.PurchasesCompanion.insert(
              purchaseNumber: purchase.purchaseNumber,
              supplierId: purchase.supplierId,
              warehouseId: purchase.warehouseId,
              subtotalCents: purchase.subtotalCents,
              taxCents: Value(purchase.taxCents),
              totalCents: purchase.totalCents,
              status: Value(purchase.status.name),
              purchaseDate: purchase.purchaseDate,
              requestedBy: purchase.requestedBy,
              supplierInvoiceNumber: Value(purchase.supplierInvoiceNumber),
              createdAt: Value(purchase.createdAt),
            ),
          );

      for (final item in purchase.items) {
        await db
            .into(db.purchaseItems)
            .insert(
              drift_db.PurchaseItemsCompanion.insert(
                purchaseId: purchaseId,
                productId: item.productId,
                variantId: Value(item.variantId),
                quantity: item.quantity,
                unitOfMeasure: item.unitOfMeasure,
                unitCostCents: item.unitCostCents,
                subtotalCents: item.subtotalCents,
                taxCents: Value(item.taxCents),
                totalCents: item.totalCents,
                lotId: Value(item.lotId),
                expirationDate: Value(item.expirationDate),
                createdAt: Value(item.createdAt),
              ),
            );
      }
      return purchaseId;
    });
  }

  @override
  Future<void> updatePurchase(Purchase purchase) async {
    await db.transaction(() async {
      await (db.update(
        db.purchases,
      )..where((t) => t.id.equals(purchase.id!))).write(
        drift_db.PurchasesCompanion(
          supplierId: Value(purchase.supplierId),
          warehouseId: Value(purchase.warehouseId),
          subtotalCents: Value(purchase.subtotalCents),
          taxCents: Value(purchase.taxCents),
          totalCents: Value(purchase.totalCents),
          status: Value(purchase.status.name),
          purchaseDate: Value(purchase.purchaseDate),
          supplierInvoiceNumber: Value(purchase.supplierInvoiceNumber),
        ),
      );

      // Delete existing items and re-insert
      await (db.delete(
        db.purchaseItems,
      )..where((t) => t.purchaseId.equals(purchase.id!))).go();

      for (final item in purchase.items) {
        await db
            .into(db.purchaseItems)
            .insert(
              drift_db.PurchaseItemsCompanion.insert(
                purchaseId: purchase.id!,
                productId: item.productId,
                variantId: Value(item.variantId),
                quantity: item.quantity,
                unitOfMeasure: item.unitOfMeasure,
                unitCostCents: item.unitCostCents,
                subtotalCents: item.subtotalCents,
                taxCents: Value(item.taxCents),
                totalCents: item.totalCents,
                lotId: Value(item.lotId),
                expirationDate: Value(item.expirationDate),
                createdAt: Value(item.createdAt),
              ),
            );
      }
    });
  }

  @override
  Future<void> deletePurchase(int id) async {
    await (db.delete(db.purchases)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<void> executePurchaseReception(
    PurchaseReceptionTransaction transaction,
  ) async {
    await db.transaction(() async {
      // 1. Insert new inventory lots and track their IDs
      final lotIdMap = await _insertInventoryLots(transaction.newLots);

      // 2. Update purchase items with received quantities and lot references
      await _updatePurchaseItems(transaction.itemUpdates, lotIdMap);

      // 3. Record inventory movements
      await _recordInventoryMovements(transaction.movements, lotIdMap);

      // 4. Update variant costs
      await _updateVariantCosts(transaction.variantUpdates);

      // 5. Update purchase status
      await _updatePurchaseStatus(transaction);
    });
  }

  /// Insert new inventory lots and return a map of lot entities to their database IDs
  Future<Map<InventoryLot, int>> _insertInventoryLots(
    List<InventoryLot> newLots,
  ) async {
    final lotIdMap = <InventoryLot, int>{};

    for (final lot in newLots) {
      final lotId = await db
          .into(db.inventoryLots)
          .insert(
            drift_db.InventoryLotsCompanion.insert(
              productId: lot.productId,
              warehouseId: lot.warehouseId,
              lotNumber: lot.lotNumber,
              quantity: Value(lot.quantity),
              originalQuantity: Value(lot.originalQuantity),
              receivedAt: Value(lot.receivedAt),
              unitCostCents: lot.unitCostCents,
              totalCostCents: lot.totalCostCents,
              variantId: Value(lot.variantId),
              expirationDate: Value(lot.expirationDate),
            ),
          );
      lotIdMap[lot] = lotId;
    }

    return lotIdMap;
  }

  /// Update purchase items with received quantities and lot references
  Future<void> _updatePurchaseItems(
    List<PurchaseItemUpdate> itemUpdates,
    Map<InventoryLot, int> lotIdMap,
  ) async {
    for (final update in itemUpdates) {
      int? finalLotId;
      if (update.newLot != null && lotIdMap.containsKey(update.newLot)) {
        finalLotId = lotIdMap[update.newLot];
      } else if (update.lotId != null) {
        finalLotId = update.lotId;
      }

      await (db.update(
        db.purchaseItems,
      )..where((t) => t.id.equals(update.itemId))).write(
        drift_db.PurchaseItemsCompanion(
          quantityReceived: Value(update.quantityReceived),
          lotId: Value(finalLotId),
        ),
      );
    }
  }

  // _adjustInventoryQuantities removed (handled by triggers)

  /// Record inventory movements for audit trail
  Future<void> _recordInventoryMovements(
    List<InventoryMovement> movements,
    Map<InventoryLot, int> lotIdMap,
  ) async {
    for (final mov in movements) {
      final invRow =
          await (db.select(db.inventory)..where(
                (t) =>
                    t.productId.equals(mov.productId) &
                    t.warehouseId.equals(mov.warehouseId) &
                    (mov.variantId != null
                        ? t.variantId.equals(mov.variantId!)
                        : t.variantId.isNull()),
              ))
              .getSingleOrNull();

      final currentQty = invRow?.quantityOnHand ?? 0.0;

      // Resolve lot ID from the map if not already set
      int? resolvedLotId = mov.lotId;
      if (resolvedLotId == null) {
        for (final entry in lotIdMap.entries) {
          if (entry.key.productId == mov.productId &&
              entry.key.quantity == mov.quantity) {
            resolvedLotId = entry.value;
            break;
          }
        }
      }

      await db
          .into(db.inventoryMovements)
          .insert(
            drift_db.InventoryMovementsCompanion.insert(
              productId: mov.productId,
              warehouseId: mov.warehouseId,
              movementType: mov.movementType.value,
              quantity: mov.quantity,
              quantityBefore: currentQty - mov.quantity,
              quantityAfter: currentQty,
              reason: Value(mov.reason),
              performedBy: mov.performedBy,
              referenceType: Value(mov.referenceType),
              referenceId: Value(mov.referenceId),
              lotId: Value(resolvedLotId),
              movementDate: Value(mov.movementDate),
              variantId: Value(mov.variantId),
            ),
          );
    }
  }

  /// Update variant costs with latest purchase prices (Last Cost policy)
  Future<void> _updateVariantCosts(
    List<ProductVariantUpdate> variantUpdates,
  ) async {
    for (final update in variantUpdates) {
      await (db.update(
        db.productVariants,
      )..where((t) => t.id.equals(update.variantId))).write(
        drift_db.ProductVariantsCompanion(
          costPriceCents: Value(update.newCostPriceCents),
          updatedAt: Value(DateTime.now()),
        ),
      );
    }
  }

  /// Update purchase status and metadata after reception
  Future<void> _updatePurchaseStatus(
    PurchaseReceptionTransaction transaction,
  ) async {
    await (db.update(
      db.purchases,
    )..where((t) => t.id.equals(transaction.purchaseId))).write(
      drift_db.PurchasesCompanion(
        status: Value(transaction.newStatus),
        receivedDate: Value(transaction.receivedDate),
        receivedBy: Value(transaction.receivedBy),
      ),
    );
  }

  @override
  Future<void> cancelPurchase(int purchaseId, int userId) async {
    await db.transaction(() async {
      final items = await (db.select(
        db.purchaseItems,
      )..where((t) => t.purchaseId.equals(purchaseId))).get();
      final purchase = await (db.select(
        db.purchases,
      )..where((t) => t.id.equals(purchaseId))).getSingle();

      for (final item in items) {
        if (item.quantityReceived > 0) {
          // Atomic inventory deduction using SQL
          // This prevents race conditions in concurrent operations
          await db.customUpdate(
            '''UPDATE inventory 
               SET quantity_on_hand = quantity_on_hand - ? 
               WHERE product_id = ? AND warehouse_id = ?''',
            variables: [
              Variable.withReal(item.quantityReceived),
              Variable.withInt(item.productId),
              Variable.withInt(purchase.warehouseId),
            ],
            updates: {db.inventory},
          );

          // Record movement
          final invRow =
              await (db.select(db.inventory)..where(
                    (t) =>
                        t.productId.equals(item.productId) &
                        t.warehouseId.equals(purchase.warehouseId),
                  ))
                  .getSingle(); // Get current stock after update? or before?

          // To be safe and clean:
          // 1. Get current stock
          // 2. new = current - amount
          // 3. update db
          // 4. log movement (before: current, after: new)
          // But customUpdate is atomic.
          // If I use customUpdate, I don't know the exact resulting row unless I query again.

          // Re-query
          final updatedInv =
              await (db.select(db.inventory)..where(
                    (t) =>
                        t.productId.equals(item.productId) &
                        t.warehouseId.equals(purchase.warehouseId),
                  ))
                  .getSingle();

          await db
              .into(db.inventoryMovements)
              .insert(
                drift_db.InventoryMovementsCompanion.insert(
                  productId: item.productId,
                  warehouseId: purchase.warehouseId,
                  movementType: 'adjustment',
                  quantity: -item.quantityReceived,
                  quantityBefore:
                      updatedInv.quantityOnHand + item.quantityReceived,
                  quantityAfter: updatedInv.quantityOnHand,
                  referenceType: Value('purchase_cancellation'),
                  referenceId: Value(purchaseId),
                  reason: Value('Cancelación de Compra'),
                  performedBy: userId,
                  movementDate: Value(DateTime.now()),
                ),
              );
        }
      }

      await (db.update(
        db.purchases,
      )..where((t) => t.id.equals(purchaseId))).write(
        drift_db.PurchasesCompanion(
          status: Value('cancelled'),
          cancelledBy: Value(userId),
        ),
      );
    });
  }
}
