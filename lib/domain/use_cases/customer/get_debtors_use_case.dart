import 'package:posventa/domain/entities/customer.dart';
import 'package:posventa/domain/repositories/customer_repository.dart';

class GetDebtorsUseCase {
  final CustomerRepository _repository;

  GetDebtorsUseCase(this._repository);

  Future<List<Customer>> call() async {
    return await _repository.getDebtors();
  }
}
