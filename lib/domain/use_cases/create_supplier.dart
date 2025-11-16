import 'package:myapp/domain/entities/supplier.dart';
import 'package:myapp/domain/repositories/supplier_repository.dart';

class CreateSupplier {
  final SupplierRepository repository;

  CreateSupplier(this.repository);

  Future<Supplier> call(Supplier supplier) async {
    // Aquí se podrían añadir validaciones de negocio antes de crear
    return await repository.createSupplier(supplier);
  }
}
