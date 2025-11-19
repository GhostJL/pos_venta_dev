class Inventory {
  final int? id;
  final int productId;
  final int warehouseId;
  final double quantityOnHand;
  final double quantityReserved;
  final int? minStock;
  final int? maxStock;
  final String? lotNumber;
  final DateTime? expirationDate;
  final DateTime? updatedAt;

  Inventory({
    this.id,
    required this.productId,
    required this.warehouseId,
    this.quantityOnHand = 0.0,
    this.quantityReserved = 0.0,
    this.minStock,
    this.maxStock,
    this.lotNumber,
    this.expirationDate,
    this.updatedAt,
  });

  Inventory copyWith({
    int? id,
    int? productId,
    int? warehouseId,
    double? quantityOnHand,
    double? quantityReserved,
    int? minStock,
    int? maxStock,
    String? lotNumber,
    DateTime? expirationDate,
    DateTime? updatedAt,
  }) {
    return Inventory(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      warehouseId: warehouseId ?? this.warehouseId,
      quantityOnHand: quantityOnHand ?? this.quantityOnHand,
      quantityReserved: quantityReserved ?? this.quantityReserved,
      minStock: minStock ?? this.minStock,
      maxStock: maxStock ?? this.maxStock,
      lotNumber: lotNumber ?? this.lotNumber,
      expirationDate: expirationDate ?? this.expirationDate,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
