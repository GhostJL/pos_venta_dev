import 'package:posventa/domain/entities/supplier.dart';
import 'package:posventa/domain/repositories/supplier_repository.dart';

class UpdateSupplier {
  final SupplierRepository repository;

  UpdateSupplier(this.repository);

  Future<Supplier> call(Supplier supplier, {required int userId}) async {
    // Validaciones antes de actualizar
    return await repository.updateSupplier(supplier, userId: userId);
  }
}
