import 'package:posventa/domain/entities/customer.dart';
import 'package:posventa/domain/repositories/customer_repository.dart';

class SearchCustomersUseCase {
  final CustomerRepository _repository;

  SearchCustomersUseCase(this._repository);

  Future<List<Customer>> call(String query) async {
    return await _repository.searchCustomers(query);
  }
}
