import 'package:myapp/domain/entities/supplier.dart';
import 'package:myapp/domain/repositories/supplier_repository.dart';

class GetAllSuppliers {
  final SupplierRepository repository;

  GetAllSuppliers(this.repository);

  Future<List<Supplier>> call() async {
    return await repository.getAllSuppliers();
  }
}
