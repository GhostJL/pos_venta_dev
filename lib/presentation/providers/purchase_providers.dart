import 'package:posventa/domain/entities/purchase.dart';
import 'package:posventa/presentation/providers/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'purchase_providers.g.dart';

@riverpod
class PurchaseNotifier extends _$PurchaseNotifier {
  @override
  Future<List<Purchase>> build() async {
    return ref.read(getPurchasesUseCaseProvider).call();
  }

  Future<void> addPurchase(Purchase purchase) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(createPurchaseUseCaseProvider).call(purchase);
      return ref.read(getPurchasesUseCaseProvider).call();
    });
  }

  Future<void> updatePurchase(Purchase purchase) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(updatePurchaseUseCaseProvider).call(purchase);
      return ref.read(getPurchasesUseCaseProvider).call();
    });
  }

  Future<void> deletePurchase(int id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(deletePurchaseUseCaseProvider).call(id);
      return ref.read(getPurchasesUseCaseProvider).call();
    });
  }

  /// Receive a purchase and update inventory
  /// This triggers:
  /// 1. Purchase status update to 'completed'
  /// 2. Inventory stock increase
  /// 3. Kardex movement creation
  /// 4. Product cost update (Last Cost policy)
  /// Receive a purchase and update inventory (Partial or Complete)
  /// [receivedQuantities] - Map of Item ID to Quantity Received
  Future<void> receivePurchase(
    int purchaseId,
    Map<int, double> receivedQuantities,
    int receivedBy,
  ) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(receivePurchaseUseCaseProvider)
          .call(purchaseId, receivedQuantities, receivedBy);
      return ref.read(getPurchasesUseCaseProvider).call();
    });
  }

  Future<void> cancelPurchase(int purchaseId, int userId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(cancelPurchaseUseCaseProvider).call(purchaseId, userId);
      return ref.read(getPurchasesUseCaseProvider).call();
    });
  }
}

@riverpod
Future<Purchase?> purchaseById(Ref ref, int id) {
  return ref.watch(getPurchaseByIdUseCaseProvider).call(id);
}
