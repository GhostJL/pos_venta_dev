import 'package:posventa/domain/entities/purchase.dart';
import 'package:posventa/domain/repositories/purchase_repository.dart';

class GetPurchaseByIdUseCase {
  final PurchaseRepository repository;

  GetPurchaseByIdUseCase(this.repository);

  Future<Purchase?> call(int id) async {
    return await repository.getPurchaseById(id);
  }
}
