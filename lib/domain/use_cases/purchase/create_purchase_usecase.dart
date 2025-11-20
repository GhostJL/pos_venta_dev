import 'package:posventa/domain/entities/purchase.dart';
import 'package:posventa/domain/repositories/purchase_repository.dart';

class CreatePurchaseUseCase {
  final PurchaseRepository repository;

  CreatePurchaseUseCase(this.repository);

  Future<int> call(Purchase purchase) async {
    return await repository.createPurchase(purchase);
  }
}
