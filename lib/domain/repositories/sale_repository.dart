import 'package:posventa/domain/entities/sale.dart';
import 'package:posventa/domain/entities/sale_transaction.dart';

abstract class SaleRepository {
  Future<List<Sale>> getSales({
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
    int? cashierId,
    int? customerId,
  });

  Future<int> countSales({
    DateTime? startDate,
    DateTime? endDate,
    int? cashierId,
    int? customerId,
  });

  Stream<List<Sale>> getSalesStream({
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
    int? cashierId,
    int? customerId,
  });

  Future<Sale?> getSaleById(int id);

  Stream<Sale?> getSaleByIdStream(int id);

  Future<Sale?> getSaleByNumber(String saleNumber);

  /// Execute a sale transaction (FIFO lot selection done in Use Case)
  Future<int> executeSaleTransaction(SaleTransaction transaction);

  /// Execute a sale cancellation transaction
  Future<void> executeSaleCancellation(SaleCancellationTransaction transaction);

  Future<String> generateNextSaleNumber();
}
