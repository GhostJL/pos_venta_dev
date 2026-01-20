import 'package:posventa/domain/entities/discount.dart';
import 'package:posventa/domain/repositories/discount_repository.dart';

class GetDiscountsForVariantUseCase {
  final DiscountRepository repository;

  GetDiscountsForVariantUseCase(this.repository);

  Future<List<Discount>> execute(int variantId) {
    return repository.getDiscountsForVariant(variantId);
  }
}
