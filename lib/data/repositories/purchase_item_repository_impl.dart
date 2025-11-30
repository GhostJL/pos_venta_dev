import 'package:posventa/data/datasources/database_helper.dart';
import 'package:posventa/data/models/purchase_item_model.dart';
import 'package:posventa/domain/entities/purchase_item.dart';
import 'package:posventa/domain/repositories/purchase_item_repository.dart';

/// Implementation of PurchaseItemRepository
/// Handles all database operations for purchase items
class PurchaseItemRepositoryImpl implements PurchaseItemRepository {
  final DatabaseHelper _databaseHelper;

  PurchaseItemRepositoryImpl(this._databaseHelper);

  @override
  Future<List<PurchaseItem>> getPurchaseItems() async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery('''
      SELECT pi.*, 
             pr.name || COALESCE(' (' || pv.description || ')', '') as product_name,
             p.purchase_number,
             p.purchase_date,
             s.name as supplier_name
      FROM ${DatabaseHelper.tablePurchaseItems} pi
      LEFT JOIN ${DatabaseHelper.tableProducts} pr ON pi.product_id = pr.id
      LEFT JOIN ${DatabaseHelper.tableProductVariants} pv ON pi.variant_id = pv.id
      LEFT JOIN ${DatabaseHelper.tablePurchases} p ON pi.purchase_id = p.id
      LEFT JOIN ${DatabaseHelper.tableSuppliers} s ON p.supplier_id = s.id
      ORDER BY pi.created_at DESC
    ''');

    return result.map((json) => PurchaseItemModel.fromJson(json)).toList();
  }

  @override
  Future<List<PurchaseItem>> getPurchaseItemsByPurchaseId(
    int purchaseId,
  ) async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery(
      '''
      SELECT pi.*, 
             pr.name || COALESCE(' (' || pv.description || ')', '') as product_name,
             p.purchase_number,
             p.purchase_date,
             s.name as supplier_name
      FROM ${DatabaseHelper.tablePurchaseItems} pi
      LEFT JOIN ${DatabaseHelper.tableProducts} pr ON pi.product_id = pr.id
      LEFT JOIN ${DatabaseHelper.tableProductVariants} pv ON pi.variant_id = pv.id
      LEFT JOIN ${DatabaseHelper.tablePurchases} p ON pi.purchase_id = p.id
      LEFT JOIN ${DatabaseHelper.tableSuppliers} s ON p.supplier_id = s.id
      WHERE pi.purchase_id = ?
      ORDER BY pi.created_at DESC
    ''',
      [purchaseId],
    );

    return result.map((json) => PurchaseItemModel.fromJson(json)).toList();
  }

  @override
  Future<PurchaseItem?> getPurchaseItemById(int id) async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery(
      '''
      SELECT pi.*, 
             pr.name || COALESCE(' (' || pv.description || ')', '') as product_name,
             pr.code as product_code,
             pr.barcode as product_barcode,
             p.purchase_number,
             p.purchase_date,
             s.name as supplier_name,
             w.name as warehouse_name
      FROM ${DatabaseHelper.tablePurchaseItems} pi
      LEFT JOIN ${DatabaseHelper.tableProducts} pr ON pi.product_id = pr.id
      LEFT JOIN ${DatabaseHelper.tableProductVariants} pv ON pi.variant_id = pv.id
      LEFT JOIN ${DatabaseHelper.tablePurchases} p ON pi.purchase_id = p.id
      LEFT JOIN ${DatabaseHelper.tableSuppliers} s ON p.supplier_id = s.id
      LEFT JOIN ${DatabaseHelper.tableWarehouses} w ON p.warehouse_id = w.id
      WHERE pi.id = ?
    ''',
      [id],
    );

    if (result.isEmpty) return null;
    return PurchaseItemModel.fromJson(result.first);
  }

  @override
  Future<List<PurchaseItem>> getPurchaseItemsByProductId(int productId) async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery(
      '''
      SELECT pi.*, 
             pr.name || COALESCE(' (' || pv.description || ')', '') as product_name,
             p.purchase_number,
             p.purchase_date,
             s.name as supplier_name
      FROM ${DatabaseHelper.tablePurchaseItems} pi
      LEFT JOIN ${DatabaseHelper.tableProducts} pr ON pi.product_id = pr.id
      LEFT JOIN ${DatabaseHelper.tableProductVariants} pv ON pi.variant_id = pv.id
      LEFT JOIN ${DatabaseHelper.tablePurchases} p ON pi.purchase_id = p.id
      LEFT JOIN ${DatabaseHelper.tableSuppliers} s ON p.supplier_id = s.id
      WHERE pi.product_id = ?
      ORDER BY pi.created_at DESC
    ''',
      [productId],
    );

    return result.map((json) => PurchaseItemModel.fromJson(json)).toList();
  }

  @override
  Future<int> createPurchaseItem(PurchaseItem item) async {
    final db = await _databaseHelper.database;
    final model = PurchaseItemModel.fromEntity(item);
    return await db.insert(
      DatabaseHelper.tablePurchaseItems,
      model.toMap()..remove('id'),
    );
  }

  @override
  Future<void> updatePurchaseItem(PurchaseItem item) async {
    final db = await _databaseHelper.database;
    final model = PurchaseItemModel.fromEntity(item);
    await db.update(
      DatabaseHelper.tablePurchaseItems,
      model.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  @override
  Future<void> deletePurchaseItem(int id) async {
    final db = await _databaseHelper.database;
    await db.delete(
      DatabaseHelper.tablePurchaseItems,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<List<PurchaseItem>> getPurchaseItemsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery(
      '''
      SELECT pi.*, 
             pr.name || COALESCE(' (' || pv.description || ')', '') as product_name,
             p.purchase_number,
             p.purchase_date,
             s.name as supplier_name
      FROM ${DatabaseHelper.tablePurchaseItems} pi
      LEFT JOIN ${DatabaseHelper.tableProducts} pr ON pi.product_id = pr.id
      LEFT JOIN ${DatabaseHelper.tableProductVariants} pv ON pi.variant_id = pv.id
      LEFT JOIN ${DatabaseHelper.tablePurchases} p ON pi.purchase_id = p.id
      LEFT JOIN ${DatabaseHelper.tableSuppliers} s ON p.supplier_id = s.id
      WHERE pi.created_at BETWEEN ? AND ?
      ORDER BY pi.created_at DESC
    ''',
      [startDate.toIso8601String(), endDate.toIso8601String()],
    );

    return result.map((json) => PurchaseItemModel.fromJson(json)).toList();
  }

  @override
  Future<List<PurchaseItem>> getRecentPurchaseItems({int limit = 50}) async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery(
      '''
      SELECT pi.*, 
             pr.name || COALESCE(' (' || pv.description || ')', '') as product_name,
             p.purchase_number,
             p.purchase_date,
             s.name as supplier_name
      FROM ${DatabaseHelper.tablePurchaseItems} pi
      LEFT JOIN ${DatabaseHelper.tableProducts} pr ON pi.product_id = pr.id
      LEFT JOIN ${DatabaseHelper.tableProductVariants} pv ON pi.variant_id = pv.id
      LEFT JOIN ${DatabaseHelper.tablePurchases} p ON pi.purchase_id = p.id
      LEFT JOIN ${DatabaseHelper.tableSuppliers} s ON p.supplier_id = s.id
      ORDER BY pi.created_at DESC
      LIMIT ?
    ''',
      [limit],
    );

    return result.map((json) => PurchaseItemModel.fromJson(json)).toList();
  }
}
