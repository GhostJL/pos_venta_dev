import 'package:posventa/domain/entities/sale_return_item.dart';

enum SaleReturnStatus { completed, cancelled }

enum RefundMethod {
  cash('cash', 'Efectivo'),
  card('card', 'Tarjeta'),
  credit('tra', 'Crédito');

  const RefundMethod(this.code, this.displayName);
  final String code;
  final String displayName;

  static RefundMethod fromCode(String code) {
    return RefundMethod.values.firstWhere(
      (method) => method.code == code,
      orElse: () => RefundMethod.cash,
    );
  }
}

class SaleReturn {
  final int? id;
  final String returnNumber;
  final int saleId;
  final int warehouseId;
  final int? customerId;
  final int processedBy;
  final int subtotalCents;
  final int taxCents;
  final int totalCents;
  final RefundMethod refundMethod;
  final String reason;
  final String? notes;
  final SaleReturnStatus status;
  final DateTime returnDate;
  final DateTime createdAt;
  final List<SaleReturnItem> items;

  // Optional fields for display
  final String? saleNumber;
  final String? customerName;
  final String? processedByName;

  const SaleReturn({
    this.id,
    required this.returnNumber,
    required this.saleId,
    required this.warehouseId,
    this.customerId,
    required this.processedBy,
    required this.subtotalCents,
    this.taxCents = 0,
    required this.totalCents,
    required this.refundMethod,
    required this.reason,
    this.notes,
    this.status = SaleReturnStatus.completed,
    required this.returnDate,
    required this.createdAt,
    this.items = const [],
    this.saleNumber,
    this.customerName,
    this.processedByName,
  });

  double get subtotal => subtotalCents / 100.0;
  double get tax => taxCents / 100.0;
  double get total => totalCents / 100.0;
}
