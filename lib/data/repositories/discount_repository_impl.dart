import 'package:posventa/data/datasources/discount_local_datasource.dart';
import 'package:posventa/data/models/discount_model.dart';
import 'package:posventa/domain/entities/discount.dart';
import 'package:posventa/domain/repositories/discount_repository.dart';

class DiscountRepositoryImpl implements DiscountRepository {
  final DiscountLocalDataSource dataSource;

  DiscountRepositoryImpl(this.dataSource);

  @override
  Future<List<Discount>> getAllDiscounts() {
    return dataSource.getAllDiscounts();
  }

  @override
  Future<List<Discount>> getActiveDiscounts() {
    return dataSource.getActiveDiscounts();
  }

  @override
  Future<Discount?> getDiscountById(int id) {
    return dataSource.getDiscountById(id);
  }

  @override
  Future<void> createDiscount(Discount discount) {
    return dataSource.createDiscount(DiscountModel.fromEntity(discount));
  }

  @override
  Future<void> updateDiscount(Discount discount) {
    return dataSource.updateDiscount(DiscountModel.fromEntity(discount));
  }

  @override
  Future<void> deleteDiscount(int id) {
    return dataSource.deleteDiscount(id);
  }

  @override
  Future<List<Discount>> getDiscountsForVariant(int variantId) {
    return dataSource.getDiscountsForVariant(variantId);
  }

  @override
  Future<void> assignDiscountToVariant(int variantId, int discountId) {
    return dataSource.assignDiscountToVariant(variantId, discountId);
  }

  @override
  Future<void> removeDiscountFromVariant(int variantId, int discountId) {
    return dataSource.removeDiscountFromVariant(variantId, discountId);
  }

  @override
  Future<void> updateVariantDiscounts(int variantId, List<int> discountIds) {
    return dataSource.updateVariantDiscounts(variantId, discountIds);
  }
}
