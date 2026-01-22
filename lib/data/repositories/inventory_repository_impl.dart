import 'package:drift/drift.dart';
import 'package:posventa/data/datasources/local/database/app_database.dart'
    as drift_db;
import 'package:posventa/data/models/inventory_model.dart';
import 'package:posventa/domain/entities/inventory.dart';
import 'package:posventa/domain/entities/inventory_movement.dart';
import 'package:posventa/domain/repositories/inventory_repository.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  final drift_db.AppDatabase db;

  InventoryRepositoryImpl(this.db);

  @override
  Stream<List<Inventory>> getAllInventoryStream() {
    return (db.select(db.inventory)).watch().map(
      (rows) => rows
          .map(
            (row) => InventoryModel(
              id: row.id,
              productId: row.productId,
              warehouseId: row.warehouseId,
              variantId: row.variantId,
              quantityOnHand: row.quantityOnHand,
              quantityReserved: row.quantityReserved,
              updatedAt: row.updatedAt,
            ),
          )
          .toList(),
    );
  }

  @override
  Future<List<Inventory>> getAllInventory() async {
    final rows = await db.select(db.inventory).get();

    // Fetch variants to filter out 'purchase' type (Show only Sales variants)
    final variants = await db.select(db.productVariants).get();
    final purchaseVariantIds = variants
        .where((v) => v.type == 'purchase')
        .map((v) => v.id)
        .toSet();

    final filteredRows = rows
        .where(
          (row) =>
              row.variantId == null ||
              !purchaseVariantIds.contains(row.variantId),
        )
        .toList();

    return filteredRows.map<Inventory>((row) {
      return InventoryModel(
        id: row.id,
        productId: row.productId,
        warehouseId: row.warehouseId,
        variantId: row.variantId,
        quantityOnHand: row.quantityOnHand,
        quantityReserved: row.quantityReserved,
        updatedAt: row.updatedAt,
      );
    }).toList();
  }

  @override
  Future<void> createInventory(Inventory inventory) async {
    await db
        .into(db.inventory)
        .insert(
          drift_db.InventoryCompanion.insert(
            productId: inventory.productId,
            warehouseId: inventory.warehouseId,
            quantityOnHand: Value(inventory.quantityOnHand),
            quantityReserved: Value(inventory.quantityReserved),
            updatedAt: Value(DateTime.now()),
            variantId: Value(inventory.variantId),
          ),
        );
  }

  @override
  Future<void> deleteInventory(int id) async {
    await db.transaction(() async {
      // 1. Get info
      final row = await (db.select(
        db.inventory,
      )..where((t) => t.id.equals(id))).getSingleOrNull();
      if (row == null) return;

      // 2. Delete lots
      final q = db.delete(db.inventoryLots)
        ..where(
          (t) =>
              t.productId.equals(row.productId) &
              t.warehouseId.equals(row.warehouseId),
        );

      if (row.variantId != null) {
        q.where((t) => t.variantId.equals(row.variantId!));
      }
      await q.go();

      // 3. Delete inventory
      await (db.delete(db.inventory)..where((t) => t.id.equals(id))).go();
    });
  }

  @override
  Future<void> deleteInventoryForProductVariant(
    int productId,
    int warehouseId,
    int variantId,
  ) async {
    await db.transaction(() async {
      // 1. Delete Lots
      await (db.delete(db.inventoryLots)..where(
            (t) =>
                t.productId.equals(productId) &
                t.warehouseId.equals(warehouseId) &
                t.variantId.equals(variantId),
          ))
          .go();

      // 2. Delete Inventory
      await (db.delete(db.inventory)..where(
            (t) =>
                t.productId.equals(productId) &
                t.warehouseId.equals(warehouseId) &
                t.variantId.equals(variantId),
          ))
          .go();
    });
  }

  @override
  Future<Inventory?> getInventoryById(int id) async {
    final row = await (db.select(
      db.inventory,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row != null) {
      return InventoryModel(
        id: row.id,
        productId: row.productId,
        warehouseId: row.warehouseId,
        variantId: row.variantId,
        quantityOnHand: row.quantityOnHand,
        quantityReserved: row.quantityReserved,
        updatedAt: row.updatedAt,
      );
    }
    return null;
  }

  @override
  Future<List<Inventory>> getInventoryByProduct(int productId) async {
    final rows = await (db.select(
      db.inventory,
    )..where((t) => t.productId.equals(productId))).get();
    return rows
        .map<Inventory>(
          (row) => InventoryModel(
            id: row.id,
            productId: row.productId,
            warehouseId: row.warehouseId,
            variantId: row.variantId,
            quantityOnHand: row.quantityOnHand,
            quantityReserved: row.quantityReserved,
            updatedAt: row.updatedAt,
          ),
        )
        .toList();
  }

  @override
  Future<List<Inventory>> getInventoryByWarehouse(int warehouseId) async {
    final rows = await (db.select(
      db.inventory,
    )..where((t) => t.warehouseId.equals(warehouseId))).get();
    return rows
        .map<Inventory>(
          (row) => InventoryModel(
            id: row.id,
            productId: row.productId,
            warehouseId: row.warehouseId,
            variantId: row.variantId,
            quantityOnHand: row.quantityOnHand,
            quantityReserved: row.quantityReserved,
            updatedAt: row.updatedAt,
          ),
        )
        .toList();
  }

  @override
  Future<void> updateInventory(Inventory inventory) async {
    await (db.update(
      db.inventory,
    )..where((t) => t.id.equals(inventory.id!))).write(
      drift_db.InventoryCompanion(
        quantityOnHand: Value(inventory.quantityOnHand),
        quantityReserved: Value(inventory.quantityReserved),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<void> adjustInventory(InventoryMovement movement) async {
    await db.transaction(() async {
      final q = db.select(db.inventory)
        ..where(
          (t) =>
              t.productId.equals(movement.productId) &
              t.warehouseId.equals(movement.warehouseId),
        );

      if (movement.variantId != null) {
        q.where((t) => t.variantId.equals(movement.variantId!));
      } else {
        q.where((t) => t.variantId.isNull());
      }

      final existing = await q.getSingleOrNull();

      if (existing == null) {
        // Insert
        await db
            .into(db.inventory)
            .insert(
              drift_db.InventoryCompanion.insert(
                productId: movement.productId,
                warehouseId: movement.warehouseId,
                quantityOnHand: Value(movement.quantity),
                quantityReserved: Value(0.0),
                updatedAt: Value(DateTime.now()),
                variantId: Value(movement.variantId),
              ),
            );
      } else {
        // Update
        // Note: movement.quantity is the CHANGE amount for adjustments, generally?
        // Wait, the previous impl logic:
        // 'quantity_on_hand': movement.quantity (for initial insert)
        // SET quantity_on_hand = quantity_on_hand + ? (for update)
        // So yes, movement.quantity is the DELTA.

        await (db.update(
          db.inventory,
        )..where((t) => t.id.equals(existing.id))).write(
          drift_db.InventoryCompanion(
            quantityOnHand: Value(existing.quantityOnHand + movement.quantity),
            updatedAt: Value(DateTime.now()),
          ),
        );
      }

      // Create Movement Record
      await db
          .into(db.inventoryMovements)
          .insert(
            drift_db.InventoryMovementsCompanion.insert(
              productId: movement.productId,
              warehouseId: movement.warehouseId,
              movementType: movement.movementType.value,
              quantity: movement.quantity,
              quantityBefore: movement.quantityBefore,
              quantityAfter: movement.quantityAfter,
              referenceType: Value(movement.referenceType),
              referenceId: Value(movement.referenceId),
              lotId: Value(movement.lotId),
              reason: Value(movement.reason),
              performedBy: movement.performedBy,
              movementDate: Value(DateTime.now()),
            ),
          );
    });
  }

  @override
  Future<void> adjustInventoryBatch(List<InventoryMovement> movements) async {
    await db.transaction(() async {
      for (final movement in movements) {
        // Keep logic same as adjustInventory
        final q = db.select(db.inventory)
          ..where(
            (t) =>
                t.productId.equals(movement.productId) &
                t.warehouseId.equals(movement.warehouseId),
          );

        if (movement.variantId != null) {
          q.where((t) => t.variantId.equals(movement.variantId!));
        } else {
          q.where((t) => t.variantId.isNull());
        }

        final existing = await q.getSingleOrNull();

        if (existing == null) {
          await db
              .into(db.inventory)
              .insert(
                drift_db.InventoryCompanion.insert(
                  productId: movement.productId,
                  warehouseId: movement.warehouseId,
                  quantityOnHand: Value(movement.quantity),
                  quantityReserved: Value(0.0),
                  updatedAt: Value(DateTime.now()),
                  variantId: Value(movement.variantId),
                ),
              );
        } else {
          await (db.update(
            db.inventory,
          )..where((t) => t.id.equals(existing.id))).write(
            drift_db.InventoryCompanion(
              quantityOnHand: Value(
                existing.quantityOnHand + movement.quantity,
              ),
              updatedAt: Value(DateTime.now()),
            ),
          );
        }

        await db
            .into(db.inventoryMovements)
            .insert(
              drift_db.InventoryMovementsCompanion.insert(
                productId: movement.productId,
                warehouseId: movement.warehouseId,
                movementType: movement.movementType.value,
                quantity: movement.quantity,
                quantityBefore: movement.quantityBefore,
                quantityAfter: movement.quantityAfter,
                referenceType: Value(movement.referenceType),
                referenceId: Value(movement.referenceId),
                lotId: Value(movement.lotId),
                reason: Value(movement.reason),
                performedBy: movement.performedBy,
                movementDate: Value(DateTime.now()),
              ),
            );
      }
    });
  }

  @override
  Future<void> transferInventory({
    required int fromWarehouseId,
    required int toWarehouseId,
    required int productId,
    required double quantity,
    required int userId,
    String? reason,
  }) async {
    await db.transaction(() async {
      // 1. Source (OUT)
      final source =
          await (db.select(db.inventory)..where(
                (t) =>
                    t.productId.equals(productId) &
                    t.warehouseId.equals(fromWarehouseId),
              ))
              .getSingleOrNull();

      if (source == null) throw Exception('Source inventory not found');
      if (source.quantityOnHand < quantity) {
        throw Exception('Insufficient stock in source warehouse');
      }

      await (db.update(
        db.inventory,
      )..where((t) => t.id.equals(source.id))).write(
        drift_db.InventoryCompanion(
          quantityOnHand: Value(source.quantityOnHand - quantity),
          updatedAt: Value(DateTime.now()),
        ),
      );

      await db
          .into(db.inventoryMovements)
          .insert(
            drift_db.InventoryMovementsCompanion.insert(
              productId: productId,
              warehouseId: fromWarehouseId,
              movementType: 'transfer_out',
              quantity: -quantity,
              quantityBefore: source.quantityOnHand,
              quantityAfter: source.quantityOnHand - quantity,
              referenceType: Value('transfer'),
              reason: Value(reason ?? 'Transfer to Warehouse $toWarehouseId'),
              performedBy: userId,
              movementDate: Value(DateTime.now()),
            ),
          );

      // 2. Destination (IN)
      final dest =
          await (db.select(db.inventory)..where(
                (t) =>
                    t.productId.equals(productId) &
                    t.warehouseId.equals(toWarehouseId),
              ))
              .getSingleOrNull();

      double destQtyBefore = 0;
      if (dest == null) {
        await db
            .into(db.inventory)
            .insert(
              drift_db.InventoryCompanion.insert(
                productId: productId,
                warehouseId: toWarehouseId,
                quantityOnHand: Value(quantity),
                quantityReserved: Value(0.0),
                updatedAt: Value(DateTime.now()),
              ),
            );
      } else {
        destQtyBefore = dest.quantityOnHand;
        await (db.update(
          db.inventory,
        )..where((t) => t.id.equals(dest.id))).write(
          drift_db.InventoryCompanion(
            quantityOnHand: Value(dest.quantityOnHand + quantity),
            updatedAt: Value(DateTime.now()),
          ),
        );
      }

      await db
          .into(db.inventoryMovements)
          .insert(
            drift_db.InventoryMovementsCompanion.insert(
              productId: productId,
              warehouseId: toWarehouseId,
              movementType: 'transfer_in',
              quantity: quantity,
              quantityBefore: destQtyBefore,
              quantityAfter: destQtyBefore + quantity,
              referenceType: Value('transfer'),
              reason: Value(
                reason ?? 'Transfer from Warehouse $fromWarehouseId',
              ),
              performedBy: userId,
              movementDate: Value(DateTime.now()),
            ),
          );
    });
  }

  @override
  Future<void> recalculateInventory(int productId) async {
    await db.transaction(() async {
      // 1. Fetch all lots for the product
      final lots = await (db.select(
        db.inventoryLots,
      )..where((t) => t.productId.equals(productId))).get();

      // 2. Aggregate quantity by (variant, warehouse)
      final aggregated = <String, double>{};
      for (final lot in lots) {
        final key = '${lot.variantId}-${lot.warehouseId}';
        aggregated[key] = (aggregated[key] ?? 0) + lot.quantity;
      }

      // 3. Update or Insert Inventory records
      // First, get existing inventory records for this product
      final existingInventory = await (db.select(
        db.inventory,
      )..where((t) => t.productId.equals(productId))).get();

      final existingMap = <String, drift_db.InventoryData>{};
      for (final item in existingInventory) {
        final key = '${item.variantId}-${item.warehouseId}';
        existingMap[key] = item;
      }

      // Process aggregated data
      for (final entry in aggregated.entries) {
        final parts = entry.key.split('-');
        final variantId = parts[0] == 'null' ? null : int.parse(parts[0]);
        final warehouseId = int.parse(parts[1]);
        final quantity = entry.value;

        // Check if exists
        final existingItem = existingMap[entry.key];

        if (existingItem != null) {
          // Update
          if (existingItem.quantityOnHand != quantity) {
            await (db.update(
              db.inventory,
            )..where((t) => t.id.equals(existingItem.id))).write(
              drift_db.InventoryCompanion(
                quantityOnHand: Value(quantity),
                updatedAt: Value(DateTime.now()),
              ),
            );
          }
          // Remove from map to track what's handled
          existingMap.remove(entry.key);
        } else {
          // Insert
          await db
              .into(db.inventory)
              .insert(
                drift_db.InventoryCompanion.insert(
                  productId: productId,
                  warehouseId: warehouseId,
                  variantId: Value(variantId),
                  quantityOnHand: Value(quantity),
                  quantityReserved: const Value(0),
                  updatedAt: Value(DateTime.now()),
                ),
              );
        }
      }

      // 4. Handle remaining existing items (entry in inventory but no lots -> stock 0)
      for (final item in existingMap.values) {
        if (item.quantityOnHand != 0) {
          await (db.update(
            db.inventory,
          )..where((t) => t.id.equals(item.id))).write(
            drift_db.InventoryCompanion(
              quantityOnHand: const Value(0),
              updatedAt: Value(DateTime.now()),
            ),
          );
        }
      }
    });
  }

  @override
  Future<void> resetAllInventory() async {
    await db.transaction(() async {
      await db.delete(db.inventoryLots).go();
      await db.delete(db.inventory).go();
    });
  }
}
