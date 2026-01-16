import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:posventa/data/datasources/local/database/tables.dart';
import 'package:posventa/core/constants/permission_constants.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Users,
    Permissions,
    UserPermissions,
    Notifications,
    Stores,
    AppMeta,
    Transactions,
    Departments,
    Categories,
    Brands,
    UnitsOfMeasure,
    TaxRates,
    Products,
    ProductVariants,
    ProductTaxes,
    Warehouses,
    Inventory,
    InventoryLots,
    InventoryMovements,
    Customers,
    Suppliers,
    Sales,
    SaleItems,
    SaleItemTaxes,
    SalePayments,
    SaleReturns,
    SaleReturnItems,
    SaleItemLots,
    Purchases,
    Purchases,
    PurchaseItems,
    CashSessions,
    CashMovements,
    CustomerPayments,
    AuditLogs,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 39; // Bumped to 39

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'pos',
      native: const DriftNativeOptions(shareAcrossIsolates: true),
    );
  }

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 37) {
        // Migration to version 37: Add credit columns to customers table
        await m.addColumn(customers, customers.creditLimitCents);
        await m.addColumn(customers, customers.creditUsedCents);
      }
      if (from < 38) {
        // Migration to version 38: Create customer_payments table
        await m.createTable(customerPayments);
      }
      if (from < 39) {
        // Migration to 39: Add credit/allocation columns
        await m.addColumn(customerPayments, customerPayments.status);
        await m.addColumn(customerPayments, customerPayments.type);
        await m.addColumn(customerPayments, customerPayments.saleId);

        await m.addColumn(sales, sales.balanceCents);
        await m.addColumn(sales, sales.amountPaidCents);
        await m.addColumn(sales, sales.paymentStatus);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');

      // FIX: Sanitize inventory.updated_at if it contains text strings (from previous bug)
      // This prevents "FormatException: Invalid radix-10 number"
      await customStatement(
        "UPDATE inventory SET updated_at = CAST(strftime('%s', updated_at) AS INTEGER) WHERE typeof(updated_at) = 'text'",
      );

      // Seed permissions if empty
      final countFunc = permissions.id.count();
      final query = selectOnly(permissions)..addColumns([countFunc]);
      final result = await query.getSingle();
      final permissionCount = result.read(countFunc);
      if (permissionCount == 0 || permissionCount == null) {
        await batch((batch) {
          batch.insertAll(permissions, [
            PermissionsCompanion.insert(
              name: 'Acceso a PV',
              code: PermissionConstants.posAccess,
              module: 'pos',
              description: Value('Acceso al módulo de Punto de Venta'),
            ),
            PermissionsCompanion.insert(
              name: 'Descuentos POS',
              code: PermissionConstants.posDiscount,
              module: 'pos',
              description: Value('Permite aplicar descuentos en el POS'),
            ),
            PermissionsCompanion.insert(
              name: 'Reembolsos POS',
              code: PermissionConstants.posRefund,
              module: 'pos',
              description: Value('Permite procesar reembolsos/devoluciones'),
            ),
            PermissionsCompanion.insert(
              name: 'Anular Ítems',
              code: PermissionConstants.posVoidItem,
              module: 'pos',
              description: Value('Permite anular ítems en una venta'),
            ),
            PermissionsCompanion.insert(
              name: 'Apertura de Caja',
              code: PermissionConstants.cashOpen,
              module: 'cash',
              description: Value('Permite abrir sesiones de caja'),
            ),
            PermissionsCompanion.insert(
              name: 'Cierre de Caja',
              code: PermissionConstants.cashClose,
              module: 'cash',
              description: Value('Permite cerrar sesiones de caja'),
            ),
            PermissionsCompanion.insert(
              name: 'Movimientos de Caja',
              code: PermissionConstants.cashMovement,
              module: 'cash',
              description: Value(
                'Permite registrar entradas/salidas de efectivo',
              ),
            ),
            PermissionsCompanion.insert(
              name: 'Ver Inventario',
              code: PermissionConstants.inventoryView,
              module: 'inventory',
              description: Value('Permite visualizar el inventario'),
            ),
            PermissionsCompanion.insert(
              name: 'Ajustar Inventario',
              code: PermissionConstants.inventoryAdjust,
              module: 'inventory',
              description: Value('Permite realizar ajustes de inventario'),
            ),
            PermissionsCompanion.insert(
              name: 'Ver Reportes',
              code: PermissionConstants.reportsView,
              module: 'reports',
              description: Value('Permite visualizar reportes y estadísticas'),
            ),
            PermissionsCompanion.insert(
              name: 'Gestionar Catálogo',
              code: PermissionConstants.catalogManage,
              module: 'catalog',
              description: Value('Permite crear/editar productos y categorías'),
            ),
            PermissionsCompanion.insert(
              name: 'Gestionar Clientes',
              code: PermissionConstants.customerManage,
              module: 'customer',
              description: Value('Permite crear/editar clientes'),
            ),
          ]);
        });
      }

      // Seed units if empty
      final unitsCountFunc = unitsOfMeasure.id.count();
      final unitsQuery = selectOnly(unitsOfMeasure)
        ..addColumns([unitsCountFunc]);
      final unitsResult = await unitsQuery.getSingle();
      final unitsCount = unitsResult.read(unitsCountFunc);

      if (unitsCount == 0 || unitsCount == null) {
        await batch((batch) {
          batch.insertAll(unitsOfMeasure, [
            UnitsOfMeasureCompanion.insert(code: 'un', name: 'Unidad'),
            UnitsOfMeasureCompanion.insert(code: 'kg', name: 'Kilogramo'),
            UnitsOfMeasureCompanion.insert(code: 'g', name: 'Gramo'),
            UnitsOfMeasureCompanion.insert(code: 'l', name: 'Litro'),
            UnitsOfMeasureCompanion.insert(code: 'ml', name: 'Mililitro'),
            UnitsOfMeasureCompanion.insert(code: 'm', name: 'Metro'),
            UnitsOfMeasureCompanion.insert(code: 'cm', name: 'Centímetro'),
            UnitsOfMeasureCompanion.insert(code: 'srv', name: 'Servicio'),
          ]);
        });
      }

      // Seed tax rates if empty
      final taxCountFunc = taxRates.id.count();
      final taxQuery = selectOnly(taxRates)..addColumns([taxCountFunc]);
      final taxResult = await taxQuery.getSingle();
      final taxCount = taxResult.read(taxCountFunc);

      if (taxCount == 0 || taxCount == null) {
        await batch((batch) {
          batch.insertAll(taxRates, [
            TaxRatesCompanion.insert(
              name: 'IVA 16%',
              code: 'IVA_16',
              rate: 0.16,
              isDefault: const Value(true),
              isEditable: const Value(false),
            ),
            TaxRatesCompanion.insert(
              name: 'Exento 0%',
              code: 'EXENTO',
              rate: 0.0,
              isDefault: const Value(false),
              isEditable: const Value(false),
            ),
            TaxRatesCompanion.insert(
              name: 'IVA 8%',
              code: 'IVA_8',
              rate: 0.08,
              isDefault: const Value(false),
              isEditable: const Value(true),
            ),
          ]);
        });
      }
    },
  );
}
