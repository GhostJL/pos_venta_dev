import 'package:myapp/domain/entities/supplier.dart';
import 'package:myapp/domain/repositories/supplier_repository.dart';

class UpdateSupplier {
  final SupplierRepository repository;

  UpdateSupplier(this.repository);

  Future<Supplier> call(Supplier supplier) async {
    // Validaciones antes de actualizar
    return await repository.updateSupplier(supplier);
  }
}
