import 'package:posventa/domain/repositories/discount_repository.dart';

class DeleteDiscountUseCase {
  final DiscountRepository repository;

  DeleteDiscountUseCase(this.repository);

  Future<void> execute(int id) {
    return repository.deleteDiscount(id);
  }
}
