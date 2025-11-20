import 'package:posventa/domain/entities/customer.dart';
import 'package:posventa/domain/repositories/customer_repository.dart';

class GetCustomersUseCase {
  final CustomerRepository _repository;

  GetCustomersUseCase(this._repository);

  Future<List<Customer>> call() async {
    return await _repository.getCustomers();
  }
}
