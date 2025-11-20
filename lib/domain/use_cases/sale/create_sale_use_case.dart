import 'package:posventa/domain/entities/sale.dart';
import 'package:posventa/domain/repositories/sale_repository.dart';

class CreateSaleUseCase {
  final SaleRepository _repository;

  CreateSaleUseCase(this._repository);

  Future<int> call(Sale sale) async {
    return await _repository.createSale(sale);
  }
}
