import 'package:posventa/data/models/discount_model.dart';
import 'package:posventa/domain/entities/discount.dart';

abstract class DiscountLocalDataSource {
  Future<List<Discount>> getAllDiscounts();
  Future<List<Discount>> getActiveDiscounts();
  Future<Discount?> getDiscountById(int id);
  Future<int> createDiscount(DiscountModel discount);
  Future<void> updateDiscount(DiscountModel discount);
  Future<void> deleteDiscount(int id);

  Future<List<Discount>> getDiscountsForVariant(int variantId);
  Future<void> assignDiscountToVariant(int variantId, int discountId);
  Future<void> removeDiscountFromVariant(int variantId, int discountId);
  Future<void> updateVariantDiscounts(int variantId, List<int> discountIds);
}
