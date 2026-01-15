import 'package:posventa/domain/entities/customer.dart';
import 'package:posventa/domain/repositories/customer_repository.dart';

class CreateCustomerUseCase {
  final CustomerRepository _repository;

  CreateCustomerUseCase(this._repository);

  Future<int> call(Customer customer, {required int userId}) async {
    return await _repository.createCustomer(customer, userId: userId);
  }
}
