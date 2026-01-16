import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:posventa/data/datasources/local/database/app_database.dart';
import 'package:posventa/data/repositories/sale_repository_impl.dart';

void main() {
  late AppDatabase database;
  late SaleRepositoryImpl repository;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    repository = SaleRepositoryImpl(database);

    // Seed dependencies for Foreign Keys

    // 1. Store
    await database
        .into(database.stores)
        .insert(
          StoresCompanion.insert(
            id: const Value(1),
            name: 'Test Store',
            businessName: const Value('Test Business'),
            address: const Value('Address'),
          ),
        );

    // 2. Warehouse
    await database
        .into(database.warehouses)
        .insert(
          WarehousesCompanion.insert(
            id: const Value(1),
            name: 'Main Warehouse',
            code: 'MAIN',
            address: const Value('Address'),
          ),
        );

    // 3. User (Cashier)
    await database
        .into(database.users)
        .insert(
          UsersCompanion.insert(
            id: const Value(1),
            firstName: const Value('Test'),
            lastName: const Value('Cashier'), // Corrected names
            username: 'cashier',
            passwordHash: 'hash',
            role: 'cashier',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(), // Corrected to raw DateTime
          ),
        );

    // 4. Customer
    await database
        .into(database.customers)
        .insert(
          CustomersCompanion.insert(
            id: const Value(1),
            code: 'CUST001', // Added required code
            firstName: 'Test',
            lastName: 'Customer',
            phone: const Value('123'),
            email: const Value('test@test.com'),
            createdAt: Value(DateTime.now()), // Explicitly wrapped
          ),
        );
  });

  tearDown(() async {
    await database.close();
  });

  group('SaleRepositoryImpl - generateNextSaleNumber', () {
    test('should return SALE-00001 when table is empty', () async {
      final result = await repository.generateNextSaleNumber();
      expect(result, 'SALE-00001');
    });

    test('should increment correctly (SALE-00005 -> SALE-00006)', () async {
      // Insert a sale with SALE-00005
      await database
          .into(database.sales)
          .insert(
            SalesCompanion.insert(
              saleNumber: 'SALE-00005',
              warehouseId: 1,
              customerId: const Value(1),
              cashierId: 1,
              subtotalCents: 100,
              discountCents: const Value(0),
              taxCents: const Value(0),
              totalCents: 100,
              paymentStatus: const Value('paid'),
              status: const Value('completed'),
              saleDate: DateTime.now(),
            ),
          );

      final result = await repository.generateNextSaleNumber();
      expect(result, 'SALE-00006');
    });

    test(
      'should handle gaps by taking the last one (SALE-00010 -> SALE-00011)',
      () async {
        // Insert SALE-00001 and SALE-00010
        await database
            .into(database.sales)
            .insert(
              SalesCompanion.insert(
                saleNumber: 'SALE-00001',
                warehouseId: 1,
                customerId: const Value(1),
                cashierId: 1,
                subtotalCents: 100,
                discountCents: const Value(0),
                taxCents: const Value(0),
                totalCents: 100,
                paymentStatus: const Value('paid'),
                status: const Value('completed'),
                saleDate: DateTime.now(),
              ),
            );

        await database
            .into(database.sales)
            .insert(
              SalesCompanion.insert(
                saleNumber: 'SALE-00010',
                warehouseId: 1,
                customerId: const Value(1),
                cashierId: 1,
                subtotalCents: 100,
                discountCents: const Value(0),
                taxCents: const Value(0),
                totalCents: 100,
                paymentStatus: const Value('paid'),
                status: const Value('completed'),
                saleDate: DateTime.now(),
              ),
            );

        final result = await repository.generateNextSaleNumber();
        expect(result, 'SALE-00011');
      },
    );
  });
}
