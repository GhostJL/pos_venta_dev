import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:myapp/presentation/providers/onboarding_state.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  // Singleton pattern
  static final DatabaseHelper _instance = DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = _instance;
  factory DatabaseHelper() => _instance;
  DatabaseHelper._privateConstructor();

  // Database configuration
  static const _databaseName = "pos.db";
  static const _databaseVersion = 3;

  // Table names
  static const tableUsers = 'users';
  static const tableAppMeta = 'app_meta';
  static const tableTransactions = 'transactions';
  static const tableDepartments = 'departments';
  static const tableCategories = 'categories';
  static const tableBrands = 'brands';
  static const tableSuppliers = 'suppliers';

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
            'Onboarding error: Cashier password for ${cashier.username} is empty.',
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
        throw Exception('Onboarding error: App Access Key is missing.');
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
}