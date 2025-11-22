import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart';
import 'package:posventa/presentation/providers/onboarding_state.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  // Singleton pattern
  static final DatabaseHelper _instance = DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = _instance;
  factory DatabaseHelper() => _instance;
  DatabaseHelper._privateConstructor();

  // Database configuration
  static const _databaseName = "pos.db";
  static const _databaseVersion =
      14; // Incremented for purchase partial reception

  // Table names
  static const tableUsers = 'users';
  static const tableAppMeta = 'app_meta';
  static const tableTransactions = 'transactions';
  static const tableDepartments = 'departments';
  static const tableCategories = 'categories';
  static const tableBrands = 'brands';
  static const tableSuppliers = 'suppliers';
  static const tableWarehouses = 'warehouses';
  static const tableTaxRates = 'tax_rates';
  static const tableProducts = 'products'; // New table
  static const tableProductTaxes = 'product_taxes'; // New table
  static const tableInventory = 'inventory'; // New table
  static const tableInventoryMovements = 'inventory_movements'; // Kardex table
  static const tableCustomers = 'customers';
  static const tableSales = 'sales';
  static const tableSaleItems = 'sale_items';
  static const tableSaleItemTaxes = 'sale_item_taxes';
  static const tableSalePayments = 'sale_payments';
  static const tablePurchases = 'purchases';
  static const tablePurchaseItems = 'purchase_items';
  static const tableCashSessions = 'cash_sessions';
  static const tableCashMovements = 'cash_movements';
  static const tableAuditLogs = 'audit_logs';
  static const tablePermissions = 'permissions';
  static const tableUserPermissions = 'user_permissions';

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  String _hashData(String data) {
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> _onCreate(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE $tableUsers (
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

    // App metadata table
    await db.execute('''
      CREATE TABLE $tableAppMeta (
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');

    // Transactions table
    await db.execute('''
      CREATE TABLE $tableTransactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        description TEXT,
        date TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES $tableUsers(id) ON DELETE SET NULL
      )
    ''');

    // Departments table
    await db.execute('''
      CREATE TABLE $tableDepartments (
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

    // Categories table
    await db.execute('''
      CREATE TABLE $tableCategories (
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
        FOREIGN KEY (department_id) REFERENCES $tableDepartments(id) ON DELETE RESTRICT,
        FOREIGN KEY (parent_category_id) REFERENCES $tableCategories(id) ON DELETE SET NULL
      )
    ''');

    // Brands table
    await db.execute('''
      CREATE TABLE $tableBrands (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        code TEXT NOT NULL UNIQUE,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
        updated_at TEXT NOT NULL DEFAULT (datetime('now', 'localtime'))
      )
    ''');

    // Suppliers table
    await db.execute('''
      CREATE TABLE $tableSuppliers (
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

    // Warehouses table
    await _createWarehousesTable(db);
    // TaxRates table
    await _createTaxRatesTable(db);
    // Products table
    await _createProductsTable(db);
    // ProductTaxes table
    await _createProductTaxesTable(db);
    // Inventory table
    await _createInventoryTable(db);
    // InventoryMovements table (Kardex)
    await _createInventoryMovementsTable(db);
    // New modules tables
    await _createCustomersTable(db);
    await _createSalesTable(db);
    await _createSaleItemsTable(db);
    await _createSaleItemTaxesTable(db);
    await _createSalePaymentsTable(db);
    await _createPurchasesTable(db);
    await _createPurchaseItemsTable(db);
    await _createCashSessionsTable(db);
    await _createCashMovementsTable(db);
    await _createAuditLogsTable(db);
    // Permissions tables
    await _createPermissionsTable(db);
    await _createUserPermissionsTable(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 4) {
      await _createWarehousesTable(db);
    }
    if (oldVersion < 6) {
      await _createTaxRatesTable(db);
    }
    if (oldVersion < 7) {
      await _createProductsTable(db);
      await _createProductTaxesTable(db);
    }
    if (oldVersion < 8) {
      await _createInventoryTable(db);
    }
    if (oldVersion < 9) {
      await _createInventoryMovementsTable(db);
    }
    if (oldVersion < 10) {
      await _createCustomersTable(db);
      await _createSalesTable(db);
      await _createSaleItemsTable(db);
      await _createSaleItemTaxesTable(db);
      await _createSalePaymentsTable(db);
      await _createPurchasesTable(db);
      await _createPurchaseItemsTable(db);
      await _createCashSessionsTable(db);
      await _createCashMovementsTable(db);
      await _createAuditLogsTable(db);
    }
    if (oldVersion < 11) {
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_products_search 
        ON $tableProducts(name, code, barcode)
      ''');
    }
    if (oldVersion < 12) {
      await _createPermissionsTable(db);
      await _createUserPermissionsTable(db);
    }
    if (oldVersion < 13) {
      // Insert new permissions for Catalog and Customer management
      final newPermissions = [
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

      for (final perm in newPermissions) {
        await db.insert(
          tablePermissions,
          perm,
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
    }
    if (oldVersion < 14) {
      await db.execute('''
        ALTER TABLE $tablePurchaseItems 
        ADD COLUMN quantity_received REAL NOT NULL DEFAULT 0
      ''');
    }
  }

  Future<void> _createWarehousesTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableWarehouses (
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

  Future<void> _createTaxRatesTable(Database db) async {
    await db.execute('''
    CREATE TABLE IF NOT EXISTS $tableTaxRates (
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
      await db.insert(tableTaxRates, {
        ...tax,
        'is_active': 1,
        'created_at': DateTime.now().toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }

  Future<void> _createProductsTable(Database db) async {
    await db.execute('''
      CREATE TABLE $tableProducts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        code TEXT NOT NULL UNIQUE,
        barcode TEXT UNIQUE,
        name TEXT NOT NULL,
        description TEXT,
        department_id INTEGER NOT NULL,
        category_id INTEGER NOT NULL,
        brand_id INTEGER,
        supplier_id INTEGER,
        unit_of_measure TEXT NOT NULL DEFAULT 'pieza',
        is_sold_by_weight INTEGER NOT NULL DEFAULT 0,
        cost_price_cents INTEGER NOT NULL DEFAULT 0,
        sale_price_cents INTEGER NOT NULL,
        wholesale_price_cents INTEGER,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
        updated_at TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
        FOREIGN KEY (department_id) REFERENCES $tableDepartments(id) ON DELETE RESTRICT,
        FOREIGN KEY (category_id) REFERENCES $tableCategories(id) ON DELETE RESTRICT,
        FOREIGN KEY (brand_id) REFERENCES $tableBrands(id) ON DELETE SET NULL,
        FOREIGN KEY (supplier_id) REFERENCES $tableSuppliers(id) ON DELETE SET NULL
      )
    ''');
  }

  Future<void> _createProductTaxesTable(Database db) async {
    await db.execute('''
      CREATE TABLE $tableProductTaxes (
        product_id INTEGER NOT NULL,
        tax_rate_id INTEGER NOT NULL,
        apply_order INTEGER NOT NULL DEFAULT 1,
        PRIMARY KEY (product_id, tax_rate_id),
        FOREIGN KEY (product_id) REFERENCES $tableProducts(id) ON DELETE CASCADE,
        FOREIGN KEY (tax_rate_id) REFERENCES $tableTaxRates(id) ON DELETE RESTRICT
      )
    ''');
  }

  Future<void> _createInventoryTable(Database db) async {
    await db.execute('''
      CREATE TABLE $tableInventory (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER NOT NULL,
        warehouse_id INTEGER NOT NULL,
        quantity_on_hand REAL NOT NULL DEFAULT 0,
        quantity_reserved REAL NOT NULL DEFAULT 0,
        min_stock INTEGER,
        max_stock INTEGER,
        lot_number TEXT,
        expiration_date TEXT,
        updated_at TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
        UNIQUE (product_id, warehouse_id, lot_number),
        FOREIGN KEY (product_id) REFERENCES $tableProducts(id) ON DELETE CASCADE,
        FOREIGN KEY (warehouse_id) REFERENCES $tableWarehouses(id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _createInventoryMovementsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableInventoryMovements (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER NOT NULL,
        warehouse_id INTEGER NOT NULL,
        movement_type TEXT NOT NULL,
        quantity REAL NOT NULL,
        quantity_before REAL NOT NULL,
        quantity_after REAL NOT NULL,
        reference_type TEXT,
        reference_id INTEGER,
        lot_number TEXT,
        reason TEXT,
        performed_by INTEGER NOT NULL,
        movement_date TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
        FOREIGN KEY (product_id) REFERENCES $tableProducts(id) ON DELETE RESTRICT,
        FOREIGN KEY (warehouse_id) REFERENCES $tableWarehouses(id) ON DELETE RESTRICT,
        FOREIGN KEY (performed_by) REFERENCES $tableUsers(id) ON DELETE RESTRICT
      )
    ''');

    // Create indexes for better query performance
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_inventory_movements_product 
      ON $tableInventoryMovements(product_id)
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_inventory_movements_warehouse 
      ON $tableInventoryMovements(warehouse_id)
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_inventory_movements_type 
      ON $tableInventoryMovements(movement_type)
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_inventory_movements_date 
      ON $tableInventoryMovements(movement_date)
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_inventory_movements_reference 
      ON $tableInventoryMovements(reference_type, reference_id)
    ''');
  }

  Future<void> _createCustomersTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableCustomers (
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
    // Indexes
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_customers_code ON $tableCustomers(code)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_customers_phone ON $tableCustomers(phone)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_customers_email ON $tableCustomers(email)',
    );
  }

  Future<void> _createSalesTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableSales (
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
        FOREIGN KEY (warehouse_id) REFERENCES $tableWarehouses(id) ON DELETE RESTRICT,
        FOREIGN KEY (customer_id) REFERENCES $tableCustomers(id) ON DELETE SET NULL,
        FOREIGN KEY (cashier_id) REFERENCES $tableUsers(id) ON DELETE RESTRICT,
        FOREIGN KEY (cancelled_by) REFERENCES $tableUsers(id) ON DELETE SET NULL
      )
    ''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_sales_number ON $tableSales(sale_number)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_sales_warehouse ON $tableSales(warehouse_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_sales_customer ON $tableSales(customer_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_sales_cashier ON $tableSales(cashier_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_sales_status ON $tableSales(status)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_sales_date ON $tableSales(sale_date)',
    );
  }

  Future<void> _createSaleItemsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableSaleItems (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sale_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        quantity REAL NOT NULL,
        unit_of_measure TEXT NOT NULL,
        unit_price_cents INTEGER NOT NULL,
        discount_cents INTEGER NOT NULL DEFAULT 0,
        subtotal_cents INTEGER NOT NULL,
        tax_cents INTEGER NOT NULL DEFAULT 0,
        total_cents INTEGER NOT NULL,
        cost_price_cents INTEGER NOT NULL,
        lot_number TEXT,
        created_at TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
        FOREIGN KEY (sale_id) REFERENCES $tableSales(id) ON DELETE CASCADE,
        FOREIGN KEY (product_id) REFERENCES $tableProducts(id) ON DELETE RESTRICT
      )
    ''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_sale_items_sale ON $tableSaleItems(sale_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_sale_items_product ON $tableSaleItems(product_id)',
    );
  }

  Future<void> _createSaleItemTaxesTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableSaleItemTaxes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sale_item_id INTEGER NOT NULL,
        tax_rate_id INTEGER NOT NULL,
        tax_name TEXT NOT NULL,
        tax_rate REAL NOT NULL,
        tax_amount_cents INTEGER NOT NULL,
        FOREIGN KEY (sale_item_id) REFERENCES $tableSaleItems(id) ON DELETE CASCADE,
        FOREIGN KEY (tax_rate_id) REFERENCES $tableTaxRates(id) ON DELETE RESTRICT
      )
    ''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_sale_item_taxes_item ON $tableSaleItemTaxes(sale_item_id)',
    );
  }

  Future<void> _createSalePaymentsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableSalePayments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sale_id INTEGER NOT NULL,
        payment_method TEXT NOT NULL,
        amount_cents INTEGER NOT NULL,
        reference_number TEXT,
        payment_date TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
        received_by INTEGER NOT NULL,
        FOREIGN KEY (sale_id) REFERENCES $tableSales(id) ON DELETE CASCADE,
        FOREIGN KEY (received_by) REFERENCES $tableUsers(id) ON DELETE RESTRICT
      )
    ''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_sale_payments_sale ON $tableSalePayments(sale_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_sale_payments_method ON $tableSalePayments(payment_method)',
    );
  }

  Future<void> _createPurchasesTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tablePurchases (
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
        created_at TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
        FOREIGN KEY (supplier_id) REFERENCES $tableSuppliers(id) ON DELETE RESTRICT,
        FOREIGN KEY (warehouse_id) REFERENCES $tableWarehouses(id) ON DELETE RESTRICT,
        FOREIGN KEY (requested_by) REFERENCES $tableUsers(id) ON DELETE RESTRICT,
        FOREIGN KEY (received_by) REFERENCES $tableUsers(id) ON DELETE SET NULL
      )
    ''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_purchases_number ON $tablePurchases(purchase_number)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_purchases_supplier ON $tablePurchases(supplier_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_purchases_warehouse ON $tablePurchases(warehouse_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_purchases_status ON $tablePurchases(status)',
    );
  }

  Future<void> _createPurchaseItemsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tablePurchaseItems (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        purchase_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        quantity REAL NOT NULL,
        unit_of_measure TEXT NOT NULL,
        unit_cost_cents INTEGER NOT NULL,
        subtotal_cents INTEGER NOT NULL,
        tax_cents INTEGER NOT NULL DEFAULT 0,
        total_cents INTEGER NOT NULL,
        lot_number TEXT,
        expiration_date TEXT,
        created_at TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
        FOREIGN KEY (purchase_id) REFERENCES $tablePurchases(id) ON DELETE CASCADE,
        FOREIGN KEY (product_id) REFERENCES $tableProducts(id) ON DELETE RESTRICT
      )
    ''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_purchase_items_purchase ON $tablePurchaseItems(purchase_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_purchase_items_product ON $tablePurchaseItems(product_id)',
    );
  }

  Future<void> _createCashSessionsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableCashSessions (
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
        FOREIGN KEY (warehouse_id) REFERENCES $tableWarehouses(id) ON DELETE RESTRICT,
        FOREIGN KEY (user_id) REFERENCES $tableUsers(id) ON DELETE RESTRICT
      )
    ''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_cash_sessions_warehouse ON $tableCashSessions(warehouse_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_cash_sessions_user ON $tableCashSessions(user_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_cash_sessions_status ON $tableCashSessions(status)',
    );
  }

  Future<void> _createCashMovementsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableCashMovements (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cash_session_id INTEGER NOT NULL,
        movement_type TEXT NOT NULL,
        amount_cents INTEGER NOT NULL,
        reason TEXT NOT NULL,
        description TEXT,
        performed_by INTEGER NOT NULL,
        movement_date TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
        FOREIGN KEY (cash_session_id) REFERENCES $tableCashSessions(id) ON DELETE CASCADE,
        FOREIGN KEY (performed_by) REFERENCES $tableUsers(id) ON DELETE RESTRICT
      )
    ''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_cash_movements_session ON $tableCashMovements(cash_session_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_cash_movements_type ON $tableCashMovements(movement_type)',
    );
  }

  Future<void> _createAuditLogsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableAuditLogs (
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
        FOREIGN KEY (user_id) REFERENCES $tableUsers(id) ON DELETE RESTRICT
      )
    ''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_audit_logs_table ON $tableAuditLogs(table_name, record_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_audit_logs_user ON $tableAuditLogs(user_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_audit_logs_action ON $tableAuditLogs(action)',
    );
  }

  Future<void> _createPermissionsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tablePermissions (
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
        tablePermissions,
        perm,
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  Future<void> _createUserPermissionsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableUserPermissions (
        user_id INTEGER NOT NULL,
        permission_id INTEGER NOT NULL,
        granted_at TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
        granted_by INTEGER,
        PRIMARY KEY (user_id, permission_id),
        FOREIGN KEY (user_id) REFERENCES $tableUsers(id) ON DELETE CASCADE,
        FOREIGN KEY (permission_id) REFERENCES $tablePermissions(id) ON DELETE CASCADE,
        FOREIGN KEY (granted_by) REFERENCES $tableUsers(id) ON DELETE SET NULL
      )
    ''');
  }

  // Onboarding methods
  Future<bool> onboardingCompleted() async {
    final db = await database;
    final result = await db.query(
      tableAppMeta,
      where: 'key = ?',
      whereArgs: ['onboarding_completed'],
    );
    return result.isNotEmpty && result.first['value'] == '1';
  }

  Future<void> setupInitialData(OnboardingState state) async {
    final db = await database;

    await db.transaction((txn) async {
      // 1. Insert Admin User
      var adminMap = state.adminUser!.toMap();
      adminMap['password_hash'] = _hashData(state.adminPassword!);
      await txn.insert(tableUsers, adminMap);

      // 2. Insert Cashier Users
      for (final cashier in state.cashiers) {
        final cashierMap = cashier.toMap();
        final rawPassword = cashier.passwordHash ?? '';
        if (rawPassword.isEmpty) {
          throw Exception(
            'Error de incorporación: la contraseña del cajero para ${cashier.username} está vacía.',
          );
        }
        cashierMap['password_hash'] = _hashData(rawPassword);
        await txn.insert(tableUsers, cashierMap);
      }

      // 3. Mark Onboarding as Completed
      await txn.insert(tableAppMeta, {
        'key': 'onboarding_completed',
        'value': '1',
      });

      // 4. Save the hashed App Access Key
      if (state.accessKey != null && state.accessKey!.isNotEmpty) {
        await txn.insert(tableAppMeta, {
          'key': 'app_access_key_hash',
          'value': _hashData(state.accessKey!),
        });
      } else {
        throw Exception(
          'Error de incorporación: falta la clave de acceso a la aplicación.',
        );
      }
    });
  }

  // Database reset method
  Future<void> resetDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);
    await deleteDatabase(path);
    _database = null;
  }

  Future<int> insert(String table, Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert(table, row);
  }

  Future<List<Map<String, dynamic>>> queryAll(String table) async {
    final db = await database;
    return await db.query(table);
  }

  Future<Map<String, dynamic>?> queryById(String table, int id) async {
    final db = await database;
    final maps = await db.query(table, where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  Future<int> update(String table, Map<String, dynamic> row) async {
    final db = await database;
    int id = row['id'];
    return await db.update(table, row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> delete(String table, int id) async {
    final db = await database;
    return await db.delete(table, where: 'id = ?', whereArgs: [id]);
  }
}
