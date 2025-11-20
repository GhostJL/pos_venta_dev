import 'package:posventa/domain/entities/sale.dart';

abstract class SaleRepository {
  Future<List<Sale>> getSales({
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  });
  Future<Sale?> getSaleById(int id);
  Future<Sale?> getSaleByNumber(String saleNumber);
  Future<int> createSale(Sale sale);
  Future<void> cancelSale(int saleId, int userId, String reason);
  Future<String> generateNextSaleNumber();
}
