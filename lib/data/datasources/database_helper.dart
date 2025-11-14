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
    final db = await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
    return db;
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createTables(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
      CREATE TABLE cash_sessions (
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
      ''');

      await db.execute('''
      CREATE TABLE cash_movements (
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
      ''');
    }
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        email TEXT NOT NULL UNIQUE,
        password_hash TEXT NOT NULL,
        first_name TEXT NOT NULL,
        last_name TEXT NOT NULL,
        role TEXT NOT NULL CHECK(role IN ('admin', 'manager', 'cashier', 'viewer')) DEFAULT 'cashier',
        phone TEXT,
        is_active INTEGER NOT NULL DEFAULT 1,
        last_login_at TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE permissions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        code TEXT NOT NULL UNIQUE,
        description TEXT,
        module TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE user_permissions (
        user_id INTEGER NOT NULL,
        permission_id INTEGER NOT NULL,
        granted_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        granted_by INTEGER,
        PRIMARY KEY (user_id, permission_id),
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (permission_id) REFERENCES permissions(id) ON DELETE CASCADE,
        FOREIGN KEY (granted_by) REFERENCES users(id) ON DELETE SET NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE cash_sessions (
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
      ''');

    await db.execute('''
      CREATE TABLE cash_movements (
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
      ''');
  }
}
