import 'package:posventa/domain/entities/sale.dart';
import 'package:posventa/domain/repositories/sale_repository.dart';

class GetSaleByIdUseCase {
  final SaleRepository _repository;

  GetSaleByIdUseCase(this._repository);

  Future<Sale?> call(int id) async {
    return await _repository.getSaleById(id);
  }
}
