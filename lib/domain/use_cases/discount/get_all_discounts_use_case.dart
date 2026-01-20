import 'package:posventa/domain/entities/discount.dart';
import 'package:posventa/domain/repositories/discount_repository.dart';

class GetAllDiscountsUseCase {
  final DiscountRepository repository;

  GetAllDiscountsUseCase(this.repository);

  Future<List<Discount>> execute() {
    return repository.getAllDiscounts();
  }
}
