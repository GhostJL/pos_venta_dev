import 'package:posventa/domain/entities/discount.dart';
import 'package:posventa/domain/repositories/discount_repository.dart';

class UpdateDiscountUseCase {
  final DiscountRepository repository;

  UpdateDiscountUseCase(this.repository);

  Future<void> execute(Discount discount) {
    return repository.updateDiscount(discount);
  }
}
