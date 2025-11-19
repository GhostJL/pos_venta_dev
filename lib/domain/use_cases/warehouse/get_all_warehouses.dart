import 'package:posventa/domain/entities/warehouse.dart';
import 'package:posventa/domain/repositories/warehouse_repository.dart';

class GetAllWarehouses {
  final WarehouseRepository repository;

  GetAllWarehouses(this.repository);

  Future<List<Warehouse>> call() {
    return repository.getAllWarehouses();
  }
}
