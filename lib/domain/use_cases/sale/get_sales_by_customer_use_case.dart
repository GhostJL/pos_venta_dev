import 'package:posventa/domain/entities/sale.dart';
import 'package:posventa/domain/repositories/sale_repository.dart';

class GetSalesByCustomerUseCase {
  final SaleRepository repository;

  GetSalesByCustomerUseCase(this.repository);

  Future<List<Sale>> call({required int customerId, int? limit, int? offset}) {
    return repository.getSales(
      customerId: customerId,
      limit: limit,
      offset: offset,
    );
  }
}
