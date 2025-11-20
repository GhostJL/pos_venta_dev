import 'package:posventa/domain/entities/purchase_item.dart';
import 'package:posventa/presentation/providers/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'purchase_item_providers.g.dart';

/// Notifier for managing purchase items state
@riverpod
class PurchaseItemNotifier extends _$PurchaseItemNotifier {
  @override
  Future<List<PurchaseItem>> build() async {
    return ref.read(getPurchaseItemsUseCaseProvider).call();
  }

  /// Add a new purchase item
  Future<void> addPurchaseItem(PurchaseItem item) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(createPurchaseItemUseCaseProvider).call(item);
      return ref.read(getPurchaseItemsUseCaseProvider).call();
    });
  }

  /// Update an existing purchase item
  Future<void> updatePurchaseItem(PurchaseItem item) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(updatePurchaseItemUseCaseProvider).call(item);
      return ref.read(getPurchaseItemsUseCaseProvider).call();
    });
  }

  /// Delete a purchase item
  Future<void> deletePurchaseItem(int id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(deletePurchaseItemUseCaseProvider).call(id);
      return ref.read(getPurchaseItemsUseCaseProvider).call();
    });
  }

  /// Refresh the purchase items list
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(getPurchaseItemsUseCaseProvider).call(),
    );
  }
}

/// Provider to get a single purchase item by ID
@riverpod
Future<PurchaseItem?> purchaseItemById(Ref ref, int id) {
  return ref.watch(getPurchaseItemByIdUseCaseProvider).call(id);
}

/// Provider to get purchase items by purchase ID
@riverpod
Future<List<PurchaseItem>> purchaseItemsByPurchaseId(Ref ref, int purchaseId) {
  return ref
      .watch(getPurchaseItemsByPurchaseIdUseCaseProvider)
      .call(purchaseId);
}

/// Provider to get purchase items by product ID
@riverpod
Future<List<PurchaseItem>> purchaseItemsByProductId(Ref ref, int productId) {
  return ref.watch(getPurchaseItemsByProductIdUseCaseProvider).call(productId);
}

/// Provider to get purchase items by date range
@riverpod
Future<List<PurchaseItem>> purchaseItemsByDateRange(
  Ref ref,
  DateTime startDate,
  DateTime endDate,
) {
  return ref
      .watch(getPurchaseItemsByDateRangeUseCaseProvider)
      .call(startDate, endDate);
}

/// Provider to get recent purchase items
@riverpod
Future<List<PurchaseItem>> recentPurchaseItems(Ref ref, {int limit = 50}) {
  return ref.watch(getRecentPurchaseItemsUseCaseProvider).call(limit: limit);
}
