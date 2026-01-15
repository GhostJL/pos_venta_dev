import 'package:posventa/domain/entities/supplier.dart';
import 'package:posventa/domain/repositories/supplier_repository.dart';

class CreateSupplier {
  final SupplierRepository repository;

  CreateSupplier(this.repository);

  Future<Supplier> call(Supplier supplier, {required int userId}) async {
    // Aquí se podrían añadir validaciones de negocio antes de crear
    return await repository.createSupplier(supplier, userId: userId);
  }
}
