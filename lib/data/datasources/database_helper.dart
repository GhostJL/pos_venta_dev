import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:myapp/domain/entities/user.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app_database.db');
    return await openDatabase(
      path,
      version: 4, // Incremented version for the new table
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createTables(db);
    // No initial admin seeding on create, onboarding is required
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 4) {
      // For simplicity in this migration, we just ensure tables are created.
      // A more robust migration would alter existing tables carefully.
      await _createTables(db);
    }
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> _createTables(Database db) async {
    await db.execute("""
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        email TEXT NOT NULL UNIQUE,
        password_hash TEXT NOT NULL,
        first_name TEXT NOT NULL,
        last_name TEXT NOT NULL,
        role TEXT NOT NULL CHECK(role IN ('admin', 'manager', 'cashier', 'viewer')) DEFAULT 'cashier',
        phone TEXT,
        is_active INTEGER NOT NULL DEFAULT 1,
        onboarding_completed INTEGER NOT NULL DEFAULT 0,
        last_login_at TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    """);

    await db.execute("""
      CREATE TABLE IF NOT EXISTS app_settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    """);

    await db.execute("""
      CREATE TABLE IF NOT EXISTS permissions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        code TEXT NOT NULL UNIQUE,
        description TEXT,
        module TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1
      )
    """);

    await db.execute("""
      CREATE TABLE IF NOT EXISTS user_permissions (
        user_id INTEGER NOT NULL,
        permission_id INTEGER NOT NULL,
        granted_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        granted_by INTEGER,
        PRIMARY KEY (user_id, permission_id),
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (permission_id) REFERENCES permissions(id) ON DELETE CASCADE,
        FOREIGN KEY (granted_by) REFERENCES users(id) ON DELETE SET NULL
      )
    """);

    await db.execute("""
      CREATE TABLE IF NOT EXISTS cash_sessions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          warehouse_id INTEGER NOT NULL,
          user_id INTEGER NOT NULL,
          opening_balance_cents BIGINT NOT NULL,
          closing_balance_cents BIGINT,
          expected_balance_cents BIGINT,
          difference_cents BIGINT,
          status TEXT NOT NULL DEFAULT 'open',
          opened_at TEXT NOT NULL,
          closed_at TEXT,
          notes TEXT,
          FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE RESTRICT
      )
      """);

    await db.execute("""
      CREATE TABLE IF NOT EXISTS cash_movements (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          cash_session_id INTEGER NOT NULL,
          movement_type TEXT NOT NULL,
          amount_cents BIGINT NOT NULL,
          reason TEXT NOT NULL,
          description TEXT,
          performed_by INTEGER NOT NULL,
          movement_date TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (cash_session_id) REFERENCES cash_sessions(id) ON DELETE CASCADE,
          FOREIGN KEY (performed_by) REFERENCES users(id) ON DELETE RESTRICT
      )
      """);
  }

  Future<void> completeOnboardingTransaction({
    required User admin,
    required List<User> cashiers,
    required String pin,
    required String adminPassword,
  }) async {
    final db = await database;
    await db.transaction((txn) async {
      // 1. Insert Admin
      final adminToInsert = admin.toMap();
      adminToInsert['password_hash'] = _hashPassword(adminPassword);
      adminToInsert['onboarding_completed'] = 1;
      adminToInsert['role'] = 'admin';
      adminToInsert.remove('id'); // Let DB assign it

      final adminId = await txn.insert('users', adminToInsert);

      // 2. Insert Cashiers
      if (cashiers.isNotEmpty) {
        final batch = txn.batch();
        for (final cashier in cashiers) {
          final cashierToInsert = cashier.toMap();
          cashierToInsert.remove('id'); // Let DB assign it
          // For onboarding, cashiers are assigned a temporary password.
          // An admin should update this password for security and proper access
          // after the initial setup.
          cashierToInsert['password_hash'] = _hashPassword("temp-password"); 
          cashierToInsert['role'] = 'cashier';
          batch.insert('users', cashierToInsert);
        }
        await batch.commit(noResult: true);
      }

      // 3. Save Hashed PIN for Admin
      await txn.insert('app_settings', {
        'key': 'admin_pin_user_$adminId',
        'value': _hashPassword(pin),
      });
    });
  }

  Future<bool> onboardingCompleted() async {
    final db = await database;
    final result = await db.query('users', where: 'role = ? AND onboarding_completed = ?', whereArgs: ['admin', 1]);
    return result.isNotEmpty;
  }
}