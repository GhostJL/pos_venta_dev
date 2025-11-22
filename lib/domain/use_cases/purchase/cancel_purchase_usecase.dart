import 'package:posventa/domain/repositories/purchase_repository.dart';

class CancelPurchaseUseCase {
  final PurchaseRepository repository;

  CancelPurchaseUseCase(this.repository);

  Future<void> call(int purchaseId, int userId) async {
    return await repository.cancelPurchase(purchaseId, userId);
  }
}
