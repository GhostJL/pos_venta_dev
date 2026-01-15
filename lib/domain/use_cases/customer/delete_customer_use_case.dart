import 'package:posventa/domain/repositories/customer_repository.dart';

class DeleteCustomerUseCase {
  final CustomerRepository _repository;

  DeleteCustomerUseCase(this._repository);

  Future<int> call(int id, {required int userId}) async {
    return await _repository.deleteCustomer(id, userId: userId);
  }
}
