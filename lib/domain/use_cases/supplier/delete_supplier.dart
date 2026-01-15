import 'package:posventa/domain/repositories/supplier_repository.dart';

class DeleteSupplier {
  final SupplierRepository repository;

  DeleteSupplier(this.repository);

  Future<void> call(int supplierId, {required int userId}) async {
    return await repository.deleteSupplier(supplierId, userId: userId);
  }
}
