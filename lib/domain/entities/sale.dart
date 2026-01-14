import 'package:posventa/domain/entities/sale_item.dart';
import 'package:posventa/domain/entities/sale_payment.dart';

enum SaleStatus { completed, pending, cancelled, returned }

class Sale {
  final int? id;
  final String saleNumber;
  final int warehouseId;
  final int? customerId;
  final int cashierId;
  final int subtotalCents;
  final int discountCents;
  final int taxCents;
  final int totalCents;
  final int amountPaidCents;
  final int balanceCents;
  final String paymentStatus;
  final SaleStatus status;
  final DateTime saleDate;
  final DateTime createdAt;
  final int? cancelledBy;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  final List<SaleItem> items;
  final List<SalePayment> payments;
  final String? customerName; // For display

  const Sale({
    this.id,
    required this.saleNumber,
    required this.warehouseId,
    this.customerId,
    required this.cashierId,
    required this.subtotalCents,
    this.discountCents = 0,
    this.taxCents = 0,
    required this.totalCents,
    this.amountPaidCents = 0,
    this.balanceCents = 0,
    this.paymentStatus = 'unpaid',
    this.status = SaleStatus.completed,
    required this.saleDate,
    required this.createdAt,
    this.cancelledBy,
    this.cancelledAt,
    this.cancellationReason,
    this.items = const [],
    this.payments = const [],
    this.customerName,
  });

  double get subtotal => subtotalCents / 100.0;
  double get discount => discountCents / 100.0;
  double get tax => taxCents / 100.0;
  double get total => totalCents / 100.0;
  double get amountPaid => amountPaidCents / 100.0;
  double get balance => balanceCents / 100.0;
}
