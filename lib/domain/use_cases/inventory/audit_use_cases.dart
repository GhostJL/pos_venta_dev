import 'package:posventa/domain/entities/inventory_audit.dart';
import 'package:posventa/domain/repositories/inventory_audit_repository.dart';
import 'package:posventa/domain/repositories/inventory_repository.dart';

class StartAuditUseCase {
  final InventoryAuditRepository auditRepository;
  final InventoryRepository inventoryRepository;

  StartAuditUseCase(this.auditRepository, this.inventoryRepository);

  Future<int> call({
    required int warehouseId,
    required int performedBy,
    String? notes,
  }) async {
    // 1. Create the session
    final audit = InventoryAuditEntity(
      auditDate: DateTime.now(),
      warehouseId: warehouseId,
      performedBy: performedBy,
      status: InventoryAuditStatus.draft,
      notes: notes,
    );

    final auditId = await auditRepository.createAudit(audit);

    // 2. Take snapshot
    final currentInventory = await inventoryRepository.getAllInventory();

    // Filter by warehouse if needed (repository should ideally allow this)
    final filteredInventory = currentInventory
        .where((i) => i.warehouseId == warehouseId)
        .toList();

    final auditItems = filteredInventory.map((inv) {
      return InventoryAuditItemEntity(
        auditId: auditId,
        productId: inv.productId,
        variantId: inv.variantId,
        expectedQuantity: inv.quantityOnHand,
        countedQuantity: 0.0, // Initial state
      );
    }).toList();

    await auditRepository.createAuditItems(auditItems);

    return auditId;
  }
}

class CompleteAuditUseCase {
  final InventoryAuditRepository auditRepository;

  CompleteAuditUseCase(this.auditRepository);

  Future<void> call(int auditId, int performedBy, {String? reason}) async {
    await auditRepository.completeAudit(auditId, performedBy, reason: reason);
  }
}

class UpdateAuditItemUseCase {
  final InventoryAuditRepository auditRepository;

  UpdateAuditItemUseCase(this.auditRepository);

  Future<void> call(InventoryAuditItemEntity item) async {
    await auditRepository.updateAuditItem(item);
  }
}
