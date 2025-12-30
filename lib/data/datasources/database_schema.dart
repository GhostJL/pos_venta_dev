import 'package:sqflite/sqflite.dart';
import 'database_constants.dart';

class DatabaseSchema {
  // =================================================================
  // 1. MÉTODO DE INICIALIZACIÓN PRINCIPAL
  // =================================================================
  static Future<void> createTables(Database db) async {
    // 1. Tablas de Meta-información y Usuarios
    await _createSystemAndUserTables(db);

    // 2. Tablas de Catálogo (Productos, Categorías, Impuestos)
    await _createCatalogTables(db);

    // 3. Tablas de Inventario y Lotes
    await _createInventoryTables(db);

    // 3.1 Tabla de Notificaciones
    await _createNotificationsTable(db);

    // 4. Tablas de Clientes y Proveedores
    await _createPartyTables(db);

    // 5. Tablas de Ventas y Pagos
    await _createSalesTables(db);

    // 6. Tablas de Compras y Suministros
    await _createPurchaseTables(db);

    // 7. Tablas de Caja y Operaciones Financieras
    await _createCashManagementTables(db);

    // 8. Tablas de Seguridad y Auditoría
    await _createSecurityAndAuditTables(db);

    // 9. Tabla de Información de la Tienda
    await _createStoreTable(db);
  }

  // =================================================================
  // 2. GRUPO: SISTEMA Y USUARIOS
  // =================================================================
  static Future<void> _createSystemAndUserTables(Database db) async {
    await _createUsersTable(db);
    await _createAppMetaTable(db);
    await _createTransactionsTable(db);
  }

  static Future<void> _createUsersTable(Database db) async {
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableUsers} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        first_name TEXT,
        last_name TEXT,
        email TEXT,
        role TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        onboarding_completed INTEGER NOT NULL DEFAULT 0,
        last_login_at TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }

  static Future<void> _createAppMetaTable(Database db) async {
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableAppMeta} (
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');
  }

  static Future<void> _createTransactionsTable(Database db) async {
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableTransactions} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        description TEXT,
        date TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES ${DatabaseConstants.tableUsers}(id) ON DELETE SET NULL
      )
    ''');
  }

  // =================================================================
  // 3. GRUPO: CATÁLOGO Y CONFIGURACIÓN DE PRODUCTOS
  // =================================================================
  static Future<void> _createCatalogTables(Database db) async {
    await _createDepartmentsTable(db);
    await _createCategoriesTable(db);
    await _createBrandsTable(db);
    await _createUnitsOfMeasureTable(
      db,
    ); // Incluye inserción de datos por defecto
    await _createTaxRatesTable(db); // Incluye inserción de datos por defecto
    await _createProductsTable(db);
    await _createProductVariantsTable(db);
    await _createProductTaxesTable(db);
  }

  static Future<void> _createDepartmentsTable(Database db) async {
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableDepartments} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        code TEXT NOT NULL UNIQUE,
        description TEXT,
        display_order INTEGER NOT NULL DEFAULT 0,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
        updated_at TEXT NOT NULL DEFAULT (datetime('now', 'localtime'))
      )
    ''');
  }

  static Future<void> _createCategoriesTable(Database db) async {
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableCategories} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        code TEXT NOT NULL UNIQUE,
        department_id INTEGER NOT NULL,
        parent_category_id INTEGER,
        description TEXT,
        display_order INTEGER NOT NULL DEFAULT 0,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
        updated_at TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
        FOREIGN KEY (department_id) REFERENCES ${DatabaseConstants.tableDepartments}(id) ON DELETE RESTRICT,
        FOREIGN KEY (parent_category_id) REFERENCES ${DatabaseConstants.tableCategories}(id) ON DELETE SET NULL
      )
    ''');
  }

  static Future<void> _createBrandsTable(Database db) async {
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableBrands} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        code TEXT NOT NULL UNIQUE,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
        updated_at TEXT NOT NULL DEFAULT (datetime('now', 'localtime'))
      )
    ''');
  }

  static Future<void> _createUnitsOfMeasureTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DatabaseConstants.tableUnitsOfMeasure} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        code TEXT NOT NULL UNIQUE,
        name TEXT NOT NULL
      )
    ''');

    // Insert default units
    final defaultUnits = [
      {'code': 'pz', 'name': 'Pieza'},
      {'code': 'kg', 'name': 'Kilogramo'},
      {'code': 'g', 'name': 'Gramo'},
      {'code': 'lt', 'name': 'Litro'},
      {'code': 'ml', 'name': 'Mililitro'},
      {'code': 'm', 'name': 'Metro'},
      {'code': 'cm', 'name': 'Centímetro'},
      {'code': 'caja', 'name': 'Caja'},
      {'code': 'paq', 'name': 'Paquete'},
      {'code': 'srv', 'name': 'Servicio'},
    ];

    for (final unit in defaultUnits) {
      await db.insert(DatabaseConstants.tableUnitsOfMeasure, unit);
    }
  }

  static Future<void> _createTaxRatesTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DatabaseConstants.tableTaxRates} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        code TEXT NOT NULL UNIQUE,
        rate REAL NOT NULL,
        is_default INTEGER NOT NULL DEFAULT 0,
        is_active INTEGER NOT NULL DEFAULT 1,
        is_editable INTEGER NOT NULL DEFAULT 0,
        is_optional INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL DEFAULT (datetime('now', 'localtime'))
      )
    ''');

    final predefinedTaxes = [
      {
        'name': 'IVA 16%',
        'code': 'IVA_16',
        'rate': 0.16,
        'is_default': 1,
        'is_editable': 0,
        'is_optional': 0,
      },
      {
        'name': 'Exento',
        'code': 'EXENTO',
        'rate': 0.0,
        'is_default': 0,
        'is_editable': 0,
        'is_optional': 0,
      },
      {
        'name': 'IEPS 8%',
        'code': 'IEPS_8',
        'rate': 0.08,
        'is_default': 0,
        'is_editable': 0,
        'is_optional': 1,
      },
    ];

    for (final tax in predefinedTaxes) {
      await db.insert(
        DatabaseConstants.tableTaxRates,
        {
          ...tax,
          'is_active': 1,
          'created_at': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  static Future<void> _createProductsTable(Database db) async {
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableProducts} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        code TEXT NOT NULL UNIQUE,
        name TEXT NOT NULL,
        description TEXT,
        department_id INTEGER NOT NULL,
        category_id INTEGER NOT NULL,
        brand_id INTEGER,
        supplier_id INTEGER,
        is_sold_by_weight INTEGER NOT NULL DEFAULT 0 CHECK (is_sold_by_weight IN (0,1)),
        is_active INTEGER NOT NULL DEFAULT 1 CHECK (is_active IN (0,1)),
        has_expiration INTEGER NOT NULL DEFAULT 0 CHECK (has_expiration IN (0,1)),
        photo_url TEXT,
        created_at TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
        updated_at TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
        FOREIGN KEY (department_id) REFERENCES ${DatabaseConstants.tableDepartments}(id) ON DELETE RESTRICT,
        FOREIGN KEY (category_id) REFERENCES ${DatabaseConstants.tableCategories}(id) ON DELETE RESTRICT,
        FOREIGN KEY (brand_id) REFERENCES ${DatabaseConstants.tableBrands}(id) ON DELETE SET NULL,
        FOREIGN KEY (supplier_id) REFERENCES ${DatabaseConstants.tableSuppliers}(id) ON DELETE SET NULL
      )
    ''');

    // Índices
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_products_code ON ${DatabaseConstants.tableProducts}(code)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_products_department ON ${DatabaseConstants.tableProducts}(department_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_products_category ON ${DatabaseConstants.tableProducts}(category_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_products_search ON ${DatabaseConstants.tableProducts}(name, code)',
    );
  }

  static Future<void> _createProductVariantsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DatabaseConstants.tableProductVariants} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER NOT NULL,
        variant_name TEXT NOT NULL,
        barcode TEXT UNIQUE,
        quantity REAL NOT NULL DEFAULT 1,
        cost_price_cents INTEGER NOT NULL,
        sale_price_cents INTEGER NOT NULL,
        wholesale_price_cents INTEGER,
        is_active INTEGER NOT NULL DEFAULT 1 CHECK (is_active IN (0,1)),
        is_for_sale INTEGER NOT NULL DEFAULT 1 CHECK (is_for_sale IN (0,1)),
        type TEXT NOT NULL DEFAULT 'sales',
        linked_variant_id INTEGER,
        stock_min REAL,
        stock_max REAL,
        unit_id INTEGER,
        is_sold_by_weight INTEGER NOT NULL DEFAULT 0 CHECK (is_sold_by_weight IN (0,1)),
        conversion_factor REAL DEFAULT 1.0,
        photo_url TEXT,
        created_at TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
        updated_at TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
        FOREIGN KEY (product_id) REFERENCES ${DatabaseConstants.tableProducts}(id) ON DELETE CASCADE,
        FOREIGN KEY (linked_variant_id) REFERENCES ${DatabaseConstants.tableProductVariants}(id) ON DELETE SET NULL
      )
    ''');
    // Índices
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_product_variants_product ON ${DatabaseConstants.tableProductVariants}(product_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_product_variants_barcode ON ${DatabaseConstants.tableProductVariants}(barcode)',
    );
  }

  static Future<void> _createProductTaxesTable(Database db) async {
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableProductTaxes} (
        product_id INTEGER NOT NULL,
        tax_rate_id INTEGER NOT NULL,
        apply_order INTEGER NOT NULL DEFAULT 1,
        PRIMARY KEY (product_id, tax_rate_id),
        FOREIGN KEY (product_id) REFERENCES ${DatabaseConstants.tableProducts}(id) ON DELETE CASCADE,
        FOREIGN KEY (tax_rate_id) REFERENCES ${DatabaseConstants.tableTaxRates}(id) ON DELETE RESTRICT
      )
    ''');
  }

  // =================================================================
  // 4. GRUPO: INVENTARIO
  // =================================================================
  static Future<void> _createInventoryTables(Database db) async {
    await _createWarehousesTable(db);
    await _createInventoryTable(db);
    await _createInventoryLotsTable(db);
    await _createInventoryMovementsTable(db);
  }

  static Future<void> _createWarehousesTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DatabaseConstants.tableWarehouses} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        code TEXT NOT NULL UNIQUE,
        address TEXT,
        phone TEXT,
        is_main INTEGER NOT NULL DEFAULT 0,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL DEFAULT (datetime('now', 'localtime'))
      )
    ''');
  }

  static Future<void> _createInventoryTable(Database db) async {
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableInventory} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER NOT NULL,
        warehouse_id INTEGER NOT NULL,
        variant_id INTEGER,
        quantity_on_hand REAL NOT NULL DEFAULT 0,
        quantity_reserved REAL NOT NULL DEFAULT 0,
        min_stock INTEGER,
        max_stock INTEGER,
        updated_at TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
        UNIQUE (product_id, warehouse_id, variant_id),
        FOREIGN KEY (product_id) REFERENCES ${DatabaseConstants.tableProducts}(id) ON DELETE CASCADE,
        FOREIGN KEY (warehouse_id) REFERENCES ${DatabaseConstants.tableWarehouses}(id) ON DELETE CASCADE,
        FOREIGN KEY (variant_id) REFERENCES ${DatabaseConstants.tableProductVariants}(id) ON DELETE CASCADE
      )
    ''');
  }

  static Future<void> _createInventoryLotsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DatabaseConstants.tableInventoryLots} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER NOT NULL,
        variant_id INTEGER,
        warehouse_id INTEGER NOT NULL,
        lot_number TEXT NOT NULL,
        quantity REAL NOT NULL DEFAULT 0,
        unit_cost_cents INTEGER NOT NULL,
        total_cost_cents INTEGER NOT NULL,
        expiration_date TEXT,
        received_at TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
        FOREIGN KEY (product_id) REFERENCES ${DatabaseConstants.tableProducts}(id) ON DELETE CASCADE,
        FOREIGN KEY (variant_id) REFERENCES ${DatabaseConstants.tableProductVariants}(id) ON DELETE SET NULL,
        FOREIGN KEY (warehouse_id) REFERENCES ${DatabaseConstants.tableWarehouses}(id) ON DELETE CASCADE
      )
    ''');
    // Índices
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_inventory_lots_product ON ${DatabaseConstants.tableInventoryLots}(product_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_inventory_lots_warehouse ON ${DatabaseConstants.tableInventoryLots}(warehouse_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_inventory_lots_number ON ${DatabaseConstants.tableInventoryLots}(lot_number)',
    );
  }

  static Future<void> _createInventoryMovementsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DatabaseConstants.tableInventoryMovements} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER NOT NULL,
        warehouse_id INTEGER NOT NULL,
        movement_type TEXT NOT NULL,
        quantity REAL NOT NULL,
        quantity_before REAL NOT NULL,
        quantity_after REAL NOT NULL,
        reference_type TEXT,
        reference_id INTEGER,
        lot_id INTEGER,
        reason TEXT,
        performed_by INTEGER NOT NULL,
        movement_date TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
        FOREIGN KEY (product_id) REFERENCES ${DatabaseConstants.tableProducts}(id) ON DELETE RESTRICT,
        FOREIGN KEY (warehouse_id) REFERENCES ${DatabaseConstants.tableWarehouses}(id) ON DELETE RESTRICT,
        FOREIGN KEY (lot_id) REFERENCES ${DatabaseConstants.tableInventoryLots}(id) ON DELETE SET NULL,
        FOREIGN KEY (performed_by) REFERENCES ${DatabaseConstants.tableUsers}(id) ON DELETE RESTRICT
      )
    ''');
    // Índices
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_inventory_movements_product ON ${DatabaseConstants.tableInventoryMovements}(product_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_inventory_movements_warehouse ON ${DatabaseConstants.tableInventoryMovements}(warehouse_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_inventory_movements_type ON ${DatabaseConstants.tableInventoryMovements}(movement_type)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_inventory_movements_date ON ${DatabaseConstants.tableInventoryMovements}(movement_date)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_inventory_movements_reference ON ${DatabaseConstants.tableInventoryMovements}(reference_type, reference_id)',
    );
  }

  // =================================================================
  // 5. GRUPO: TERCEROS (CLIENTES Y PROVEEDORES)
  // =================================================================
  static Future<void> _createPartyTables(Database db) async {
    await _createCustomersTable(db);
    await _createSuppliersTable(db);
  }

  static Future<void> _createCustomersTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DatabaseConstants.tableCustomers} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        code TEXT NOT NULL UNIQUE,
        first_name TEXT NOT NULL,
        last_name TEXT NOT NULL,
        phone TEXT,
        email TEXT,
        address TEXT,
        tax_id TEXT,
        business_name TEXT,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
        updated_at TEXT NOT NULL DEFAULT (datetime('now', 'localtime'))
      )
    ''');
    // Índices
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_customers_code ON ${DatabaseConstants.tableCustomers}(code)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_customers_phone ON ${DatabaseConstants.tableCustomers}(phone)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_customers_email ON ${DatabaseConstants.tableCustomers}(email)',
    );
  }

  static Future<void> _createSuppliersTable(Database db) async {
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableSuppliers} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        code TEXT NOT NULL UNIQUE,
        contact_person TEXT,
        phone TEXT,
        email TEXT,
        address TEXT,
        tax_id TEXT,
        credit_days INTEGER DEFAULT 0,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
        updated_at TEXT NOT NULL DEFAULT (datetime('now', 'localtime'))
      )
    ''');
  }

  // =================================================================
  // 6. GRUPO: VENTAS Y DEVOLUCIONES (POS)
  // =================================================================
  static Future<void> _createSalesTables(Database db) async {
    await _createSalesTable(db);
    await _createSaleItemsTable(db);
    await _createSaleItemTaxesTable(db);
    await _createSalePaymentsTable(db);
    await _createSaleReturnsTable(db);
    await _createSaleReturnItemsTable(db);
    await _createSaleItemLotsTable(db);
  }

  static Future<void> _createSalesTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DatabaseConstants.tableSales} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sale_number TEXT NOT NULL UNIQUE,
        warehouse_id INTEGER NOT NULL,
        customer_id INTEGER,
        cashier_id INTEGER NOT NULL,
        subtotal_cents INTEGER NOT NULL,
        discount_cents INTEGER NOT NULL DEFAULT 0,
        tax_cents INTEGER NOT NULL DEFAULT 0,
        total_cents INTEGER NOT NULL,
        status TEXT NOT NULL DEFAULT 'completed',
        sale_date TEXT NOT NULL,
        created_at TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
        cancelled_by INTEGER,
        cancelled_at TEXT,
        cancellation_reason TEXT,
        FOREIGN KEY (warehouse_id) REFERENCES ${DatabaseConstants.tableWarehouses}(id) ON DELETE RESTRICT,
        FOREIGN KEY (customer_id) REFERENCES ${DatabaseConstants.tableCustomers}(id) ON DELETE SET NULL,
        FOREIGN KEY (cashier_id) REFERENCES ${DatabaseConstants.tableUsers}(id) ON DELETE RESTRICT,
        FOREIGN KEY (cancelled_by) REFERENCES ${DatabaseConstants.tableUsers}(id) ON DELETE SET NULL
      )
    ''');
    // Índices
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_sales_number ON ${DatabaseConstants.tableSales}(sale_number)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_sales_warehouse ON ${DatabaseConstants.tableSales}(warehouse_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_sales_customer ON ${DatabaseConstants.tableSales}(customer_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_sales_cashier ON ${DatabaseConstants.tableSales}(cashier_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_sales_status ON ${DatabaseConstants.tableSales}(status)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_sales_date ON ${DatabaseConstants.tableSales}(sale_date)',
    );
  }

  static Future<void> _createSaleItemsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DatabaseConstants.tableSaleItems} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sale_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        variant_id INTEGER,
        quantity REAL NOT NULL,
        unit_of_measure TEXT NOT NULL,
        unit_price_cents INTEGER NOT NULL,
        discount_cents INTEGER NOT NULL DEFAULT 0,
        subtotal_cents INTEGER NOT NULL,
        tax_cents INTEGER NOT NULL DEFAULT 0,
        total_cents INTEGER NOT NULL,
        cost_price_cents INTEGER NOT NULL,
        lot_id INTEGER,
        created_at TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
        FOREIGN KEY (sale_id) REFERENCES ${DatabaseConstants.tableSales}(id) ON DELETE CASCADE,
        FOREIGN KEY (product_id) REFERENCES ${DatabaseConstants.tableProducts}(id) ON DELETE RESTRICT,
        FOREIGN KEY (variant_id) REFERENCES ${DatabaseConstants.tableProductVariants}(id) ON DELETE SET NULL,
        FOREIGN KEY (lot_id) REFERENCES ${DatabaseConstants.tableInventoryLots}(id) ON DELETE SET NULL
      )
    ''');
    // Índices
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_sale_items_sale ON ${DatabaseConstants.tableSaleItems}(sale_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_sale_items_product ON ${DatabaseConstants.tableSaleItems}(product_id)',
    );
  }

  static Future<void> _createSaleItemTaxesTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DatabaseConstants.tableSaleItemTaxes} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sale_item_id INTEGER NOT NULL,
        tax_rate_id INTEGER NOT NULL,
        tax_name TEXT NOT NULL,
        tax_rate REAL NOT NULL,
        tax_amount_cents INTEGER NOT NULL,
        FOREIGN KEY (sale_item_id) REFERENCES ${DatabaseConstants.tableSaleItems}(id) ON DELETE CASCADE,
        FOREIGN KEY (tax_rate_id) REFERENCES ${DatabaseConstants.tableTaxRates}(id) ON DELETE RESTRICT
      )
    ''');
    // Índices
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_sale_item_taxes_item ON ${DatabaseConstants.tableSaleItemTaxes}(sale_item_id)',
    );
  }

  static Future<void> _createSalePaymentsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DatabaseConstants.tableSalePayments} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sale_id INTEGER NOT NULL,
        payment_method TEXT NOT NULL,
        amount_cents INTEGER NOT NULL,
        reference_number TEXT,
        payment_date TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
        received_by INTEGER NOT NULL,
        FOREIGN KEY (sale_id) REFERENCES ${DatabaseConstants.tableSales}(id) ON DELETE CASCADE,
        FOREIGN KEY (received_by) REFERENCES ${DatabaseConstants.tableUsers}(id) ON DELETE RESTRICT
      )
    ''');
    // Índices
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_sale_payments_sale ON ${DatabaseConstants.tableSalePayments}(sale_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_sale_payments_method ON ${DatabaseConstants.tableSalePayments}(payment_method)',
    );
  }

  static Future<void> _createSaleReturnsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DatabaseConstants.tableSaleReturns} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        return_number TEXT NOT NULL UNIQUE,
        sale_id INTEGER NOT NULL,
        warehouse_id INTEGER NOT NULL,
        customer_id INTEGER,
        processed_by INTEGER NOT NULL,
        subtotal_cents INTEGER NOT NULL,
        tax_cents INTEGER NOT NULL DEFAULT 0,
        total_cents INTEGER NOT NULL,
        refund_method TEXT NOT NULL,
        reason TEXT NOT NULL,
        notes TEXT,
        status TEXT NOT NULL DEFAULT 'completed',
        return_date TEXT NOT NULL,
        created_at TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
        FOREIGN KEY (sale_id) REFERENCES ${DatabaseConstants.tableSales}(id) ON DELETE RESTRICT,
        FOREIGN KEY (warehouse_id) REFERENCES ${DatabaseConstants.tableWarehouses}(id) ON DELETE RESTRICT,
        FOREIGN KEY (customer_id) REFERENCES ${DatabaseConstants.tableCustomers}(id) ON DELETE SET NULL,
        FOREIGN KEY (processed_by) REFERENCES ${DatabaseConstants.tableUsers}(id) ON DELETE RESTRICT
      )
    ''');
    // Índices
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_sale_returns_number ON ${DatabaseConstants.tableSaleReturns}(return_number)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_sale_returns_sale ON ${DatabaseConstants.tableSaleReturns}(sale_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_sale_returns_date ON ${DatabaseConstants.tableSaleReturns}(return_date)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_sale_returns_status ON ${DatabaseConstants.tableSaleReturns}(status)',
    );
  }

  static Future<void> _createSaleReturnItemsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DatabaseConstants.tableSaleReturnItems} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sale_return_id INTEGER NOT NULL,
        sale_item_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        quantity REAL NOT NULL,
        unit_price_cents INTEGER NOT NULL,
        subtotal_cents INTEGER NOT NULL,
        tax_cents INTEGER NOT NULL DEFAULT 0,
        total_cents INTEGER NOT NULL,
        reason TEXT,
        created_at TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
        FOREIGN KEY (sale_return_id) REFERENCES ${DatabaseConstants.tableSaleReturns}(id) ON DELETE CASCADE,
        FOREIGN KEY (sale_item_id) REFERENCES ${DatabaseConstants.tableSaleItems}(id) ON DELETE RESTRICT,
        FOREIGN KEY (product_id) REFERENCES ${DatabaseConstants.tableProducts}(id) ON DELETE RESTRICT
      )
    ''');
    // Índices
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_sale_return_items_return ON ${DatabaseConstants.tableSaleReturnItems}(sale_return_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_sale_return_items_sale_item ON ${DatabaseConstants.tableSaleReturnItems}(sale_item_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_sale_return_items_product ON ${DatabaseConstants.tableSaleReturnItems}(product_id)',
    );
  }

  static Future<void> _createSaleItemLotsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DatabaseConstants.tableSaleItemLots} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sale_item_id INTEGER NOT NULL,
        lot_id INTEGER NOT NULL,
        quantity_deducted REAL NOT NULL,
        created_at TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
        FOREIGN KEY (sale_item_id) REFERENCES ${DatabaseConstants.tableSaleItems}(id) ON DELETE CASCADE,
        FOREIGN KEY (lot_id) REFERENCES ${DatabaseConstants.tableInventoryLots}(id) ON DELETE RESTRICT
      )
    ''');
    // Índices
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_sale_item_lots_sale_item ON ${DatabaseConstants.tableSaleItemLots}(sale_item_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_sale_item_lots_lot ON ${DatabaseConstants.tableSaleItemLots}(lot_id)',
    );
  }

  // =================================================================
  // 7. GRUPO: COMPRAS Y ADQUISICIONES
  // =================================================================
  static Future<void> _createPurchaseTables(Database db) async {
    await _createPurchasesTable(db);
    await _createPurchaseItemsTable(db);
  }

  static Future<void> _createPurchasesTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DatabaseConstants.tablePurchases} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        purchase_number TEXT NOT NULL UNIQUE,
        supplier_id INTEGER NOT NULL,
        warehouse_id INTEGER NOT NULL,
        subtotal_cents INTEGER NOT NULL,
        tax_cents INTEGER NOT NULL DEFAULT 0,
        total_cents INTEGER NOT NULL,
        status TEXT NOT NULL DEFAULT 'pending',
        purchase_date TEXT NOT NULL,
        received_date TEXT,
        supplier_invoice_number TEXT,
        requested_by INTEGER NOT NULL,
        received_by INTEGER,
        cancelled_by INTEGER,
        created_at TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
        FOREIGN KEY (supplier_id) REFERENCES ${DatabaseConstants.tableSuppliers}(id) ON DELETE RESTRICT,
        FOREIGN KEY (warehouse_id) REFERENCES ${DatabaseConstants.tableWarehouses}(id) ON DELETE RESTRICT,
        FOREIGN KEY (requested_by) REFERENCES ${DatabaseConstants.tableUsers}(id) ON DELETE RESTRICT,
        FOREIGN KEY (received_by) REFERENCES ${DatabaseConstants.tableUsers}(id) ON DELETE SET NULL,
        FOREIGN KEY (cancelled_by) REFERENCES ${DatabaseConstants.tableUsers}(id) ON DELETE SET NULL
      )
    ''');
    // Índices
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_purchases_number ON ${DatabaseConstants.tablePurchases}(purchase_number)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_purchases_supplier ON ${DatabaseConstants.tablePurchases}(supplier_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_purchases_warehouse ON ${DatabaseConstants.tablePurchases}(warehouse_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_purchases_status ON ${DatabaseConstants.tablePurchases}(status)',
    );
  }

  static Future<void> _createPurchaseItemsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DatabaseConstants.tablePurchaseItems} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        purchase_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        variant_id INTEGER,
        quantity REAL NOT NULL,
        quantity_received REAL NOT NULL DEFAULT 0,
        unit_of_measure TEXT NOT NULL,
        unit_cost_cents INTEGER NOT NULL,
        subtotal_cents INTEGER NOT NULL,
        tax_cents INTEGER NOT NULL DEFAULT 0,
        total_cents INTEGER NOT NULL,
        lot_id INTEGER,
        expiration_date TEXT,
        created_at TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
        FOREIGN KEY (purchase_id) REFERENCES ${DatabaseConstants.tablePurchases}(id) ON DELETE CASCADE,
        FOREIGN KEY (product_id) REFERENCES ${DatabaseConstants.tableProducts}(id) ON DELETE RESTRICT,
        FOREIGN KEY (variant_id) REFERENCES ${DatabaseConstants.tableProductVariants}(id) ON DELETE SET NULL,
        FOREIGN KEY (lot_id) REFERENCES ${DatabaseConstants.tableInventoryLots}(id) ON DELETE SET NULL
      )
    ''');
    // Índices
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_purchase_items_purchase ON ${DatabaseConstants.tablePurchaseItems}(purchase_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_purchase_items_product ON ${DatabaseConstants.tablePurchaseItems}(product_id)',
    );
  }

  // =================================================================
  // 8. GRUPO: GESTIÓN DE CAJA Y MOVIMIENTOS
  // =================================================================
  static Future<void> _createCashManagementTables(Database db) async {
    await _createCashSessionsTable(db);
    await _createCashMovementsTable(db);
  }

  static Future<void> _createCashSessionsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DatabaseConstants.tableCashSessions} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        warehouse_id INTEGER NOT NULL,
        user_id INTEGER NOT NULL,
        opening_balance_cents INTEGER NOT NULL,
        closing_balance_cents INTEGER,
        expected_balance_cents INTEGER,
        difference_cents INTEGER,
        status TEXT NOT NULL DEFAULT 'open',
        opened_at TEXT NOT NULL,
        closed_at TEXT,
        notes TEXT,
        FOREIGN KEY (warehouse_id) REFERENCES ${DatabaseConstants.tableWarehouses}(id) ON DELETE RESTRICT,
        FOREIGN KEY (user_id) REFERENCES ${DatabaseConstants.tableUsers}(id) ON DELETE RESTRICT
      )
    ''');
    // Índices
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_cash_sessions_warehouse ON ${DatabaseConstants.tableCashSessions}(warehouse_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_cash_sessions_user ON ${DatabaseConstants.tableCashSessions}(user_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_cash_sessions_status ON ${DatabaseConstants.tableCashSessions}(status)',
    );
  }

  static Future<void> _createCashMovementsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DatabaseConstants.tableCashMovements} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cash_session_id INTEGER NOT NULL,
        movement_type TEXT NOT NULL,
        amount_cents INTEGER NOT NULL,
        reason TEXT NOT NULL,
        description TEXT,
        performed_by INTEGER NOT NULL,
        movement_date TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
        FOREIGN KEY (cash_session_id) REFERENCES ${DatabaseConstants.tableCashSessions}(id) ON DELETE CASCADE,
        FOREIGN KEY (performed_by) REFERENCES ${DatabaseConstants.tableUsers}(id) ON DELETE RESTRICT
      )
    ''');
    // Índices
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_cash_movements_session ON ${DatabaseConstants.tableCashMovements}(cash_session_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_cash_movements_type ON ${DatabaseConstants.tableCashMovements}(movement_type)',
    );
  }

  // =================================================================
  // 9. GRUPO: SEGURIDAD Y AUDITORÍA
  // =================================================================
  static Future<void> _createSecurityAndAuditTables(Database db) async {
    await _createPermissionsTable(db); // Incluye inserción de datos por defecto
    await _createUserPermissionsTable(db);
    await _createAuditLogsTable(db);
  }

  static Future<void> _createAuditLogsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DatabaseConstants.tableAuditLogs} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        table_name TEXT NOT NULL,
        record_id INTEGER,
        action TEXT NOT NULL,
        user_id INTEGER NOT NULL,
        username TEXT NOT NULL,
        old_values TEXT,
        new_values TEXT,
        ip_address TEXT,
        created_at TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
        FOREIGN KEY (user_id) REFERENCES ${DatabaseConstants.tableUsers}(id) ON DELETE RESTRICT
      )
    ''');
    // Índices
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_audit_logs_table ON ${DatabaseConstants.tableAuditLogs}(table_name, record_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_audit_logs_user ON ${DatabaseConstants.tableAuditLogs}(user_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_audit_logs_action ON ${DatabaseConstants.tableAuditLogs}(action)',
    );
  }

  static Future<void> _createPermissionsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DatabaseConstants.tablePermissions} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        code TEXT NOT NULL UNIQUE,
        description TEXT,
        module TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1
      )
    ''');

    // Insert default permissions
    final permissions = [
      // POS Module
      {
        'name': 'Acceso al POS',
        'code': 'POS_ACCESS',
        'module': 'POS',
        'description': 'Permite acceder a la pantalla de ventas',
      },
      {
        'name': 'Aplicar Descuentos',
        'code': 'POS_DISCOUNT',
        'module': 'POS',
        'description': 'Permite aplicar descuentos manuales',
      },
      {
        'name': 'Realizar Devoluciones',
        'code': 'POS_REFUND',
        'module': 'POS',
        'description': 'Permite procesar devoluciones',
      },
      {
        'name': 'Anular Items',
        'code': 'POS_VOID_ITEM',
        'module': 'POS',
        'description': 'Permite eliminar items del carrito',
      },
      // Cash Module
      {
        'name': 'Abrir Caja',
        'code': 'CASH_OPEN',
        'module': 'CASH',
        'description': 'Permite abrir turno de caja',
      },
      {
        'name': 'Cerrar Caja',
        'code': 'CASH_CLOSE',
        'module': 'CASH',
        'description': 'Permite cerrar turno de caja',
      },
      {
        'name': 'Movimientos de Caja',
        'code': 'CASH_MOVEMENT',
        'module': 'CASH',
        'description': 'Permite registrar ingresos/egresos',
      },
      // Inventory Module
      {
        'name': 'Ver Inventario',
        'code': 'INVENTORY_VIEW',
        'module': 'INVENTORY',
        'description': 'Permite ver existencias',
      },
      {
        'name': 'Ajustar Inventario',
        'code': 'INVENTORY_ADJUST',
        'module': 'INVENTORY',
        'description': 'Permite realizar ajustes de inventario',
      },
      // Reports Module
      {
        'name': 'Ver Reportes',
        'code': 'REPORTS_VIEW',
        'module': 'REPORTS',
        'description': 'Permite ver reportes de ventas',
      },
      {
        'name': 'Gestionar Catálogo',
        'code': 'CATALOG_MANAGE',
        'module': 'CATALOG',
        'description': 'Permite administrar productos, categorías, etc.',
      },
      {
        'name': 'Gestionar Clientes',
        'code': 'CUSTOMER_MANAGE',
        'module': 'CUSTOMERS',
        'description': 'Permite administrar clientes',
      },
    ];

    for (final perm in permissions) {
      await db.insert(
        DatabaseConstants.tablePermissions,
        perm,
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  static Future<void> _createUserPermissionsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DatabaseConstants.tableUserPermissions} (
        user_id INTEGER NOT NULL,
        permission_id INTEGER NOT NULL,
        granted_at TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
        granted_by INTEGER,
        PRIMARY KEY (user_id, permission_id),
        FOREIGN KEY (user_id) REFERENCES ${DatabaseConstants.tableUsers}(id) ON DELETE CASCADE,
        FOREIGN KEY (permission_id) REFERENCES ${DatabaseConstants.tablePermissions}(id) ON DELETE CASCADE,
        FOREIGN KEY (granted_by) REFERENCES ${DatabaseConstants.tableUsers}(id) ON DELETE SET NULL
      )
    ''');
  }

  static Future<void> _createNotificationsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DatabaseConstants.tableNotifications} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        body TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        is_read INTEGER NOT NULL DEFAULT 0,
        type TEXT NOT NULL,
        related_product_id INTEGER,
        related_variant_id INTEGER,
        FOREIGN KEY (related_product_id) REFERENCES ${DatabaseConstants.tableProducts}(id) ON DELETE CASCADE,
        FOREIGN KEY (related_variant_id) REFERENCES ${DatabaseConstants.tableProductVariants}(id) ON DELETE CASCADE
      )
    ''');
  }

  static Future<void> _createStoreTable(Database db) async {
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableStore} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        business_name TEXT,
        tax_id TEXT,
        address TEXT,
        phone TEXT,
        email TEXT,
        website TEXT,
        logo_path TEXT,
        receipt_footer TEXT,
        currency TEXT NOT NULL DEFAULT 'MXN',
        timezone TEXT NOT NULL DEFAULT 'America/Mexico_City',
        created_at TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
        updated_at TEXT NOT NULL DEFAULT (datetime('now', 'localtime'))
      )
    ''');

    // Insert default store if not exists
    await db.insert(DatabaseConstants.tableStore, {
      'name': 'Mi Tienda',
      'currency': 'MXN',
      'timezone': 'America/Mexico_City',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }
}
