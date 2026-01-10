import 'package:posventa/domain/repositories/customer_repository.dart';

class UpdateCustomerCreditUseCase {
  final CustomerRepository _repository;

  UpdateCustomerCreditUseCase(this._repository);

  Future<void> call(int customerId, double amount, {bool isIncrement = true}) {
    return _repository.updateCustomerCredit(
      customerId,
      amount,
      isIncrement: isIncrement,
    );
  }
}
