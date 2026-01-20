import 'package:posventa/domain/repositories/discount_repository.dart';

class UpdateVariantDiscountsUseCase {
  final DiscountRepository repository;

  UpdateVariantDiscountsUseCase(this.repository);

  Future<void> execute(int variantId, List<int> discountIds) {
    return repository.updateVariantDiscounts(variantId, discountIds);
  }
}
