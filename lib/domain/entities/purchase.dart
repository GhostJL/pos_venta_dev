import 'package:posventa/domain/entities/purchase_item.dart';

enum PurchaseStatus { pending, completed, cancelled }

class Purchase {
  final int? id;
  final String purchaseNumber;
  final int supplierId;
  final int warehouseId;
  final int subtotalCents;
  final int taxCents;
  final int totalCents;
  final PurchaseStatus status;
  final DateTime purchaseDate;
  final DateTime? receivedDate;
  final String? supplierInvoiceNumber;
  final int requestedBy;
  final int? receivedBy;
  final DateTime createdAt;
  final List<PurchaseItem> items;
  final String? supplierName; // For display
  final String? warehouseName; // For display

  const Purchase({
    this.id,
    required this.purchaseNumber,
    required this.supplierId,
    required this.warehouseId,
    required this.subtotalCents,
    this.taxCents = 0,
    required this.totalCents,
    this.status = PurchaseStatus.pending,
    required this.purchaseDate,
    this.receivedDate,
    this.supplierInvoiceNumber,
    required this.requestedBy,
    this.receivedBy,
    required this.createdAt,
    this.items = const [],
    this.supplierName,
    this.warehouseName,
  });

  double get subtotal => subtotalCents / 100.0;
  double get tax => taxCents / 100.0;
  double get total => totalCents / 100.0;
}
