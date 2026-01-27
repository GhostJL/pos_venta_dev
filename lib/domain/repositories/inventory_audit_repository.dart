import 'package:posventa/domain/entities/inventory_audit.dart';

abstract class InventoryAuditRepository {
  Future<List<InventoryAuditEntity>> getAllAudits();
  Future<InventoryAuditEntity?> getAuditById(int id);
  Future<int> createAudit(InventoryAuditEntity audit);
  Future<void> updateAudit(InventoryAuditEntity audit);
  Future<void> deleteAudit(int id);

  // Items
  Future<List<InventoryAuditItemEntity>> getAuditItems(int auditId);
  Future<void> updateAuditItem(InventoryAuditItemEntity item);
  Future<void> createAuditItems(List<InventoryAuditItemEntity> items);

  // Specific operations
  Future<void> completeAudit(int auditId, int performedBy, {String? reason});
  Future<void> cancelAudit(int auditId);
}
