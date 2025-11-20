import 'package:posventa/domain/entities/purchase.dart';
import 'package:posventa/domain/entities/purchase_item.dart';

class PurchaseModel extends Purchase {
  const PurchaseModel({
    super.id,
    required super.purchaseNumber,
    required super.supplierId,
    required super.warehouseId,
    required super.subtotalCents,
    super.taxCents,
    required super.totalCents,
    super.status,
    required super.purchaseDate,
    super.receivedDate,
    super.supplierInvoiceNumber,
    required super.requestedBy,
    super.receivedBy,
    required super.createdAt,
    super.items,
    super.supplierName,
  });

  factory PurchaseModel.fromJson(Map<String, dynamic> json) {
    return PurchaseModel(
      id: json['id'],
      purchaseNumber: json['purchase_number'],
      supplierId: json['supplier_id'],
      warehouseId: json['warehouse_id'],
      subtotalCents: json['subtotal_cents'],
      taxCents: json['tax_cents'] ?? 0,
      totalCents: json['total_cents'],
      status: PurchaseStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PurchaseStatus.pending,
      ),
      purchaseDate: DateTime.parse(json['purchase_date']),
      receivedDate: json['received_date'] != null
          ? DateTime.parse(json['received_date'])
          : null,
      supplierInvoiceNumber: json['supplier_invoice_number'],
      requestedBy: json['requested_by'],
      receivedBy: json['received_by'],
      createdAt: DateTime.parse(json['created_at']),
      supplierName: json['supplier_name'], // Joined field
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'purchase_number': purchaseNumber,
      'supplier_id': supplierId,
      'warehouse_id': warehouseId,
      'subtotal_cents': subtotalCents,
      'tax_cents': taxCents,
      'total_cents': totalCents,
      'status': status.name,
      'purchase_date': purchaseDate.toIso8601String(),
      'received_date': receivedDate?.toIso8601String(),
      'supplier_invoice_number': supplierInvoiceNumber,
      'requested_by': requestedBy,
      'received_by': receivedBy,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory PurchaseModel.fromEntity(Purchase purchase) {
    return PurchaseModel(
      id: purchase.id,
      purchaseNumber: purchase.purchaseNumber,
      supplierId: purchase.supplierId,
      warehouseId: purchase.warehouseId,
      subtotalCents: purchase.subtotalCents,
      taxCents: purchase.taxCents,
      totalCents: purchase.totalCents,
      status: purchase.status,
      purchaseDate: purchase.purchaseDate,
      receivedDate: purchase.receivedDate,
      supplierInvoiceNumber: purchase.supplierInvoiceNumber,
      requestedBy: purchase.requestedBy,
      receivedBy: purchase.receivedBy,
      createdAt: purchase.createdAt,
      items: purchase.items,
      supplierName: purchase.supplierName,
    );
  }

  PurchaseModel copyWith({List<PurchaseItem>? items}) {
    return PurchaseModel(
      id: id,
      purchaseNumber: purchaseNumber,
      supplierId: supplierId,
      warehouseId: warehouseId,
      subtotalCents: subtotalCents,
      taxCents: taxCents,
      totalCents: totalCents,
      status: status,
      purchaseDate: purchaseDate,
      receivedDate: receivedDate,
      supplierInvoiceNumber: supplierInvoiceNumber,
      requestedBy: requestedBy,
      receivedBy: receivedBy,
      createdAt: createdAt,
      items: items ?? this.items,
      supplierName: supplierName,
    );
  }
}
