import 'package:posventa/domain/entities/warehouse.dart';

abstract class WarehouseRepository {
  Future<List<Warehouse>> getAllWarehouses();
  Future<int> createWarehouse(Warehouse warehouse);
  Future<void> updateWarehouse(Warehouse warehouse);
  Future<void> deleteWarehouse(int id);
}
