import 'package:posventa/domain/entities/discount.dart';
import 'package:posventa/domain/repositories/discount_repository.dart';

class CreateDiscountUseCase {
  final DiscountRepository repository;

  CreateDiscountUseCase(this.repository);

  Future<void> execute(Discount discount) {
    return repository.createDiscount(discount);
  }
}
