import 'package:posventa/domain/entities/sale.dart';
import 'package:posventa/data/models/sale_item_model.dart';
import 'package:posventa/data/models/sale_payment_model.dart';

class SaleModel extends Sale {
  const SaleModel({
    super.id,
    required super.saleNumber,
    required super.warehouseId,
    super.customerId,
    required super.cashierId,
    required super.subtotalCents,
    super.discountCents,
    super.taxCents,
    required super.totalCents,
    super.status,
    required super.saleDate,
    required super.createdAt,
    super.cancelledBy,
    super.cancelledAt,
    super.cancellationReason,
    super.items,
    super.payments,
    super.customerName,
  });

  factory SaleModel.fromJson(Map<String, dynamic> json) {
    return SaleModel(
      id: json['id'],
      saleNumber: json['sale_number'],
      warehouseId: json['warehouse_id'],
      customerId: json['customer_id'],
      cashierId: json['cashier_id'],
      subtotalCents: json['subtotal_cents'],
      discountCents: json['discount_cents'] ?? 0,
      taxCents: json['tax_cents'] ?? 0,
      totalCents: json['total_cents'],
      status: json['status'] == 'completed'
          ? SaleStatus.completed
          : json['status'] == 'pending'
          ? SaleStatus.pending
          : json['status'] == 'returned'
          ? SaleStatus.returned
          : SaleStatus.cancelled,
      saleDate: DateTime.parse(json['sale_date']),
      createdAt: DateTime.parse(json['created_at']),
      cancelledBy: json['cancelled_by'],
      cancelledAt: json['cancelled_at'] != null
          ? DateTime.parse(json['cancelled_at'])
          : null,
      cancellationReason: json['cancellation_reason'],
      customerName: json['customer_name'], // Joined field
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sale_number': saleNumber,
      'warehouse_id': warehouseId,
      'customer_id': customerId,
      'cashier_id': cashierId,
      'subtotal_cents': subtotalCents,
      'discount_cents': discountCents,
      'tax_cents': taxCents,
      'total_cents': totalCents,
      'status': status.name,
      'sale_date': saleDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'cancelled_by': cancelledBy,
      'cancelled_at': cancelledAt?.toIso8601String(),
      'cancellation_reason': cancellationReason,
    };
  }

  factory SaleModel.fromEntity(Sale sale) {
    return SaleModel(
      id: sale.id,
      saleNumber: sale.saleNumber,
      warehouseId: sale.warehouseId,
      customerId: sale.customerId,
      cashierId: sale.cashierId,
      subtotalCents: sale.subtotalCents,
      discountCents: sale.discountCents,
      taxCents: sale.taxCents,
      totalCents: sale.totalCents,
      status: sale.status,
      saleDate: sale.saleDate,
      createdAt: sale.createdAt,
      cancelledBy: sale.cancelledBy,
      cancelledAt: sale.cancelledAt,
      cancellationReason: sale.cancellationReason,
      items: sale.items,
      payments: sale.payments,
      customerName: sale.customerName,
    );
  }

  SaleModel copyWith({
    List<SaleItemModel>? items,
    List<SalePaymentModel>? payments,
  }) {
    return SaleModel(
      id: id,
      saleNumber: saleNumber,
      warehouseId: warehouseId,
      customerId: customerId,
      cashierId: cashierId,
      subtotalCents: subtotalCents,
      discountCents: discountCents,
      taxCents: taxCents,
      totalCents: totalCents,
      status: status,
      saleDate: saleDate,
      createdAt: createdAt,
      cancelledBy: cancelledBy,
      cancelledAt: cancelledAt,
      cancellationReason: cancellationReason,
      items: items ?? this.items,
      payments: payments ?? this.payments,
      customerName: customerName,
    );
  }
}
