import 'package:posventa/domain/entities/sale.dart';
import 'package:posventa/domain/repositories/sale_repository.dart';

class GetSalesUseCase {
  final SaleRepository _repository;

  GetSalesUseCase(this._repository);

  Future<List<Sale>> call({
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  }) async {
    return await _repository.getSales(
      startDate: startDate,
      endDate: endDate,
      limit: limit,
      offset: offset,
    );
  }
}
