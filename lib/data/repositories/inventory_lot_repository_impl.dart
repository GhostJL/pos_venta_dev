import 'package:intl/intl.dart';
import 'package:posventa/data/datasources/database_helper.dart';
import 'package:posventa/data/models/inventory_lot_model.dart';
import 'package:posventa/domain/entities/inventory_lot.dart';
import 'package:posventa/domain/repositories/inventory_lot_repository.dart';

class InventoryLotRepositoryImpl implements InventoryLotRepository {
  final DatabaseHelper _databaseHelper;

  InventoryLotRepositoryImpl(this._databaseHelper);

  @override
  Future<List<InventoryLot>> getLotsByProduct(
    int productId,
    int warehouseId,
  ) async {
    final db = await _databaseHelper.database;
    final result = await db.query(
      DatabaseHelper.tableInventoryLots,
      where: 'product_id = ? AND warehouse_id = ?',
      whereArgs: [productId, warehouseId],
      orderBy: 'received_at DESC',
    );

    return result.map((json) => InventoryLotModel.fromJson(json)).toList();
  }

  @override
  Future<List<InventoryLot>> getAvailableLots(
    int productId,
    int warehouseId,
  ) async {
    final db = await _databaseHelper.database;
    final result = await db.query(
      DatabaseHelper.tableInventoryLots,
      where: 'product_id = ? AND warehouse_id = ? AND quantity > 0',
      whereArgs: [productId, warehouseId],
      orderBy: 'received_at ASC', // FIFO: oldest first
    );

    return result.map((json) => InventoryLotModel.fromJson(json)).toList();
  }

  @override
  Future<InventoryLot?> getLotById(int id) async {
    final db = await _databaseHelper.database;
    final result = await db.query(
      DatabaseHelper.tableInventoryLots,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isEmpty) return null;
    return InventoryLotModel.fromJson(result.first);
  }

  @override
  Future<int> createLot(InventoryLot lot) async {
    final db = await _databaseHelper.database;
    final model = InventoryLotModel.fromEntity(lot);
    final lotId = await db.insert(
      DatabaseHelper.tableInventoryLots,
      model.toJson()..remove('id'),
    );
    return lotId;
  }

  @override
  Future<void> updateLotQuantity(int lotId, double newQuantity) async {
    final db = await _databaseHelper.database;
    await db.update(
      DatabaseHelper.tableInventoryLots,
      {'quantity': newQuantity},
      where: 'id = ?',
      whereArgs: [lotId],
    );
  }

  @override
  String generateLotNumber() {
    final now = DateTime.now();
    final dateFormat = DateFormat('yyyyMMdd');
    final timeFormat = DateFormat('HHmmss');

    // Format: LOT-YYYYMMDD-HHMMSS
    return 'LOT-${dateFormat.format(now)}-${timeFormat.format(now)}';
  }

  @override
  Future<List<InventoryLot>> getExpiringLots(
    int warehouseId,
    int withinDays,
  ) async {
    final db = await _databaseHelper.database;
    final expirationDate = DateTime.now().add(Duration(days: withinDays));

    final result = await db.query(
      DatabaseHelper.tableInventoryLots,
      where:
          'warehouse_id = ? AND expiration_date IS NOT NULL AND expiration_date <= ? AND quantity > 0',
      whereArgs: [warehouseId, expirationDate.toIso8601String()],
      orderBy: 'expiration_date ASC',
    );

    return result.map((json) => InventoryLotModel.fromJson(json)).toList();
  }

  @override
  Future<List<InventoryLot>> getLotsByWarehouse(int warehouseId) async {
    final db = await _databaseHelper.database;
    final result = await db.query(
      DatabaseHelper.tableInventoryLots,
      where: 'warehouse_id = ?',
      whereArgs: [warehouseId],
      orderBy: 'received_at DESC',
    );

    return result.map((json) => InventoryLotModel.fromJson(json)).toList();
  }
}
