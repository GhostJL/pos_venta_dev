import 'package:posventa/domain/repositories/customer_repository.dart';

class GenerateNextCustomerCodeUseCase {
  final CustomerRepository _repository;

  GenerateNextCustomerCodeUseCase(this._repository);

  Future<String> call() async {
    return await _repository.generateNextCustomerCode();
  }
}
