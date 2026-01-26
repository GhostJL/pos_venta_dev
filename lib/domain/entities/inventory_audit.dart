enum InventoryAuditStatus { draft, completed, cancelled }

class InventoryAuditEntity {
  final int? id;
  final DateTime auditDate;
  final int warehouseId;
  final int performedBy;
  final InventoryAuditStatus status;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<InventoryAuditItemEntity> items;

  InventoryAuditEntity({
    this.id,
    required this.auditDate,
    required this.warehouseId,
    required this.performedBy,
    this.status = InventoryAuditStatus.draft,
    this.notes,
    this.createdAt,
    this.updatedAt,
    this.items = const [],
  });

  InventoryAuditEntity copyWith({
    int? id,
    DateTime? auditDate,
    int? warehouseId,
    int? performedBy,
    InventoryAuditStatus? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<InventoryAuditItemEntity>? items,
  }) {
    return InventoryAuditEntity(
      id: id ?? this.id,
      auditDate: auditDate ?? this.auditDate,
      warehouseId: warehouseId ?? this.warehouseId,
      performedBy: performedBy ?? this.performedBy,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      items: items ?? this.items,
    );
  }
}

class InventoryAuditItemEntity {
  final int? id;
  final int auditId;
  final int productId;
  final int? variantId;
  final double expectedQuantity;
  final double countedQuantity;
  final DateTime? countedAt;

  // Helper fields for UI
  final String? productName;
  final String? variantName;
  final String? barcode;

  InventoryAuditItemEntity({
    this.id,
    required this.auditId,
    required this.productId,
    this.variantId,
    required this.expectedQuantity,
    this.countedQuantity = 0.0,
    this.countedAt,
    this.productName,
    this.variantName,
    this.barcode,
  });

  double get difference => countedQuantity - expectedQuantity;

  InventoryAuditItemEntity copyWith({
    int? id,
    int? auditId,
    int? productId,
    int? variantId,
    double? expectedQuantity,
    double? countedQuantity,
    DateTime? countedAt,
    String? productName,
    String? variantName,
    String? barcode,
  }) {
    return InventoryAuditItemEntity(
      id: id ?? this.id,
      auditId: auditId ?? this.auditId,
      productId: productId ?? this.productId,
      variantId: variantId ?? this.variantId,
      expectedQuantity: expectedQuantity ?? this.expectedQuantity,
      countedQuantity: countedQuantity ?? this.countedQuantity,
      countedAt: countedAt ?? this.countedAt,
      productName: productName ?? this.productName,
      variantName: variantName ?? this.variantName,
      barcode: barcode ?? this.barcode,
    );
  }
}
