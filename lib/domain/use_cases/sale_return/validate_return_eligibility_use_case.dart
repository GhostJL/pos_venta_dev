import 'package:posventa/domain/repositories/sale_return_repository.dart';

class ValidateReturnEligibilityUseCase {
  final SaleReturnRepository _repository;

  ValidateReturnEligibilityUseCase(this._repository);

  Future<bool> call(int saleId) async {
    return await _repository.canReturnSale(saleId);
  }
}
