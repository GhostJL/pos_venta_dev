import 'package:posventa/domain/entities/inventory.dart';

class InventoryModel extends Inventory {
  InventoryModel({
    super.id,
    required super.productId,
    required super.warehouseId,
    super.variantId,
    super.quantityOnHand,
    super.quantityReserved,
    super.minStock,
    super.maxStock,
    super.updatedAt,
  });

  factory InventoryModel.fromJson(Map<String, dynamic> json) {
    return InventoryModel(
      id: json['id'],
      productId: json['product_id'],
      warehouseId: json['warehouse_id'],
      variantId: json['variant_id'],
      quantityOnHand: (json['quantity_on_hand'] as num?)?.toDouble() ?? 0.0,
      quantityReserved: (json['quantity_reserved'] as num?)?.toDouble() ?? 0.0,
      minStock: json['min_stock'],
      maxStock: json['max_stock'],
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'warehouse_id': warehouseId,
      'variant_id': variantId,
      'quantity_on_hand': quantityOnHand,
      'quantity_reserved': quantityReserved,
      'min_stock': minStock,
      'max_stock': maxStock,
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory InventoryModel.fromEntity(Inventory inventory) {
    return InventoryModel(
      id: inventory.id,
      productId: inventory.productId,
      warehouseId: inventory.warehouseId,
      variantId: inventory.variantId,
      quantityOnHand: inventory.quantityOnHand,
      quantityReserved: inventory.quantityReserved,
      minStock: inventory.minStock,
      maxStock: inventory.maxStock,
      updatedAt: inventory.updatedAt,
    );
  }
}
