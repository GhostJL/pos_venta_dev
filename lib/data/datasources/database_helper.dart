import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'database_constants.dart';
import 'database_migrations.dart';
import 'database_schema.dart';

class DatabaseHelper {
  // Singleton pattern
  static final DatabaseHelper _instance = DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = _instance;
  factory DatabaseHelper() => _instance;
  DatabaseHelper._privateConstructor();

  // Database configuration
  static const _databaseName = "pos.db";
  static const _databaseVersion = 30;

  // Table names - Exposed from DatabaseConstants for backward compatibility
  static const tableUsers = DatabaseConstants.tableUsers;
  static const tableAppMeta = DatabaseConstants.tableAppMeta;
  static const tableTransactions = DatabaseConstants.tableTransactions;
  static const tableDepartments = DatabaseConstants.tableDepartments;
  static const tableCategories = DatabaseConstants.tableCategories;
  static const tableBrands = DatabaseConstants.tableBrands;
  static const tableSuppliers = DatabaseConstants.tableSuppliers;
  static const tableWarehouses = DatabaseConstants.tableWarehouses;
  static const tableTaxRates = DatabaseConstants.tableTaxRates;
  static const tableProducts = DatabaseConstants.tableProducts;
  static const tableProductTaxes = DatabaseConstants.tableProductTaxes;
  static const tableInventory = DatabaseConstants.tableInventory;
  static const tableInventoryMovements =
      DatabaseConstants.tableInventoryMovements;
  static const tableCustomers = DatabaseConstants.tableCustomers;
  static const tableSales = DatabaseConstants.tableSales;
  static const tableSaleItems = DatabaseConstants.tableSaleItems;
  static const tableSaleItemTaxes = DatabaseConstants.tableSaleItemTaxes;
  static const tableSalePayments = DatabaseConstants.tableSalePayments;
  static const tablePurchases = DatabaseConstants.tablePurchases;
  static const tablePurchaseItems = DatabaseConstants.tablePurchaseItems;
  static const tableCashSessions = DatabaseConstants.tableCashSessions;
  static const tableCashMovements = DatabaseConstants.tableCashMovements;
  static const tableAuditLogs = DatabaseConstants.tableAuditLogs;
  static const tablePermissions = DatabaseConstants.tablePermissions;
  static const tableUserPermissions = DatabaseConstants.tableUserPermissions;
  static const tableSaleReturns = DatabaseConstants.tableSaleReturns;
  static const tableSaleReturnItems = DatabaseConstants.tableSaleReturnItems;
  static const tableProductVariants = DatabaseConstants.tableProductVariants;
  static const tableUnitsOfMeasure = DatabaseConstants.tableUnitsOfMeasure;
  static const tableInventoryLots = DatabaseConstants.tableInventoryLots;
  static const tableSaleItemLots = DatabaseConstants.tableSaleItemLots;

  static Database? _database;

  // Stream controller for table updates
  final _tableUpdateController = StreamController<String>.broadcast();
  Stream<String> get tableUpdateStream => _tableUpdateController.stream;

  void notifyTableChanged(String tableName) {
    _tableUpdateController.add(tableName);
  }

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

  Future<void> _onCreate(Database db, int version) async {
    await DatabaseSchema.createTables(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    await DatabaseMigrations.processMigrations(db, oldVersion, newVersion);
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
