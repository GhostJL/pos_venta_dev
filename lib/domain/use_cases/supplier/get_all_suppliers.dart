import 'package:posventa/domain/entities/supplier.dart';
import 'package:posventa/domain/repositories/supplier_repository.dart';

class GetAllSuppliers {
  final SupplierRepository repository;

  GetAllSuppliers(this.repository);

  Future<List<Supplier>> call() async {
    return await repository.getAllSuppliers();
  }
}
