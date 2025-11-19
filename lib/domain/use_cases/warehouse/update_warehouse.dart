import 'package:posventa/domain/entities/warehouse.dart';
import 'package:posventa/domain/repositories/warehouse_repository.dart';

class UpdateWarehouse {
  final WarehouseRepository repository;

  UpdateWarehouse(this.repository);

  Future<void> call(Warehouse warehouse) {
    return repository.updateWarehouse(warehouse);
  }
}
