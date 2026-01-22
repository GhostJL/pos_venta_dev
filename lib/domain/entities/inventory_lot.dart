import 'package:equatable/equatable.dart';

class InventoryLot extends Equatable {
  final int id;
  final int productId;
  final int? variantId;
  final int warehouseId;
  final String lotNumber;
  final double quantity;
  final double originalQuantity;
  final int unitCostCents;
  final int totalCostCents;
  final DateTime? expirationDate;
  final DateTime receivedAt;

  const InventoryLot({
    required this.id,
    required this.productId,
    this.variantId,
    required this.warehouseId,
    required this.lotNumber,
    required this.quantity,
    required this.originalQuantity,
    required this.unitCostCents,
    required this.totalCostCents,
    this.expirationDate,
    required this.receivedAt,
  });

  @override
  List<Object?> get props => [
    id,
    productId,
    variantId,
    warehouseId,
    lotNumber,
    quantity,
    unitCostCents,
    totalCostCents,
    expirationDate,
    receivedAt,
  ];
}
