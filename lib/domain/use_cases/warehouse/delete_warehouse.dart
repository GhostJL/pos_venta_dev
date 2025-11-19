import 'package:posventa/domain/repositories/warehouse_repository.dart';

class DeleteWarehouse {
  final WarehouseRepository repository;

  DeleteWarehouse(this.repository);

  Future<void> call(int id) {
    return repository.deleteWarehouse(id);
  }
}
