import 'package:posventa/domain/entities/discount.dart';

abstract class DiscountRepository {
  Future<List<Discount>> getAllDiscounts();
  Future<List<Discount>> getActiveDiscounts();
  Future<Discount?> getDiscountById(int id);
  Future<void> createDiscount(Discount discount);
  Future<void> updateDiscount(Discount discount);
  Future<void> deleteDiscount(int id);

  // Pivot table operations
  Future<List<Discount>> getDiscountsForVariant(int variantId);
  Future<void> assignDiscountToVariant(int variantId, int discountId);
  Future<void> removeDiscountFromVariant(int variantId, int discountId);
  Future<void> updateVariantDiscounts(int variantId, List<int> discountIds);
}
