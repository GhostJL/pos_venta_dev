import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:myapp/domain/entities/user.dart';
import 'package:myapp/presentation/providers/onboarding_state.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app.db');

    return await openDatabase(
      path,
      version: 3, // Incremented version
      onCreate: _createDb,
      onUpgrade: _upgradeDb,
      onConfigure: _onConfigure,
    );
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
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

    await db.execute('''
      CREATE TABLE app_meta (
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userId INTEGER,
          amount REAL NOT NULL,
          type TEXT NOT NULL,
          description TEXT,
          date TEXT NOT NULL,
          FOREIGN KEY (userId) REFERENCES users(id) ON DELETE SET NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE departments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        code TEXT NOT NULL UNIQUE,
        description TEXT,
        display_order INTEGER NOT NULL DEFAULT 0,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await _createCategoriesTable(db);
    await _createBrandsTable(db);
  }

  Future<void> _upgradeDb(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createCategoriesTable(db);
    }
    if (oldVersion < 3) {
      await _createBrandsTable(db);
    }
  }

  Future<void> _createCategoriesTable(Database db) async {
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        code TEXT NOT NULL UNIQUE,
        department_id INTEGER NOT NULL,
        parent_category_id INTEGER,
        description TEXT,
        display_order INTEGER NOT NULL DEFAULT 0,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (department_id) REFERENCES departments(id) ON DELETE RESTRICT,
        FOREIGN KEY (parent_category_id) REFERENCES categories(id) ON DELETE SET NULL
      )
    ''');
  }

    Future<void> _createBrandsTable(Database db) async {
    await db.execute('''
      CREATE TABLE brands (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          code TEXT NOT NULL UNIQUE,
          is_active INTEGER NOT NULL DEFAULT 1,
          created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
          updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
    ''');
  }

  Future<bool> onboardingCompleted() async {
    final db = await database;
    final result = await db.query(
      'app_meta',
      where: 'key = ?',
      whereArgs: ['onboarding_completed'],
    );
    return result.isNotEmpty && result.first['value'] == '1';
  }

  Future<void> setupInitialData(OnboardingState state) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    String hashPassword(String password) {
      final bytes = utf8.encode(password);
      final digest = sha256.convert(bytes);
      return digest.toString();
    }

    await db.transaction((txn) async {
      // 1. Insert Admin User
      if (state.adminUser != null && state.adminPassword != null) {
        final admin = state.adminUser!;
        final hashedPassword = hashPassword(state.adminPassword!);
        await txn.insert('users', {
          'username': admin.username,
          'password_hash': hashedPassword,
          'first_name': admin.firstName,
          'last_name': admin.lastName,
          'email': admin.email,
          'role': UserRole.admin.name,
          'is_active': 1,
          'onboarding_completed': 1,
          'created_at': now,
          'updated_at': now,
        });
      }

      // 2. Insert Cashier Users
      if (state.accessKey != null) {
        final cashierPasswordHash = hashPassword(state.accessKey!);
        for (final cashier in state.cashiers) {
          await txn.insert('users', {
            'username': cashier.username,
            'password_hash': cashierPasswordHash,
            'first_name': cashier.firstName,
            'last_name': cashier.lastName,
            'email': cashier.email,
            'role': UserRole.cashier.name,
            'is_active': 1,
            'onboarding_completed': 1,
            'created_at': now,
            'updated_at': now,
          });
        }
      }

      // 3. Set Access Key
      if (state.accessKey != null) {
        await txn.insert(
          'app_meta',
          {'key': 'access_key', 'value': state.accessKey!},
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      // 4. Mark onboarding as completed
      await txn.insert(
        'app_meta',
        {'key': 'onboarding_completed', 'value': '1'},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  Future<void> resetDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app.db');
    await deleteDatabase(path);
    _database = null;
  }
}
