

import 'package:posventa/domain/entities/warehouse.dart';
import 'package:posventa/domain/repositories/warehouse_repository.dart';

class CreateWarehouse {
  final WarehouseRepository repository;

  CreateWarehouse(this.repository);

  Future<void> call(Warehouse warehouse) {
    return repository.createWarehouse(warehouse);
  }
}
