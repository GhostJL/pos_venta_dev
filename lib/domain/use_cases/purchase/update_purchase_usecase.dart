import 'package:posventa/domain/entities/purchase.dart';
import 'package:posventa/domain/repositories/purchase_repository.dart';

class UpdatePurchaseUseCase {
  final PurchaseRepository repository;

  UpdatePurchaseUseCase(this.repository);

  Future<void> call(Purchase purchase) async {
    await repository.updatePurchase(purchase);
  }
}
