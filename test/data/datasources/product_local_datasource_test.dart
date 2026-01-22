import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:posventa/data/datasources/local/database/app_database.dart';
import 'package:posventa/data/datasources/product_local_datasource_impl.dart';
import 'package:posventa/data/models/product_model.dart';
import 'package:posventa/data/models/product_variant_model.dart';
import 'package:posventa/domain/entities/product_variant.dart';

void main() {
  late AppDatabase database;
  late ProductLocalDataSourceImpl dataSource;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    dataSource = ProductLocalDataSourceImpl(database);

    // Seed dependencies
    await database
        .into(database.warehouses)
        .insert(
          WarehousesCompanion.insert(
            id: const Value(1),
            name: 'Main',
            code: 'MAIN',
            address: const Value('Addr'),
          ),
        );
    await database
        .into(database.departments)
        .insert(
          DepartmentsCompanion.insert(
            id: const Value(1),
            name: 'Dept',
            code: 'DEPT',
          ),
        );
    await database
        .into(database.categories)
        .insert(
          CategoriesCompanion.insert(
            id: const Value(1),
            name: 'Cat',
            code: 'CAT',
            departmentId: 1,
          ),
        );
  });

  tearDown(() => database.close());

  test(
    'createProduct redirects stock from linked purchase variant to target variant',
    () async {
      // 1. Create a dummy "Sales" variant/product to link TO.
      final p1 = ProductModel(
        code: 'P1',
        name: 'P1',
        description: 'D1',
        departmentId: 1,
        categoryId: 1,
        isSoldByWeight: false,
        isActive: true,
        hasExpiration: false,
        variants: [
          ProductVariantModel(
            productId: 0,
            variantName: 'Sales',
            priceCents: 100,
            costPriceCents: 50,
            type: VariantType.sales,
            // stock: 0, // Removed
            quantity: 1.0,
            isActive: true,
            isForSale: true,
          ),
        ],
      );
      final p1Id = await dataSource.createProduct(p1);
      final p1Data = await dataSource.getProductById(p1Id);
      final salesVariantId = p1Data!.variants![0].id;

      // 2. Create Product P2 with a Purchase variant linked to P1's Sales Variant.
      // Stock: 10 Boxes. Conversion: 12.
      final p2 = ProductModel(
        code: 'P2',
        name: 'P2',
        description: 'D2',
        departmentId: 1,
        categoryId: 1,
        isSoldByWeight: false,
        isActive: true,
        hasExpiration: false,
        variants: [
          ProductVariantModel(
            productId: 0,
            variantName: 'Box',
            priceCents: 1000,
            costPriceCents: 500,
            type: VariantType.purchase,
            linkedVariantId: salesVariantId, // Linked to existing variant
            // stock: 10.0, // Removed
            conversionFactor: 12.0,
            quantity: 1.0,
            isActive: true,
            isForSale: true,
          ),
        ],
      );

      final p2Id = await dataSource.createProduct(p2);
      final p2Data = await dataSource.getProductById(p2Id);
      final purchaseVariantId = p2Data!.variants![0].id;

      // 3. Verify Stock Redirected to Sales Variant (ID: salesVariantId)
      // Expected Qty = 10 * 12 = 120.
      // Expected Unit Cost = 500 / 12 ~= 42.

      final lots = await database.select(database.inventoryLots).get();

      // Should find lot for Sales Variant
      final salesLot = lots
          .where((l) => l.variantId == salesVariantId)
          .firstOrNull;
      expect(
        salesLot,
        isNotNull,
        reason: 'Should have created lot for target variant',
      );
      expect(salesLot!.quantity, 120.0);

      // Should NOT find lot for Purchase Variant
      final purchaseLot = lots
          .where((l) => l.variantId == purchaseVariantId)
          .firstOrNull;
      expect(
        purchaseLot,
        isNull,
        reason: 'Should not create lot for purchase variant',
      );

      // Verify Inventory Table
      final inv = await database.select(database.inventory).get();
      final salesInv = inv
          .where((i) => i.variantId == salesVariantId)
          .firstOrNull;
      expect(salesInv, isNotNull);
      expect(salesInv!.quantityOnHand, 120.0);
    },
  );
}
