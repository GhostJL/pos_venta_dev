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
}
