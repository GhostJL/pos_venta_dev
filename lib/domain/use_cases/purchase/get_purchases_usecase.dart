import 'package:posventa/domain/entities/purchase.dart';
import 'package:posventa/domain/repositories/purchase_repository.dart';

class GetPurchasesUseCase {
  final PurchaseRepository repository;

  GetPurchasesUseCase(this.repository);

  Future<List<Purchase>> call() async {
    return await repository.getPurchases();
  }
}
