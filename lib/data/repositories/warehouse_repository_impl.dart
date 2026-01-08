import 'package:drift/drift.dart';
import 'package:posventa/data/datasources/local/database/app_database.dart'
    as drift_db;
import 'package:posventa/data/models/warehouse_model.dart';
import 'package:posventa/domain/entities/warehouse.dart';
import 'package:posventa/domain/repositories/warehouse_repository.dart';

class WarehouseRepositoryImpl implements WarehouseRepository {
  final drift_db.AppDatabase db;

  WarehouseRepositoryImpl(this.db);

  @override
  Future<List<Warehouse>> getAllWarehouses() async {
    final rows = await db.select(db.warehouses).get();
    return rows
        .map(
          (row) => WarehouseModel(
            id: row.id,
            name: row.name,
            code: row.code,
            address: row.address,
            phone: row.phone,
            isMain: row.isMain,
            isActive: row.isActive,
          ),
        )
        .toList();
  }

  @override
  Future<int> createWarehouse(Warehouse warehouse) async {
    return await db
        .into(db.warehouses)
        .insert(
          drift_db.WarehousesCompanion.insert(
            name: warehouse.name,
            code: warehouse.code,
            address: Value(warehouse.address),
            phone: Value(warehouse.phone),
            isMain: Value(warehouse.isMain),
            isActive: Value(warehouse.isActive),
          ),
        );
  }

  @override
  Future<void> updateWarehouse(Warehouse warehouse) async {
    await (db.update(
      db.warehouses,
    )..where((t) => t.id.equals(warehouse.id!))).write(
      drift_db.WarehousesCompanion(
        name: Value(warehouse.name),
        code: Value(warehouse.code),
        address: Value(warehouse.address),
        phone: Value(warehouse.phone),
        isMain: Value(warehouse.isMain),
        isActive: Value(warehouse.isActive),
      ),
    );
  }

  @override
  Future<void> deleteWarehouse(int id) async {
    await (db.delete(db.warehouses)..where((t) => t.id.equals(id))).go();
  }
}
