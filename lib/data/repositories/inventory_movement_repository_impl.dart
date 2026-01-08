import 'package:drift/drift.dart';
import 'package:posventa/data/datasources/local/database/app_database.dart'
    as drift_db;
import 'package:posventa/data/models/inventory_movement_model.dart';
import 'package:posventa/domain/entities/inventory_movement.dart';
import 'package:posventa/domain/repositories/inventory_movement_repository.dart';

class InventoryMovementRepositoryImpl implements InventoryMovementRepository {
  final drift_db.AppDatabase db;

  InventoryMovementRepositoryImpl(this.db);

  @override
  Future<void> createMovement(InventoryMovement movement) async {
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
            performedBy: movement.performedBy,
            movementDate: Value(movement.movementDate),
            variantId: Value(movement.variantId),
            referenceId: Value(movement.referenceId),
            lotId: Value(movement.lotId),
            reason: Value(movement.reason),
          ),
        );
  }

  @override
  Future<void> deleteMovement(int id) async {
    await (db.delete(
      db.inventoryMovements,
    )..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<List<InventoryMovement>> getAllMovements() async {
    final rows = await (db.select(
      db.inventoryMovements,
    )..orderBy([(t) => OrderingTerm.desc(t.movementDate)])).get();

    return rows
        .map(
          (row) => InventoryMovementModel(
            id: row.id,
            productId: row.productId,
            warehouseId: row.warehouseId,
            variantId: row.variantId,
            movementType: _parseMovementType(row.movementType),
            quantity: row.quantity,
            quantityBefore: row.quantityBefore,
            quantityAfter: row.quantityAfter,
            referenceType: row.referenceType,
            referenceId: row.referenceId,
            lotId: row.lotId,
            reason: row.reason,
            performedBy: row.performedBy,
            movementDate: row.movementDate,
          ),
        )
        .toList();
  }

  @override
  Future<InventoryMovement?> getMovementById(int id) async {
    final row = await (db.select(
      db.inventoryMovements,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row != null) {
      return InventoryMovementModel(
        id: row.id,
        productId: row.productId,
        warehouseId: row.warehouseId,
        variantId: row.variantId,
        movementType: _parseMovementType(row.movementType),
        quantity: row.quantity,
        quantityBefore: row.quantityBefore,
        quantityAfter: row.quantityAfter,
        referenceType: row.referenceType,
        referenceId: row.referenceId,
        lotId: row.lotId,
        reason: row.reason,
        performedBy: row.performedBy,
        movementDate: row.movementDate,
      );
    }
    return null;
  }

  @override
  Future<List<InventoryMovement>> getMovementsByProduct(
    int productId, {
    int? variantId,
  }) async {
    final q = db.select(db.inventoryMovements)
      ..where((t) => t.productId.equals(productId));

    if (variantId != null) {
      q.where((t) => t.variantId.equals(variantId));
    }

    q.orderBy([(t) => OrderingTerm.desc(t.movementDate)]);

    final rows = await q.get();
    return rows
        .map(
          (row) => InventoryMovementModel(
            id: row.id,
            productId: row.productId,
            warehouseId: row.warehouseId,
            variantId: row.variantId,
            movementType: _parseMovementType(row.movementType),
            quantity: row.quantity,
            quantityBefore: row.quantityBefore,
            quantityAfter: row.quantityAfter,
            referenceType: row.referenceType,
            referenceId: row.referenceId,
            lotId: row.lotId,
            reason: row.reason,
            performedBy: row.performedBy,
            movementDate: row.movementDate,
          ),
        )
        .toList();
  }

  @override
  Future<List<InventoryMovement>> getMovementsByWarehouse(
    int warehouseId,
  ) async {
    final rows =
        await (db.select(db.inventoryMovements)
              ..where((t) => t.warehouseId.equals(warehouseId))
              ..orderBy([(t) => OrderingTerm.desc(t.movementDate)]))
            .get();

    return rows
        .map(
          (row) => InventoryMovementModel(
            id: row.id,
            productId: row.productId,
            warehouseId: row.warehouseId,
            variantId: row.variantId,
            movementType: _parseMovementType(row.movementType),
            quantity: row.quantity,
            quantityBefore: row.quantityBefore,
            quantityAfter: row.quantityAfter,
            referenceType: row.referenceType,
            referenceId: row.referenceId,
            lotId: row.lotId,
            reason: row.reason,
            performedBy: row.performedBy,
            movementDate: row.movementDate,
          ),
        )
        .toList();
  }

  @override
  Future<List<InventoryMovement>> getMovementsByType(
    String movementType,
  ) async {
    final rows =
        await (db.select(db.inventoryMovements)
              ..where((t) => t.movementType.equals(movementType))
              ..orderBy([(t) => OrderingTerm.desc(t.movementDate)]))
            .get();

    return rows
        .map(
          (row) => InventoryMovementModel(
            id: row.id,
            productId: row.productId,
            warehouseId: row.warehouseId,
            variantId: row.variantId,
            movementType: _parseMovementType(row.movementType),
            quantity: row.quantity,
            quantityBefore: row.quantityBefore,
            quantityAfter: row.quantityAfter,
            referenceType: row.referenceType,
            referenceId: row.referenceId,
            lotId: row.lotId,
            reason: row.reason,
            performedBy: row.performedBy,
            movementDate: row.movementDate,
          ),
        )
        .toList();
  }

  @override
  Future<List<InventoryMovement>> getMovementsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final rows =
        await (db.select(db.inventoryMovements)
              ..where((t) => t.movementDate.isBetweenValues(startDate, endDate))
              ..orderBy([(t) => OrderingTerm.desc(t.movementDate)]))
            .get();

    return rows
        .map(
          (row) => InventoryMovementModel(
            id: row.id,
            productId: row.productId,
            warehouseId: row.warehouseId,
            variantId: row.variantId,
            movementType: _parseMovementType(row.movementType),
            quantity: row.quantity,
            quantityBefore: row.quantityBefore,
            quantityAfter: row.quantityAfter,
            referenceType: row.referenceType,
            referenceId: row.referenceId,
            lotId: row.lotId,
            reason: row.reason,
            performedBy: row.performedBy,
            movementDate: row.movementDate,
          ),
        )
        .toList();
  }

  @override
  Future<void> updateMovement(InventoryMovement movement) async {
    await (db.update(
      db.inventoryMovements,
    )..where((t) => t.id.equals(movement.id!))).write(
      drift_db.InventoryMovementsCompanion(
        productId: Value(movement.productId),
        warehouseId: Value(movement.warehouseId),
        variantId: Value(movement.variantId),
        movementType: Value(movement.movementType.value),
        quantity: Value(movement.quantity),
        quantityBefore: Value(movement.quantityBefore),
        quantityAfter: Value(movement.quantityAfter),
        referenceType: Value(movement.referenceType),
        referenceId: Value(movement.referenceId),
        lotId: Value(movement.lotId),
        reason: Value(movement.reason),
        performedBy: Value(movement.performedBy),
        movementDate: Value(movement.movementDate),
      ),
    );
  }

  MovementType _parseMovementType(String value) {
    return MovementType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => MovementType.adjustment,
    );
  }
}
