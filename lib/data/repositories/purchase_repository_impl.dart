import 'package:posventa/data/datasources/database_helper.dart';
import 'package:posventa/data/models/purchase_item_model.dart';
import 'package:posventa/data/models/purchase_model.dart';
import 'package:posventa/domain/entities/purchase.dart';
import 'package:posventa/domain/entities/purchase_item.dart';
import 'package:posventa/domain/repositories/purchase_repository.dart';

class PurchaseRepositoryImpl implements PurchaseRepository {
  final DatabaseHelper _databaseHelper;

  PurchaseRepositoryImpl(this._databaseHelper);

  @override
  Future<List<Purchase>> getPurchases() async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery('''
      SELECT p.*, s.name as supplier_name
      FROM ${DatabaseHelper.tablePurchases} p
      LEFT JOIN ${DatabaseHelper.tableSuppliers} s ON p.supplier_id = s.id
      ORDER BY p.created_at DESC
    ''');

    final List<Purchase> purchases = [];
    for (final row in result) {
      final purchaseModel = PurchaseModel.fromJson(row);
      final itemsResult = await db.query(
        DatabaseHelper.tablePurchaseItems,
        where: 'purchase_id = ?',
        whereArgs: [purchaseModel.id],
      );
      final items = itemsResult
          .map((i) => PurchaseItemModel.fromJson(i))
          .toList();
      purchases.add(purchaseModel.copyWith(items: items));
    }

    return purchases;
  }

  @override
  Future<Purchase?> getPurchaseById(int id) async {
    final db = await _databaseHelper.database;

    // Get purchase details
    final purchaseResult = await db.rawQuery(
      '''
      SELECT p.*, s.name as supplier_name
      FROM ${DatabaseHelper.tablePurchases} p
      LEFT JOIN ${DatabaseHelper.tableSuppliers} s ON p.supplier_id = s.id
      WHERE p.id = ?
    ''',
      [id],
    );

    if (purchaseResult.isEmpty) return null;

    final purchaseData = purchaseResult.first;

    // Get purchase items
    final itemsResult = await db.rawQuery(
      '''
      SELECT pi.*, pr.name as product_name
      FROM ${DatabaseHelper.tablePurchaseItems} pi
      LEFT JOIN ${DatabaseHelper.tableProducts} pr ON pi.product_id = pr.id
      WHERE pi.purchase_id = ?
    ''',
      [id],
    );

    final List<PurchaseItem> items = itemsResult
        .map((json) => PurchaseItemModel.fromJson(json))
        .toList();
    return PurchaseModel.fromJson(purchaseData).copyWith(items: items);
  }

  @override
  Future<int> createPurchase(Purchase purchase) async {
    final db = await _databaseHelper.database;
    return await db.transaction((txn) async {
      final purchaseModel = PurchaseModel.fromEntity(purchase);
      final purchaseId = await txn.insert(
        DatabaseHelper.tablePurchases,
        purchaseModel.toMap()..remove('id'),
      );

      for (final item in purchase.items) {
        final itemModel = PurchaseItemModel.fromEntity(item);
        await txn.insert(
          DatabaseHelper.tablePurchaseItems,
          itemModel.toMap()
            ..remove('id')
            ..['purchase_id'] = purchaseId,
        );
      }
      return purchaseId;
    });
  }

  @override
  Future<void> updatePurchase(Purchase purchase) async {
    final db = await _databaseHelper.database;
    await db.transaction((txn) async {
      final purchaseModel = PurchaseModel.fromEntity(purchase);
      await txn.update(
        DatabaseHelper.tablePurchases,
        purchaseModel.toMap(),
        where: 'id = ?',
        whereArgs: [purchase.id],
      );

      await txn.delete(
        DatabaseHelper.tablePurchaseItems,
        where: 'purchase_id = ?',
        whereArgs: [purchase.id],
      );

      for (final item in purchase.items) {
        final itemModel = PurchaseItemModel.fromEntity(item);
        await txn.insert(
          DatabaseHelper.tablePurchaseItems,
          itemModel.toMap()
            ..remove('id')
            ..['purchase_id'] = purchase.id,
        );
      }
    });
  }

  @override
  Future<void> deletePurchase(int id) async {
    final db = await _databaseHelper.database;
    await db.delete(
      DatabaseHelper.tablePurchases,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
