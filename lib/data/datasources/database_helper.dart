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
  static const _databaseVersion = 8; // Incremented version

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
