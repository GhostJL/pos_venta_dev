import 'package:drift/drift.dart';
import 'package:intl/intl.dart';
import 'package:posventa/data/datasources/local/database/app_database.dart'
    as drift_db;
import 'package:posventa/data/models/inventory_lot_model.dart';
import 'package:posventa/domain/entities/inventory_lot.dart';
import 'package:posventa/domain/repositories/inventory_lot_repository.dart';

class InventoryLotRepositoryImpl implements InventoryLotRepository {
  final drift_db.AppDatabase db;

  InventoryLotRepositoryImpl(this.db);

  @override
  Future<List<InventoryLot>> getLotsByProduct(
    int productId,
    int warehouseId,
  ) async {
    final rows =
        await (db.select(db.inventoryLots)
              ..where(
                (t) =>
                    t.productId.equals(productId) &
                    t.warehouseId.equals(warehouseId),
              )
              ..orderBy([(t) => OrderingTerm.desc(t.receivedAt)]))
            .get();

    return rows
        .map(
          (row) => InventoryLotModel(
            id: row.id,
            productId: row.productId,
            warehouseId: row.warehouseId,
            variantId: row.variantId,
            lotNumber: row.lotNumber,
            quantity: row.quantity,
            originalQuantity: row.originalQuantity,
            unitCostCents: row.unitCostCents,
            totalCostCents: row.totalCostCents,
            receivedAt: row.receivedAt,
            expirationDate: row.expirationDate,
          ),
        )
        .toList();
  }

  @override
  Future<List<InventoryLot>> getAvailableLots(
    int productId,
    int warehouseId, {
    int? variantId,
  }) async {
    final q = db.select(db.inventoryLots)
      ..where(
        (t) =>
            t.productId.equals(productId) &
            t.warehouseId.equals(warehouseId) &
            t.quantity.isBiggerThanValue(0),
      );

    if (variantId != null) {
      q.where((t) => t.variantId.equals(variantId));
    }

    q.orderBy([(t) => OrderingTerm.asc(t.receivedAt)]); // FIFO

    final rows = await q.get();
    return rows
        .map(
          (row) => InventoryLotModel(
            id: row.id,
            productId: row.productId,
            warehouseId: row.warehouseId,
            variantId: row.variantId,
            lotNumber: row.lotNumber,
            quantity: row.quantity,
            originalQuantity: row.originalQuantity,
            unitCostCents: row.unitCostCents,
            totalCostCents: row.totalCostCents,
            receivedAt: row.receivedAt,
            expirationDate: row.expirationDate,
          ),
        )
        .toList();
  }

  @override
  Future<InventoryLot?> getLotById(int id) async {
    final row = await (db.select(
      db.inventoryLots,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row != null) {
      return InventoryLotModel(
        id: row.id,
        productId: row.productId,
        warehouseId: row.warehouseId,
        variantId: row.variantId,
        lotNumber: row.lotNumber,
        quantity: row.quantity,
        originalQuantity: row.originalQuantity,
        unitCostCents: row.unitCostCents,
        totalCostCents: row.totalCostCents,
        receivedAt: row.receivedAt,
        expirationDate: row.expirationDate,
      );
    }
    return null;
  }

  @override
  Future<int> createLot(InventoryLot lot) async {
    return await db
        .into(db.inventoryLots)
        .insert(
          drift_db.InventoryLotsCompanion.insert(
            productId: lot.productId,
            warehouseId: lot.warehouseId,
            lotNumber: lot.lotNumber,
            quantity: Value(lot.quantity),
            // When creating, original = initial quantity
            originalQuantity: Value(lot.quantity),
            receivedAt: Value(lot.receivedAt),
            unitCostCents: lot.unitCostCents,
            totalCostCents: lot.totalCostCents,
            variantId: Value(lot.variantId),
            expirationDate: Value(lot.expirationDate),
          ),
        );
  }

  @override
  Future<void> updateLotQuantity(int lotId, double newQuantity) async {
    await (db.update(db.inventoryLots)..where((t) => t.id.equals(lotId))).write(
      drift_db.InventoryLotsCompanion(quantity: Value(newQuantity)),
    );
  }

  @override
  String generateLotNumber() {
    final now = DateTime.now();
    final dateFormat = DateFormat('yyyyMMdd');
    final timeFormat = DateFormat('HHmmss');
    // Format: LOT-YYYYMMDD-HHMMSS
    return 'LOT-${dateFormat.format(now)}-${timeFormat.format(now)}';
  }

  @override
  Future<List<InventoryLot>> getExpiringLots(
    int warehouseId,
    int withinDays,
  ) async {
    final expirationDate = DateTime.now().add(Duration(days: withinDays));

    final rows =
        await (db.select(db.inventoryLots)
              ..where(
                (t) =>
                    t.warehouseId.equals(warehouseId) &
                    t.expirationDate.isNotNull() &
                    t.expirationDate.isSmallerOrEqualValue(expirationDate) &
                    t.quantity.isBiggerThanValue(0),
              )
              ..orderBy([(t) => OrderingTerm.asc(t.expirationDate)]))
            .get();

    return rows
        .map(
          (row) => InventoryLotModel(
            id: row.id,
            productId: row.productId,
            warehouseId: row.warehouseId,
            variantId: row.variantId,
            lotNumber: row.lotNumber,
            quantity: row.quantity,
            originalQuantity: row.originalQuantity,
            unitCostCents: row.unitCostCents,
            totalCostCents: row.totalCostCents,
            receivedAt: row.receivedAt,
            expirationDate: row.expirationDate,
          ),
        )
        .toList();
  }

  @override
  Future<List<InventoryLot>> getLotsByWarehouse(int warehouseId) async {
    final rows =
        await (db.select(db.inventoryLots)
              ..where((t) => t.warehouseId.equals(warehouseId))
              ..orderBy([(t) => OrderingTerm.desc(t.receivedAt)]))
            .get();

    return rows
        .map(
          (row) => InventoryLotModel(
            id: row.id,
            productId: row.productId,
            warehouseId: row.warehouseId,
            variantId: row.variantId,
            lotNumber: row.lotNumber,
            quantity: row.quantity,
            originalQuantity: row.originalQuantity,
            unitCostCents: row.unitCostCents,
            totalCostCents: row.totalCostCents,
            receivedAt: row.receivedAt,
            expirationDate: row.expirationDate,
          ),
        )
        .toList();
  }
}
