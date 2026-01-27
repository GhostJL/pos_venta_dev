import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:posventa/domain/entities/inventory_audit.dart';
import 'package:posventa/presentation/providers/di/inventory_di.dart';
import 'package:posventa/presentation/providers/auth_provider.dart';

part 'inventory_audit_view_model.g.dart';

@riverpod
class InventoryAuditViewModel extends _$InventoryAuditViewModel {
  @override
  FutureOr<InventoryAuditEntity?> build() async {
    return null; // No active audit by default
  }

  Future<void> startNewAudit(int warehouseId, {String? notes}) async {
    state = const AsyncValue.loading();
    try {
      final user = ref.read(authProvider).user;
      if (user == null || user.id == null) {
        throw Exception('Usuario no autenticado');
      }
      final performedBy = user.id!;

      final auditId = await ref
          .read(startAuditUseCaseProvider)
          .call(
            warehouseId: warehouseId,
            performedBy: performedBy,
            notes: notes,
          );

      final audit = await ref
          .read(inventoryAuditRepositoryProvider)
          .getAuditById(auditId);

      // Refresh the list so the new audit appears in the sidebar
      ref.invalidate(inventoryAuditListProvider);

      state = AsyncValue.data(audit);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> loadAudit(int auditId) async {
    state = const AsyncValue.loading();
    try {
      final audit = await ref
          .read(inventoryAuditRepositoryProvider)
          .getAuditById(auditId);
      state = AsyncValue.data(audit);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> scanProduct(String barcode) async {
    final audit = state.value;
    if (audit == null) return;

    // Find item by barcode
    final itemIndex = audit.items.indexWhere((i) => i.barcode == barcode);
    if (itemIndex != -1) {
      final item = audit.items[itemIndex];
      // Increment count
      final updatedItem = item.copyWith(
        countedQuantity: item.countedQuantity + 1,
        countedAt: DateTime.now(),
      );

      await ref.read(updateAuditItemUseCaseProvider).call(updatedItem);

      // Update state locally for immediate feedback
      final updatedItems = [...audit.items];
      updatedItems[itemIndex] = updatedItem;
      state = AsyncValue.data(audit.copyWith(items: updatedItems));
    } else {
      // Product not in snapshot or wrong barcode
      throw Exception(
        'Producto no encontrado en este inventario o código inválido',
      );
    }
  }

  Future<void> updateItemCount(int itemId, double count) async {
    final audit = state.value;
    if (audit == null) return;

    final itemIndex = audit.items.indexWhere((i) => i.id == itemId);
    if (itemIndex != -1) {
      final item = audit.items[itemIndex];
      final updatedItem = item.copyWith(
        countedQuantity: count,
        countedAt: DateTime.now(),
      );

      await ref.read(updateAuditItemUseCaseProvider).call(updatedItem);

      final updatedItems = [...audit.items];
      updatedItems[itemIndex] = updatedItem;
      state = AsyncValue.data(audit.copyWith(items: updatedItems));
    }
  }

  Future<void> fillWithSystemStock() async {
    final audit = state.value;
    if (audit == null) return;

    state = const AsyncValue.loading();
    try {
      final updatedItems = <InventoryAuditItemEntity>[];

      for (final item in audit.items) {
        // Only update if not already counted (optional decision, but safer to overwrite all for "Copy System Stock" action,
        // or maybe only 0s? User request implies "use total count", so overwriting seems appropriate or filling all.
        // Let's overwrite all to match system stock as a baseline.)
        final updatedItem = item.copyWith(
          countedQuantity: item.expectedQuantity,
          countedAt: DateTime.now(),
        );
        updatedItems.add(updatedItem);

        // Update in DB (we could optimize this with a batch update use case if improved later)
        await ref.read(updateAuditItemUseCaseProvider).call(updatedItem);
      }

      state = AsyncValue.data(audit.copyWith(items: updatedItems));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // --- Quick Audit Logic ---

  void startQuickAudit() {
    final audit = state.value;
    if (audit == null || audit.items.isEmpty) return;

    // Start at the first uncounted item, or 0 if all are counted
    final firstUncounted = audit.items.indexWhere(
      (i) => i.countedQuantity == 0,
    );
    final startIndex = firstUncounted != -1 ? firstUncounted : 0;

    ref.read(quickAuditStateProvider.notifier).start(startIndex);
  }

  void exitQuickAudit() {
    ref.read(quickAuditStateProvider.notifier).stop();
  }

  Future<void> confirmQuickAuditItemAndNext(double quantity) async {
    final audit = state.value;
    // Get current index from the separate provider
    final currentIndex = ref.read(quickAuditStateProvider);

    if (audit == null ||
        currentIndex < 0 ||
        currentIndex >= audit.items.length) {
      return;
    }

    final currentItem = audit.items[currentIndex];

    // Save current
    await updateItemCount(currentItem.id!, quantity);

    // IMPORTANT: The updateItemCount refreshes 'state' (the audit).
    // The QuickAuditState provider is separate, so it maintains the index.

    // Move to next
    // Even if at the end, next() will take us to (length), which triggers the "Done" view in QuickAuditView
    ref.read(quickAuditStateProvider.notifier).next();
  }

  Future<InventoryAuditEntity?> completeAudit({String? reason}) async {
    final audit = state.value;
    if (audit == null) return null;

    state = const AsyncValue.loading();
    try {
      final user = ref.read(authProvider).user;
      if (user == null || user.id == null) {
        throw Exception('Usuario no autenticado');
      }
      final performedBy = user.id!;

      await ref
          .read(completeAuditUseCaseProvider)
          .call(audit.id!, performedBy, reason: reason);

      // Fetch the final state of the audit to return it (for PDF generation)
      final completedAudit = await ref
          .read(inventoryAuditRepositoryProvider)
          .getAuditById(audit.id!);

      // Refresh the list so the status update appears in the sidebar
      ref.invalidate(inventoryAuditListProvider);

      ref
          .read(quickAuditStateProvider.notifier)
          .stop(); // Reset quick audit on complete

      state = const AsyncValue.data(null); // Audit closed in the current view
      return completedAudit;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }
}

// Separate provider for the Quick Audit Index to avoid polluting the main Entity state
// and to allow specific UI rebuilds.
@riverpod
class QuickAuditState extends _$QuickAuditState {
  @override
  int build() => -1; // -1 means inactive

  void start(int startIndex) => state = startIndex;
  void next() => state++;
  void previous() {
    if (state > 0) state--;
  }

  void stop() => state = -1;
}

@riverpod
FutureOr<List<InventoryAuditEntity>> inventoryAuditList(ref) async {
  return ref.watch(inventoryAuditRepositoryProvider).getAllAudits();
}
