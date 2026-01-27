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
    Discounts,
    ProductVariantDiscounts,
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
    SaleSequences, // Added for atomic sale number generation
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
    InventoryAudits,
    InventoryAuditItems,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 46; // Bumped to 46 for Spanish localization trigger

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'pos',
      native: const DriftNativeOptions(shareAcrossIsolates: true),
    );
  }

  void notifyInventoryUpdate() {
    markTablesUpdated({inventory});
  }

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 46) {
        // Migration to 46: Translate Trigger "audit_inventory_manual_changes" to Spanish
        await customStatement(
          'DROP TRIGGER IF EXISTS audit_inventory_manual_changes',
        );

        await customStatement('''
          CREATE TRIGGER IF NOT EXISTS audit_inventory_manual_changes
          AFTER UPDATE OF quantity_on_hand, quantity_reserved ON inventory
          WHEN NEW.quantity_on_hand != OLD.quantity_on_hand 
            OR NEW.quantity_reserved != OLD.quantity_reserved
          BEGIN
            INSERT INTO inventory_movements (
              product_id, warehouse_id, variant_id, movement_type,
              quantity, quantity_before, quantity_after,
              reason, performed_by, movement_date
            )
            VALUES (
              NEW.product_id, NEW.warehouse_id, NEW.variant_id, 'adjustment',
              NEW.quantity_on_hand - OLD.quantity_on_hand,
              OLD.quantity_on_hand, NEW.quantity_on_hand,
              'Registro automático de auditoría', 1, CAST(strftime('%s', 'now') AS INTEGER)
            );
          END;
        ''');
      }
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
      if (from < 40) {
        // Migration to 40: Add Discounts tables
        await m.createTable(discounts);
        await m.createTable(productVariantDiscounts);
      }
      if (from < 41) {
        // Migration to 41: Add original_quantity to InventoryLots
        await m.addColumn(inventoryLots, inventoryLots.originalQuantity);

        // Backfill existing lots: set original = current
        await customStatement(
          'UPDATE inventory_lots SET original_quantity = quantity',
        );
      }
      if (from < 42) {
        // Migration to 42: Add triggers for auto-sync and performance indexes

        // 1. Create triggers for automatic inventory synchronization
        // Note: These initial triggers had a bug (using CURRENT_TIMESTAMP).
        // Fixed in v43, but we keep v42 migration as history (or we could just override it if we assume sequential updates)
        // For safety, we reproduce them here as they were, knowing v43 will fix them.
        await customStatement('''
          CREATE TRIGGER IF NOT EXISTS sync_inventory_after_lot_insert
          AFTER INSERT ON inventory_lots
          BEGIN
            INSERT INTO inventory (product_id, warehouse_id, variant_id, quantity_on_hand, quantity_reserved, updated_at)
            VALUES (NEW.product_id, NEW.warehouse_id, NEW.variant_id, NEW.quantity, 0, CURRENT_TIMESTAMP)
            ON CONFLICT (product_id, warehouse_id, variant_id) DO UPDATE
            SET quantity_on_hand = quantity_on_hand + NEW.quantity,
                updated_at = CURRENT_TIMESTAMP;
          END;
        ''');

        await customStatement('''
          CREATE TRIGGER IF NOT EXISTS sync_inventory_after_lot_update
          AFTER UPDATE ON inventory_lots
          BEGIN
            UPDATE inventory
            SET quantity_on_hand = quantity_on_hand + (NEW.quantity - OLD.quantity),
                updated_at = CURRENT_TIMESTAMP
            WHERE product_id = NEW.product_id
              AND warehouse_id = NEW.warehouse_id
              AND (variant_id = NEW.variant_id OR (variant_id IS NULL AND NEW.variant_id IS NULL));
          END;
        ''');

        await customStatement('''
          CREATE TRIGGER IF NOT EXISTS sync_inventory_after_lot_delete
          AFTER DELETE ON inventory_lots
          BEGIN
            UPDATE inventory
            SET quantity_on_hand = quantity_on_hand - OLD.quantity,
                updated_at = CURRENT_TIMESTAMP
            WHERE product_id = OLD.product_id
              AND warehouse_id = OLD.warehouse_id
              AND (variant_id = OLD.variant_id OR (variant_id IS NULL AND OLD.variant_id IS NULL));
          END;
        ''');

        // 2. Create performance indexes
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_inventory_product ON inventory(product_id)',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_inventory_warehouse ON inventory(warehouse_id)',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_inventory_variant ON inventory(variant_id)',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_lots_product_warehouse ON inventory_lots(product_id, warehouse_id)',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_lots_variant ON inventory_lots(variant_id)',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_lots_expiration ON inventory_lots(expiration_date)',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_movements_product ON inventory_movements(product_id)',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_movements_warehouse ON inventory_movements(warehouse_id)',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_movements_date ON inventory_movements(movement_date)',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_movements_reference ON inventory_movements(reference_type, reference_id)',
        );

        // 3. Create audit trigger for manual inventory adjustments
        await customStatement('''
          CREATE TRIGGER IF NOT EXISTS audit_inventory_manual_changes
          AFTER UPDATE OF quantity_on_hand, quantity_reserved ON inventory
          WHEN NEW.quantity_on_hand != OLD.quantity_on_hand 
            OR NEW.quantity_reserved != OLD.quantity_reserved
          BEGIN
            INSERT INTO inventory_movements (
              product_id, warehouse_id, variant_id, movement_type,
              quantity, quantity_before, quantity_after,
              reason, performed_by, movement_date
            )
            VALUES (
              NEW.product_id, NEW.warehouse_id, NEW.variant_id, 'adjustment',
              NEW.quantity_on_hand - OLD.quantity_on_hand,
              OLD.quantity_on_hand, NEW.quantity_on_hand,
              'Automatic audit log', 1, CURRENT_TIMESTAMP
            );
          END;
        ''');

        // 4. Create database views
        await customStatement('''
          CREATE VIEW IF NOT EXISTS product_stock_summary AS
          SELECT 
            p.id as product_id,
            p.code as product_code,
            p.name as product_name,
            i.warehouse_id,
            COALESCE(SUM(i.quantity_on_hand), 0) as total_stock,
            COALESCE(SUM(i.quantity_reserved), 0) as total_reserved,
            COALESCE(SUM(i.quantity_on_hand - i.quantity_reserved), 0) as available_stock
          FROM products p
          LEFT JOIN inventory i ON i.product_id = p.id
          WHERE p.is_active = 1
          GROUP BY p.id, p.code, p.name, i.warehouse_id
        ''');

        await customStatement('''
          CREATE VIEW IF NOT EXISTS low_stock_products AS
          SELECT 
            p.id as product_id,
            p.code as product_code,
            p.name as product_name,
            pv.id as variant_id,
            pv.variant_name,
            i.warehouse_id,
            i.quantity_on_hand as current_stock,
            pv.stock_min as min_stock,
            pv.stock_max as max_stock
          FROM products p
          INNER JOIN product_variants pv ON pv.product_id = p.id
          INNER JOIN inventory i ON i.product_id = p.id AND i.variant_id = pv.id
          WHERE p.is_active = 1
            AND pv.is_active = 1
            AND pv.stock_min IS NOT NULL
            AND i.quantity_on_hand <= pv.stock_min
          ORDER BY i.quantity_on_hand ASC
        ''');

        // 5. Recalculate existing inventory
        await customStatement('''
          UPDATE inventory
          SET quantity_on_hand = (
            SELECT COALESCE(SUM(quantity), 0)
            FROM inventory_lots
            WHERE inventory_lots.product_id = inventory.product_id
              AND inventory_lots.warehouse_id = inventory.warehouse_id
              AND (inventory_lots.variant_id = inventory.variant_id 
                   OR (inventory_lots.variant_id IS NULL AND inventory.variant_id IS NULL))
          ),
          updated_at = CURRENT_TIMESTAMP
        ''');
      }

      if (from < 43) {
        // Migration to 43: Fix DateTime corruption by Triggers
        // Replace CURRENT_TIMESTAMP (String) with CAST(strftime('%s', 'now') AS INTEGER)

        // 1. Drop old triggers
        await customStatement(
          'DROP TRIGGER IF EXISTS sync_inventory_after_lot_insert',
        );
        await customStatement(
          'DROP TRIGGER IF EXISTS sync_inventory_after_lot_update',
        );
        await customStatement(
          'DROP TRIGGER IF EXISTS sync_inventory_after_lot_delete',
        );
        await customStatement(
          'DROP TRIGGER IF EXISTS audit_inventory_manual_changes',
        );

        // 2. Re-create Triggers with Integer timestamp
        await customStatement('''
          CREATE TRIGGER IF NOT EXISTS sync_inventory_after_lot_insert
          AFTER INSERT ON inventory_lots
          BEGIN
            INSERT INTO inventory (product_id, warehouse_id, variant_id, quantity_on_hand, quantity_reserved, updated_at)
            VALUES (NEW.product_id, NEW.warehouse_id, NEW.variant_id, NEW.quantity, 0, CAST(strftime('%s', 'now') AS INTEGER))
            ON CONFLICT (product_id, warehouse_id, variant_id) DO UPDATE
            SET quantity_on_hand = quantity_on_hand + NEW.quantity,
                updated_at = CAST(strftime('%s', 'now') AS INTEGER);
          END;
        ''');

        await customStatement('''
          CREATE TRIGGER IF NOT EXISTS sync_inventory_after_lot_update
          AFTER UPDATE ON inventory_lots
          BEGIN
            UPDATE inventory
            SET quantity_on_hand = quantity_on_hand + (NEW.quantity - OLD.quantity),
                updated_at = CAST(strftime('%s', 'now') AS INTEGER)
            WHERE product_id = NEW.product_id
              AND warehouse_id = NEW.warehouse_id
              AND (variant_id = NEW.variant_id OR (variant_id IS NULL AND NEW.variant_id IS NULL));
          END;
        ''');

        await customStatement('''
          CREATE TRIGGER IF NOT EXISTS sync_inventory_after_lot_delete
          AFTER DELETE ON inventory_lots
          BEGIN
            UPDATE inventory
            SET quantity_on_hand = quantity_on_hand - OLD.quantity,
                updated_at = CAST(strftime('%s', 'now') AS INTEGER)
            WHERE product_id = OLD.product_id
              AND warehouse_id = OLD.warehouse_id
              AND (variant_id = OLD.variant_id OR (variant_id IS NULL AND OLD.variant_id IS NULL));
          END;
        ''');

        await customStatement('''
          CREATE TRIGGER IF NOT EXISTS audit_inventory_manual_changes
          AFTER UPDATE OF quantity_on_hand, quantity_reserved ON inventory
          WHEN NEW.quantity_on_hand != OLD.quantity_on_hand 
            OR NEW.quantity_reserved != OLD.quantity_reserved
          BEGIN
            INSERT INTO inventory_movements (
              product_id, warehouse_id, variant_id, movement_type,
              quantity, quantity_before, quantity_after,
              reason, performed_by, movement_date
            )
            VALUES (
              NEW.product_id, NEW.warehouse_id, NEW.variant_id, 'adjustment',
              NEW.quantity_on_hand - OLD.quantity_on_hand,
              OLD.quantity_on_hand, NEW.quantity_on_hand,
              'Automatic audit log', 1, CAST(strftime('%s', 'now') AS INTEGER)
            );
          END;
        ''');

        // 3. Fix Existing Data
        // Convert any Text strings in updated_at, createdAt, movementDate to integers
        // Note: 'now' in strftime might not be appropriate for historical data,
        // but converting the EXISTING text string to seconds is what we need.
        // strftime('%s', column) attempts to parse the column string.

        await customStatement(
          "UPDATE inventory SET updated_at = CAST(strftime('%s', updated_at) AS INTEGER) WHERE typeof(updated_at) = 'text'",
        );

        await customStatement(
          "UPDATE inventory_movements SET movement_date = CAST(strftime('%s', movement_date) AS INTEGER) WHERE typeof(movement_date) = 'text'",
        );
      }

      if (from < 44) {
        // Migration to 44: Create sale_sequences table for atomic sale number generation
        await m.createTable(saleSequences);

        // Initialize sequence with current max sale number
        await customStatement('''
          INSERT INTO sale_sequences (id, last_number, updated_at)
          SELECT 1, 
                 COALESCE(MAX(CAST(SUBSTR(sale_number, INSTR(sale_number, '-') + 1) AS INTEGER)), 0),
                 CAST(strftime('%s', 'now') AS INTEGER)
          FROM sales
          WHERE sale_number LIKE 'SALE-%'
        ''');

        // If no sales exist, insert default
        await customStatement('''
          INSERT OR IGNORE INTO sale_sequences (id, last_number, updated_at)
          VALUES (1, 0, CAST(strftime('%s', 'now') AS INTEGER))
        ''');
      }

      if (from < 45) {
        // Migration to 45: Create inventory_audits and inventory_audit_items tables
        await m.createTable(inventoryAudits);
        await m.createTable(inventoryAuditItems);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');

      // Double-check sanitization on every open (harmless if data is clean)
      await customStatement(
        "UPDATE inventory SET updated_at = CAST(strftime('%s', updated_at) AS INTEGER) WHERE typeof(updated_at) = 'text'",
      );
      await customStatement(
        "UPDATE inventory_movements SET movement_date = CAST(strftime('%s', movement_date) AS INTEGER) WHERE typeof(movement_date) = 'text'",
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
