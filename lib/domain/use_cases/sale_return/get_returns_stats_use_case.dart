import 'package:posventa/domain/repositories/sale_return_repository.dart';

class GetReturnsStatsUseCase {
  final SaleReturnRepository _repository;

  GetReturnsStatsUseCase(this._repository);

  Future<Map<String, dynamic>> call({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return _repository.getReturnsStats(startDate: startDate, endDate: endDate);
  }
}
