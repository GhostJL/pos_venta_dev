
import 'dart:convert';
import 'package:crypto/crypto.dart';
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
      version: 1,
      onCreate: _createDb,
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
  }

  Future<bool> onboardingCompleted() async {
    final db = await database;
    final result = await db.query('app_meta', where: 'key = ?', whereArgs: ['onboarding_completed']);
    return result.isNotEmpty && result.first['value'] == '1';
  }

  Future<void> setupInitialData(OnboardingState state) async {
    final db = await database;

    await db.transaction((txn) async {
      // 1. Insert Admin User
      var adminMap = state.adminUser!.toMap();
      adminMap['password_hash'] = _hashData(state.adminPassword!);
      await txn.insert('users', adminMap);

      // 2. Insert Cashier Users
      for (final cashier in state.cashiers) {
        final cashierMap = cashier.toMap();
        final rawPassword = cashier.passwordHash ?? '';
        if (rawPassword.isEmpty) {
          throw Exception('Onboarding error: Cashier password for \${cashier.username} is empty.');
        }
        cashierMap['password_hash'] = _hashData(rawPassword);
        await txn.insert('users', cashierMap);
      }

      // 3. Mark Onboarding as Completed
      await txn.insert('app_meta', {'key': 'onboarding_completed', 'value': '1'});

      // 4. Save the hashed App Access Key
      if (state.accessKey != null && state.accessKey!.isNotEmpty) {
        await txn.insert('app_meta', {
          'key': 'app_access_key_hash', // Renamed key
          'value': _hashData(state.accessKey!) // Using accessKey
        });
      } else {
        throw Exception('Onboarding error: App Access Key is missing.');
      }
    });
  }

  Future<void> resetDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app.db');
    await deleteDatabase(path);
    _database = null;
  }
}
