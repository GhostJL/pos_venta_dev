import '../../domain/entities/sale_item_lot.dart';

class SaleItemLotModel extends SaleItemLot {
  const SaleItemLotModel({
    required super.id,
    required super.saleItemId,
    required super.lotId,
    required super.quantityDeducted,
    required super.createdAt,
  });

  factory SaleItemLotModel.fromJson(Map<String, dynamic> json) {
    return SaleItemLotModel(
      id: json['id'] as int,
      saleItemId: json['sale_item_id'] as int,
      lotId: json['lot_id'] as int,
      quantityDeducted: (json['quantity_deducted'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sale_item_id': saleItemId,
      'lot_id': lotId,
      'quantity_deducted': quantityDeducted,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory SaleItemLotModel.fromEntity(SaleItemLot entity) {
    return SaleItemLotModel(
      id: entity.id,
      saleItemId: entity.saleItemId,
      lotId: entity.lotId,
      quantityDeducted: entity.quantityDeducted,
      createdAt: entity.createdAt,
    );
  }
}
