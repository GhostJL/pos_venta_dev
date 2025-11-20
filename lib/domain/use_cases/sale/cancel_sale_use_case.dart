import 'package:posventa/domain/repositories/sale_repository.dart';

class CancelSaleUseCase {
  final SaleRepository _repository;

  CancelSaleUseCase(this._repository);

  Future<void> call(int saleId, int userId, String reason) async {
    await _repository.cancelSale(saleId, userId, reason);
  }
}
