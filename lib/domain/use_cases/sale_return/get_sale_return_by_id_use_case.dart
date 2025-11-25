import 'package:posventa/domain/entities/sale_return.dart';
import 'package:posventa/domain/repositories/sale_return_repository.dart';

class GetSaleReturnByIdUseCase {
  final SaleReturnRepository _repository;

  GetSaleReturnByIdUseCase(this._repository);

  Future<SaleReturn?> call(int id) async {
    return await _repository.getSaleReturnById(id);
  }
}
