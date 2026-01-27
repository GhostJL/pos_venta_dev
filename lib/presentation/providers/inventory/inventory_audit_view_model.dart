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

  Future<void> completeAudit({String? reason}) async {
    final audit = state.value;
    if (audit == null) return;

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
      state = const AsyncValue.data(null); // Audit closed
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

@riverpod
FutureOr<List<InventoryAuditEntity>> inventoryAuditList(ref) async {
  return ref.watch(inventoryAuditRepositoryProvider).getAllAudits();
}
