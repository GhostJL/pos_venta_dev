import 'package:drift/drift.dart';
import 'package:posventa/data/datasources/local/database/app_database.dart';

class SyncInventoryWithLotsUseCase {
  final AppDatabase db;

  SyncInventoryWithLotsUseCase(this.db);

  Future<void> call() async {
    // 1. Get all Inventory records
    final inventoryList = await db.select(db.inventory).get();

    for (final inv in inventoryList) {
      // 2. Sum lots for this specific inventory slot (Product + Variant + Warehouse)
      final lotsQuery = db.selectOnly(db.inventoryLots)
        ..addColumns([db.inventoryLots.quantity.sum()])
        ..where(
          db.inventoryLots.productId.equals(inv.productId) &
              db.inventoryLots.warehouseId.equals(inv.warehouseId) &
              (inv.variantId != null
                  ? db.inventoryLots.variantId.equals(inv.variantId!)
                  : db.inventoryLots.variantId.isNull()),
        );

      final result = await lotsQuery.getSingle();
      final totalLotsQuantity =
          result.read(db.inventoryLots.quantity.sum()) ?? 0.0;

      // 3. Update Inventory if different
      if ((inv.quantityOnHand - totalLotsQuantity).abs() > 0.001) {
        await (db.update(
          db.inventory,
        )..where((t) => t.id.equals(inv.id))).write(
          InventoryCompanion(
            quantityOnHand: Value(totalLotsQuantity),
            updatedAt: Value(DateTime.now()),
          ),
        );
      }
    }
  }
}
