import 'package:posventa/domain/entities/sale_return.dart';

abstract class SaleReturnRepository {
  /// Get list of sale returns with optional filters
  Future<List<SaleReturn>> getSaleReturns({
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  });

  Stream<List<SaleReturn>> getSaleReturnsStream({
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  });

  /// Get a specific sale return by ID with all items
  Future<SaleReturn?> getSaleReturnById(int id);

  /// Get a specific sale return by return number
  Future<SaleReturn?> getSaleReturnByNumber(String returnNumber);

  /// Create a new sale return (includes inventory movements)
  Future<int> createSaleReturn(SaleReturn saleReturn);

  /// Generate next sequential return number
  Future<String> generateNextReturnNumber();

  /// Check if a sale can be returned (not cancelled, completed, etc.)
  Future<bool> canReturnSale(int saleId);

  /// Get already returned quantities for each sale item
  /// Returns Map with saleItemId as key and returnedQuantity as value
  Future<Map<int, double>> getReturnedQuantities(int saleId);

  /// Checks if all items from a sale have been fully returned
  Future<bool> isSaleFullyReturned(int saleId);

  /// Get statistics for returns within a date range
  Future<Map<String, dynamic>> getReturnsStats({
    required DateTime startDate,
    required DateTime endDate,
  });
}
