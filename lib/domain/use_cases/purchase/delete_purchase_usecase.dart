import 'package:posventa/domain/repositories/purchase_repository.dart';

class DeletePurchaseUseCase {
  final PurchaseRepository repository;

  DeletePurchaseUseCase(this.repository);

  Future<void> call(int id) async {
    await repository.deletePurchase(id);
  }
}
