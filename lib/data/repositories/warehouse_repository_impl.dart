import 'package:posventa/data/datasources/database_helper.dart';
import 'package:posventa/data/models/warehouse_model.dart';
import 'package:posventa/domain/entities/warehouse.dart';
import 'package:posventa/domain/repositories/warehouse_repository.dart';

class WarehouseRepositoryImpl implements WarehouseRepository {
  final DatabaseHelper _databaseHelper;

  WarehouseRepositoryImpl(this._databaseHelper);

  @override
  Future<List<Warehouse>> getAllWarehouses() async {
    final db = await _databaseHelper.database;
    final maps = await db.query(DatabaseHelper.tableWarehouses);
    return maps.map((map) => WarehouseModel.fromMap(map)).toList();
  }

  @override
  Future<int> createWarehouse(Warehouse warehouse) async {
    final db = await _databaseHelper.database;
    final warehouseModel = WarehouseModel(
      name: warehouse.name,
      code: warehouse.code,
      address: warehouse.address,
      phone: warehouse.phone,
      isMain: warehouse.isMain,
      isActive: warehouse.isActive,
    );
    return await db.insert(
      DatabaseHelper.tableWarehouses,
      warehouseModel.toMap(),
    );
  }

  @override
  Future<void> updateWarehouse(Warehouse warehouse) async {
    final db = await _databaseHelper.database;
    final warehouseModel = WarehouseModel(
      id: warehouse.id,
      name: warehouse.name,
      code: warehouse.code,
      address: warehouse.address,
      phone: warehouse.phone,
      isMain: warehouse.isMain,
      isActive: warehouse.isActive,
    );
    await db.update(
      DatabaseHelper.tableWarehouses,
      warehouseModel.toMap(),
      where: 'id = ?',
      whereArgs: [warehouse.id],
    );
  }

  @override
  Future<void> deleteWarehouse(int id) async {
    final db = await _databaseHelper.database;
    await db.delete(
      DatabaseHelper.tableWarehouses,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
