import 'package:myapp/domain/repositories/supplier_repository.dart';

class DeleteSupplier {
  final SupplierRepository repository;

  DeleteSupplier(this.repository);

  Future<void> call(int supplierId) async {
    return await repository.deleteSupplier(supplierId);
  }
}
