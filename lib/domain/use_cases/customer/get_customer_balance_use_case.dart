import 'package:posventa/domain/repositories/customer_repository.dart';

class GetCustomerBalanceUseCase {
  final CustomerRepository _repository;

  GetCustomerBalanceUseCase(this._repository);

  Future<double> call(int customerId) {
    return _repository.getCustomerBalance(customerId);
  }
}
