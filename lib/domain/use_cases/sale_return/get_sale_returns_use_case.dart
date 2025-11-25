import 'package:posventa/domain/entities/sale_return.dart';
import 'package:posventa/domain/repositories/sale_return_repository.dart';

class GetSaleReturnsUseCase {
  final SaleReturnRepository _repository;

  GetSaleReturnsUseCase(this._repository);

  Future<List<SaleReturn>> call({
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  }) async {
    return await _repository.getSaleReturns(
      startDate: startDate,
      endDate: endDate,
      limit: limit,
      offset: offset,
    );
  }
}
