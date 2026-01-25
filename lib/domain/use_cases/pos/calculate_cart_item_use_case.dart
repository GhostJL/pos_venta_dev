import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/entities/product_variant.dart';
import 'package:posventa/domain/entities/sale_item.dart';
import 'package:posventa/domain/entities/sale_item_tax.dart';
import 'package:posventa/domain/entities/discount.dart';
import 'package:posventa/domain/repositories/product_repository.dart';
import 'package:posventa/domain/use_cases/discount/get_discounts_for_variant_use_case.dart';

class CalculateCartItemUseCase {
  final ProductRepository _productRepository;
  final GetDiscountsForVariantUseCase _getDiscountsUseCase;

  CalculateCartItemUseCase(this._productRepository, this._getDiscountsUseCase);

  Future<SaleItem> execute({
    required Product product,
    ProductVariant? variant,
    required double quantity,
    required bool useTax,
    SaleItem? existingItem,
  }) async {
    // 1. Get Prices
    final unitPriceCents = variant != null
        ? variant.priceCents
        : (product.price * 100).round();
    final costPriceCents = variant != null
        ? variant.costPriceCents
        : (product.costPrice * 100).round();

    // 2. Gross Subtotal
    final subtotalCents = (unitPriceCents * quantity).round();

    // 3. Discounts
    int discountCents = 0;
    if (variant != null && variant.id != null) {
      final discounts = await _getDiscountsUseCase.execute(variant.id!);
      final now = DateTime.now();
      final activeDiscounts = discounts
          .where(
            (d) =>
                d.isActive &&
                (d.startDate == null || d.startDate!.isBefore(now)) &&
                (d.endDate == null || d.endDate!.isAfter(now)),
          )
          .toList();

      for (var d in activeDiscounts) {
        if (d.type == DiscountType.percentage) {
          // value is basis points (1000 = 10%)
          discountCents += (subtotalCents * (d.value / 10000)).round();
        } else {
          // value is cents off per unit
          discountCents += (d.value * quantity).round();
        }
      }
    }
    // Clamp discount
    if (discountCents > subtotalCents) discountCents = subtotalCents;

    final netSubtotalCents = subtotalCents - discountCents;

    // 4. Taxes
    int taxCents = 0;
    final taxesList = <SaleItemTax>[];

    if (useTax) {
      final taxesResult = await _productRepository.getTaxRatesForProduct(
        product.id!,
      );
      final rates = taxesResult.getOrElse((_) => []);
      for (var t in rates) {
        final amount = (netSubtotalCents * t.rate).round();
        taxCents += amount;
        taxesList.add(
          SaleItemTax(
            taxRateId: t.id!,
            taxName: t.name,
            taxRate: t.rate,
            taxAmountCents: amount,
          ),
        );
      }
    }

    final totalCents = netSubtotalCents + taxCents;

    if (existingItem != null) {
      return existingItem.copyWith(
        quantity: quantity,
        subtotalCents: subtotalCents,
        discountCents: discountCents,
        taxCents: taxCents,
        totalCents: totalCents,
        taxes: taxesList,
        unitPriceCents: unitPriceCents,
        costPriceCents: costPriceCents,
      );
    } else {
      return SaleItem(
        productId: product.id!,
        variantId: variant?.id,
        quantity: quantity,
        unitOfMeasure: product.unitOfMeasure,
        unitPriceCents: unitPriceCents,
        costPriceCents: costPriceCents,
        subtotalCents: subtotalCents,
        discountCents: discountCents,
        taxCents: taxCents,
        totalCents: totalCents,
        productName: product.name,
        variantDescription: variant?.description,
        variantName: variant?.variantName,
        taxes: taxesList,
        unitsPerPack: variant?.quantity ?? 1.0,
      );
    }
  }
}
