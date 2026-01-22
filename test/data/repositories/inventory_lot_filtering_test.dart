import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:posventa/data/datasources/local/database/app_database.dart';
import 'package:posventa/data/repositories/inventory_lot_repository_impl.dart';

void main() {
  late AppDatabase database;
  late InventoryLotRepositoryImpl repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = InventoryLotRepositoryImpl(database);
  });

  tearDown(() => database.close());

  test(
    'getAvailableLots should return lots with quantity > 0 and correct variantId',
    () async {
      final now = DateTime.now();

      // 1. Setup Data
      // Product P=1, Warehouse W=1.
      // Variant V=1 (Sales).
      // Lots:
      // L1: Qty 12, Var 1.
      // L2: Qty 0, Var 1.
      // L3: Qty 5, Var 2.

      await database
          .into(database.inventoryLots)
          .insert(
            InventoryLotsCompanion.insert(
              productId: 1,
              warehouseId: 1,
              lotNumber: 'L1',
              quantity: const Value(12.0),
              unitCostCents: 100,
              totalCostCents: 1200,
              variantId: const Value(1),
              receivedAt: Value(now),
            ),
          );

      await database
          .into(database.inventoryLots)
          .insert(
            InventoryLotsCompanion.insert(
              productId: 1,
              warehouseId: 1,
              lotNumber: 'L2',
              quantity: const Value(0.0), // Empty
              unitCostCents: 100,
              totalCostCents: 0,
              variantId: const Value(1),
              receivedAt: Value(now),
            ),
          );

      // 2. Call availableLots (mimic provider)
      // NOTE: provider doesn't pass variantId to repository.
      final allAvailable = await repository.getAvailableLots(1, 1);

      // Should return L1. Should NOT return L2.
      expect(allAvailable.length, 1);
      expect(allAvailable.first.lotNumber, 'L1');

      // 3. Mimic Client-Side Filtering in InventoryLotsPage
      final variantId = 1;
      final filtered = allAvailable
          .where((l) => l.variantId == variantId)
          .toList();

      expect(filtered.length, 1);
      expect(filtered.first.lotNumber, 'L1');
    },
  );
}
