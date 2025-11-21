import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import 'package:posventa/data/datasources/database_helper.dart';
import 'package:posventa/domain/entities/inventory_movement.dart';
import 'package:posventa/data/repositories/inventory_repository_impl.dart';
import 'package:posventa/data/repositories/sale_repository_impl.dart';
import 'package:posventa/domain/entities/sale.dart';
import 'package:posventa/domain/entities/sale_item.dart';
import 'package:posventa/domain/entities/sale_payment.dart';

void main() {
  // Initialize FFI
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Database db;
  late InventoryRepositoryImpl inventoryRepository;
  late SaleRepositoryImpl saleRepository;

  setUp(() async {
    // Initialize DatabaseHelper
    // This will create the DB file in a temp directory and run onCreate if needed
    db = await DatabaseHelper.instance.database;

    // Clear all tables to ensure clean state
    // We need to delete in correct order due to foreign keys
    await db.delete(DatabaseHelper.tableInventoryMovements);
    await db.delete(DatabaseHelper.tableInventory);
    await db.delete(DatabaseHelper.tableSaleItemTaxes);
    await db.delete(DatabaseHelper.tableSaleItems);
    await db.delete(DatabaseHelper.tableSalePayments);
    await db.delete(DatabaseHelper.tableSales);
    await db.delete(DatabaseHelper.tableProducts);
    await db.delete(DatabaseHelper.tableCategories); // Add this
    await db.delete(DatabaseHelper.tableDepartments); // Add this
    await db.delete(DatabaseHelper.tableWarehouses);
    await db.delete(DatabaseHelper.tableUsers);
    // Add other tables if necessary, but these are the main ones for our test

    // Instantiate repositories
    inventoryRepository = InventoryRepositoryImpl(DatabaseHelper.instance);
    saleRepository = SaleRepositoryImpl(DatabaseHelper.instance);

    // Insert Seed Data
    await db.insert('users', {
      'id': 1,
      'username': 'admin',
      'password_hash': 'hash',
      'role': 'admin',
      'first_name': 'Admin',
      'last_name': 'User',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });

    await db.insert('warehouses', {
      'id': 1,
      'name': 'Main Warehouse',
      'code': 'MAIN',
      'is_main': 1,
    });

    await db.insert('warehouses', {
      'id': 2,
      'name': 'Secondary Warehouse',
      'code': 'SEC',
      'is_main': 0,
    });

    // We need departments and categories for products due to FK constraints in real schema
    await db.insert('departments', {'id': 1, 'name': 'General', 'code': 'GEN'});

    await db.insert('categories', {
      'id': 1,
      'name': 'General',
      'code': 'GEN',
      'department_id': 1,
    });

    await db.insert('products', {
      'id': 1,
      'code': 'P001',
      'name': 'Test Product',
      'sale_price_cents': 1000,
      'department_id': 1,
      'category_id': 1,
    });

    // Initial Inventory
    await db.insert('inventory', {
      'product_id': 1,
      'warehouse_id': 1,
      'quantity_on_hand': 100.0,
    });

    await db.insert('inventory', {
      'product_id': 1,
      'warehouse_id': 2,
      'quantity_on_hand': 0.0,
    });
  });

  test(
    'Adjustment Flow: Adjust Inventory adds stock and creates movement',
    () async {
      // Action: Adjust Inventory (+10)
      final movement = InventoryMovement(
        productId: 1,
        warehouseId: 1,
        movementType: MovementType.adjustment,
        quantity: 10,
        quantityBefore: 0,
        quantityAfter: 10,
        performedBy: 1,
        reason: 'Initial Stock',
        movementDate: DateTime.now(),
      );

      await inventoryRepository.adjustInventory(movement);

      // Verify Inventory
      final inv = await db.query(
        'inventory',
        where: 'product_id = ? AND warehouse_id = ?',
        whereArgs: [1, 1],
      );
      // Initial 100 + 10 = 110
      expect(inv.first['quantity_on_hand'], 110.0);

      // Verify Movement
      final moves = await db.query('inventory_movements');
      expect(moves.length, 1);
      expect(moves.first['movement_type'], 'adjustment');
      expect(moves.first['quantity'], 10.0);
    },
  );

  test('Transfer Flow: Transfer moves stock and creates 2 movements', () async {
    // Action: Transfer 20 from W1 to W2
    await inventoryRepository.transferInventory(
      fromWarehouseId: 1,
      toWarehouseId: 2,
      productId: 1,
      quantity: 20,
      userId: 1,
      reason: 'Restock',
    );

    // Verify Inventory
    final inv1 = await db.query(
      'inventory',
      where: 'warehouse_id = ?',
      whereArgs: [1],
    );
    final inv2 = await db.query(
      'inventory',
      where: 'warehouse_id = ?',
      whereArgs: [2],
    );

    expect(inv1.first['quantity_on_hand'], 80.0); // 100 - 20
    expect(inv2.first['quantity_on_hand'], 20.0); // 0 + 20

    // Verify Movements
    final moves = await db.query(
      'inventory_movements',
      orderBy: 'id DESC',
      limit: 2,
    );
    expect(moves.length, 2);

    final types = moves.map((m) => m['movement_type']).toList();
    expect(types, containsAll(['transfer_out', 'transfer_in']));
  });

  test('Sale Flow: Sale reduces stock and creates sale movement', () async {
    // Action: Create Sale of 5 items
    final sale = Sale(
      saleNumber: 'S-001',
      warehouseId: 1,
      cashierId: 1,
      subtotalCents: 5000,
      taxCents: 0,
      totalCents: 5000,
      status: SaleStatus.completed,
      saleDate: DateTime.now(),
      createdAt: DateTime.now(),
      items: [
        SaleItem(
          productId: 1,
          quantity: 5,
          unitOfMeasure: 'pieza',
          unitPriceCents: 1000,
          subtotalCents: 5000,
          totalCents: 5000,
          costPriceCents: 500,
        ),
      ],
      payments: [
        SalePayment(
          paymentMethod: 'cash',
          amountCents: 5000,
          receivedBy: 1,
          paymentDate: DateTime.now(),
        ),
      ],
    );

    await saleRepository.createSale(sale);

    // Verify Inventory
    final inv = await db.query(
      'inventory',
      where: 'warehouse_id = ?',
      whereArgs: [1],
    );
    expect(inv.first['quantity_on_hand'], 95.0); // 100 - 5

    // Verify Movement
    final moves = await db.query(
      'inventory_movements',
      where: "movement_type = 'sale'",
    );
    expect(moves.length, 1);
    expect(moves.first['quantity'], -5.0);
  });

  test(
    'Return Flow: Cancel Sale restores stock and creates return movement',
    () async {
      // Setup: Create a sale first
      final sale = Sale(
        saleNumber: 'S-002',
        warehouseId: 1,
        cashierId: 1,
        subtotalCents: 5000,
        taxCents: 0,
        totalCents: 5000,
        status: SaleStatus.completed,
        saleDate: DateTime.now(),
        createdAt: DateTime.now(),
        items: [
          SaleItem(
            productId: 1,
            quantity: 5,
            unitOfMeasure: 'pieza',
            unitPriceCents: 1000,
            subtotalCents: 5000,
            totalCents: 5000,
            costPriceCents: 500,
          ),
        ],
        payments: [],
      );
      final saleId = await saleRepository.createSale(sale);

      // Verify initial stock deduction (100 - 5 = 95)
      var inv = await db.query(
        'inventory',
        where: 'warehouse_id = ?',
        whereArgs: [1],
      );
      expect(inv.first['quantity_on_hand'], 95.0);

      // Action: Cancel Sale
      await saleRepository.cancelSale(saleId, 1, 'Customer changed mind');

      // Verify Inventory Restored
      inv = await db.query(
        'inventory',
        where: 'warehouse_id = ?',
        whereArgs: [1],
      );
      expect(inv.first['quantity_on_hand'], 100.0); // 95 + 5

      // Verify Movement
      final moves = await db.query(
        'inventory_movements',
        where: "movement_type = 'return'",
      );
      expect(moves.length, 1);
      expect(moves.first['quantity'], 5.0);
    },
  );
}
