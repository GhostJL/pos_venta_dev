import 'package:posventa/domain/entities/inventory.dart';

class InventoryModel extends Inventory {
  InventoryModel({
    super.id,
    required super.productId,
    required super.warehouseId,
    super.quantityOnHand,
    super.quantityReserved,
    super.minStock,
    super.maxStock,
    super.lotNumber,
    super.expirationDate,
    super.updatedAt,
  });

  factory InventoryModel.fromJson(Map<String, dynamic> json) {
    return InventoryModel(
      id: json['id'],
      productId: json['product_id'],
      warehouseId: json['warehouse_id'],
      quantityOnHand: (json['quantity_on_hand'] as num?)?.toDouble() ?? 0.0,
      quantityReserved: (json['quantity_reserved'] as num?)?.toDouble() ?? 0.0,
      minStock: json['min_stock'],
      maxStock: json['max_stock'],
      lotNumber: json['lot_number'],
      expirationDate: json['expiration_date'] != null
          ? DateTime.parse(json['expiration_date'])
          : null,
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
      'quantity_on_hand': quantityOnHand,
      'quantity_reserved': quantityReserved,
      'min_stock': minStock,
      'max_stock': maxStock,
      'lot_number': lotNumber,
      'expiration_date': expirationDate?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory InventoryModel.fromEntity(Inventory inventory) {
    return InventoryModel(
      id: inventory.id,
      productId: inventory.productId,
      warehouseId: inventory.warehouseId,
      quantityOnHand: inventory.quantityOnHand,
      quantityReserved: inventory.quantityReserved,
      minStock: inventory.minStock,
      maxStock: inventory.maxStock,
      lotNumber: inventory.lotNumber,
      expirationDate: inventory.expirationDate,
      updatedAt: inventory.updatedAt,
    );
  }
}
