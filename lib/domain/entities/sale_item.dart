import 'package:posventa/domain/entities/sale_item_tax.dart';

class SaleItem {
  final int? id;
  final int? saleId;
  final int productId;
  final int? variantId;
  final double quantity;
  final String unitOfMeasure;
  final int unitPriceCents;
  final int discountCents;
  final int subtotalCents;
  final int taxCents;
  final int totalCents;
  final int costPriceCents;
  final int? lotId;
  final String? productName; // For display convenience
  final String? variantDescription;

  const SaleItem({
    this.id,
    this.saleId,
    required this.productId,
    this.variantId,
    required this.quantity,
    required this.unitOfMeasure,
    required this.unitPriceCents,
    this.discountCents = 0,
    required this.subtotalCents,
    this.taxCents = 0,
    required this.totalCents,
    required this.costPriceCents,
    this.lotId,
    this.productName,
    this.variantDescription,
    this.taxes = const [],
    this.unitsPerPack = 1.0,
  });

  final List<SaleItemTax> taxes;
  final double unitsPerPack;

  double get unitPrice => unitPriceCents / 100.0;
  double get subtotal => subtotalCents / 100.0;
  double get tax => taxCents / 100.0;
  double get total => totalCents / 100.0;
  double get discount => discountCents / 100.0;

  SaleItem copyWith({
    int? id,
    int? saleId,
    int? productId,
    int? variantId,
    double? quantity,
    String? unitOfMeasure,
    int? unitPriceCents,
    int? discountCents,
    int? subtotalCents,
    int? taxCents,
    int? totalCents,
    int? costPriceCents,
    int? lotId,
    String? productName,
    String? variantDescription,
    List<SaleItemTax>? taxes,
    double? unitsPerPack,
  }) {
    return SaleItem(
      id: id ?? this.id,
      saleId: saleId ?? this.saleId,
      productId: productId ?? this.productId,
      variantId: variantId ?? this.variantId,
      quantity: quantity ?? this.quantity,
      unitOfMeasure: unitOfMeasure ?? this.unitOfMeasure,
      unitPriceCents: unitPriceCents ?? this.unitPriceCents,
      discountCents: discountCents ?? this.discountCents,
      subtotalCents: subtotalCents ?? this.subtotalCents,
      taxCents: taxCents ?? this.taxCents,
      totalCents: totalCents ?? this.totalCents,
      costPriceCents: costPriceCents ?? this.costPriceCents,
      lotId: lotId ?? this.lotId,
      productName: productName ?? this.productName,
      variantDescription: variantDescription ?? this.variantDescription,
      taxes: taxes ?? this.taxes,
      unitsPerPack: unitsPerPack ?? this.unitsPerPack,
    );
  }
}
