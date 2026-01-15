import 'package:posventa/domain/entities/customer.dart';
import 'package:posventa/domain/repositories/customer_repository.dart';

class UpdateCustomerUseCase {
  final CustomerRepository _repository;

  UpdateCustomerUseCase(this._repository);

  Future<int> call(Customer customer, {required int userId}) async {
    return await _repository.updateCustomer(customer, userId: userId);
  }
}
