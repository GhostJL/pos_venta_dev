import 'package:posventa/domain/entities/purchase_item.dart';
import 'package:posventa/domain/repositories/purchase_item_repository.dart';

/// Use case to get purchase items within a date range
/// Useful for POS reporting and analytics
class GetPurchaseItemsByDateRangeUseCase {
  final PurchaseItemRepository repository;

  GetPurchaseItemsByDateRangeUseCase(this.repository);

  Future<List<PurchaseItem>> call(DateTime startDate, DateTime endDate) {
    return repository.getPurchaseItemsByDateRange(startDate, endDate);
  }
}
