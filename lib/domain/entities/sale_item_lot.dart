import 'package:equatable/equatable.dart';

/// Represents a lot deduction for a sale item.
/// This entity tracks which lots were used and how much quantity
/// was deducted from each lot during a sale.
class SaleItemLot extends Equatable {
  final int id;
  final int saleItemId;
  final int lotId;
  final double quantityDeducted;
  final DateTime createdAt;

  const SaleItemLot({
    required this.id,
    required this.saleItemId,
    required this.lotId,
    required this.quantityDeducted,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    saleItemId,
    lotId,
    quantityDeducted,
    createdAt,
  ];
}
