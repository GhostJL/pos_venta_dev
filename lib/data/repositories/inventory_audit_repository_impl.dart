import 'package:drift/drift.dart';
import 'package:posventa/data/datasources/local/database/app_database.dart'
    as drift_db;
import 'package:posventa/domain/entities/inventory_audit.dart';
import 'package:posventa/domain/repositories/inventory_audit_repository.dart';

class InventoryAuditRepositoryImpl implements InventoryAuditRepository {
  final drift_db.AppDatabase db;

  InventoryAuditRepositoryImpl(this.db);

  @override
  Future<List<InventoryAuditEntity>> getAllAudits() async {
    final rows = await db.select(db.inventoryAudits).get();
    return rows.map((row) => _mapToEntity(row)).toList();
  }

  @override
  Future<InventoryAuditEntity?> getAuditById(int id) async {
    final row = await (db.select(
      db.inventoryAudits,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row == null) return null;

    final items = await getAuditItems(id);
    return _mapToEntity(row).copyWith(items: items);
  }

  @override
  Future<int> createAudit(InventoryAuditEntity audit) async {
    return await db
        .into(db.inventoryAudits)
        .insert(
          drift_db.InventoryAuditsCompanion.insert(
            auditDate: audit.auditDate,
            warehouseId: audit.warehouseId,
            performedBy: audit.performedBy,
            status: Value(audit.status.name),
            notes: Value(audit.notes),
            createdAt: Value(DateTime.now()),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  @override
  Future<void> updateAudit(InventoryAuditEntity audit) async {
    await (db.update(
      db.inventoryAudits,
    )..where((t) => t.id.equals(audit.id!))).write(
      drift_db.InventoryAuditsCompanion(
        status: Value(audit.status.name),
        notes: Value(audit.notes),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<void> deleteAudit(int id) async {
    await (db.delete(db.inventoryAudits)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<List<InventoryAuditItemEntity>> getAuditItems(int auditId) async {
    final query = db.select(db.inventoryAuditItems).join([
      innerJoin(
        db.products,
        db.products.id.equalsExp(db.inventoryAuditItems.productId),
      ),
      leftOuterJoin(
        db.productVariants,
        db.productVariants.id.equalsExp(db.inventoryAuditItems.variantId),
      ),
    ])..where(db.inventoryAuditItems.auditId.equals(auditId));

    final rows = await query.get();
    return rows.map((row) {
      final item = row.readTable(db.inventoryAuditItems);
      final product = row.readTable(db.products);
      final variant = row.readTableOrNull(db.productVariants);

      return InventoryAuditItemEntity(
        id: item.id,
        auditId: item.auditId,
        productId: item.productId,
        variantId: item.variantId,
        expectedQuantity: item.expectedQuantity,
        countedQuantity: item.countedQuantity,
        countedAt: item.countedAt,
        productName: product.name,
        variantName: variant?.variantName,
        barcode: variant?.barcode ?? product.code,
      );
    }).toList();
  }

  @override
  Future<void> updateAuditItem(InventoryAuditItemEntity item) async {
    await (db.update(
      db.inventoryAuditItems,
    )..where((t) => t.id.equals(item.id!))).write(
      drift_db.InventoryAuditItemsCompanion(
        countedQuantity: Value(item.countedQuantity),
        countedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<void> createAuditItems(List<InventoryAuditItemEntity> items) async {
    await db.batch((batch) {
      batch.insertAll(
        db.inventoryAuditItems,
        items
            .map(
              (item) => drift_db.InventoryAuditItemsCompanion.insert(
                auditId: item.auditId,
                productId: item.productId,
                variantId: Value(item.variantId),
                expectedQuantity: item.expectedQuantity,
                countedQuantity: Value(item.countedQuantity),
                countedAt: Value(item.countedAt),
              ),
            )
            .toList(),
      );
    });
  }

  @override
  Future<void> completeAudit(int auditId, int performedBy) async {
    await db.transaction(() async {
      final auditRow = await (db.select(
        db.inventoryAudits,
      )..where((t) => t.id.equals(auditId))).getSingle();
      final items = await getAuditItems(auditId);

      for (final item in items) {
        final difference = item.difference;
        if (difference.abs() > 0.0001) {
          // Reconcile stock
          // 1. Update Inventory Table
          final existingInv =
              await (db.select(db.inventory)..where(
                    (t) =>
                        t.productId.equals(item.productId) &
                        t.warehouseId.equals(auditRow.warehouseId) &
                        (item.variantId != null
                            ? t.variantId.equals(item.variantId!)
                            : t.variantId.isNull()),
                  ))
                  .getSingleOrNull();

          double quantityBefore = existingInv?.quantityOnHand ?? 0.0;
          double quantityAfter = item.countedQuantity;

          if (existingInv != null) {
            await (db.update(
              db.inventory,
            )..where((t) => t.id.equals(existingInv.id))).write(
              drift_db.InventoryCompanion(
                quantityOnHand: Value(quantityAfter),
                updatedAt: Value(DateTime.now()),
              ),
            );
          } else {
            await db
                .into(db.inventory)
                .insert(
                  drift_db.InventoryCompanion.insert(
                    productId: item.productId,
                    warehouseId: auditRow.warehouseId,
                    variantId: Value(item.variantId),
                    quantityOnHand: Value(quantityAfter),
                    quantityReserved: const Value(0.0),
                    updatedAt: Value(DateTime.now()),
                  ),
                );
          }

          // 2. Create Movement
          await db
              .into(db.inventoryMovements)
              .insert(
                drift_db.InventoryMovementsCompanion.insert(
                  productId: item.productId,
                  warehouseId: auditRow.warehouseId,
                  variantId: Value(item.variantId),
                  movementType: 'reconciliation',
                  quantity: difference,
                  quantityBefore: quantityBefore,
                  quantityAfter: quantityAfter,
                  referenceType: const Value('audit'),
                  referenceId: Value(auditId),
                  reason: Value('Inventory Audit #$auditId reconciliation'),
                  performedBy: performedBy,
                  movementDate: Value(DateTime.now()),
                ),
              );
        }
      }

      // Update Audit status
      await (db.update(
        db.inventoryAudits,
      )..where((t) => t.id.equals(auditId))).write(
        drift_db.InventoryAuditsCompanion(
          status: const Value('completed'),
          updatedAt: Value(DateTime.now()),
        ),
      );
    });
  }

  @override
  Future<void> cancelAudit(int auditId) async {
    await (db.update(
      db.inventoryAudits,
    )..where((t) => t.id.equals(auditId))).write(
      const drift_db.InventoryAuditsCompanion(status: Value('cancelled')),
    );
  }

  InventoryAuditEntity _mapToEntity(drift_db.InventoryAudit row) {
    return InventoryAuditEntity(
      id: row.id,
      auditDate: row.auditDate,
      warehouseId: row.warehouseId,
      performedBy: row.performedBy,
      status: InventoryAuditStatus.values.firstWhere(
        (e) => e.name == row.status,
      ),
      notes: row.notes,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}
