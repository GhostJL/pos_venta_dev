import 'package:posventa/domain/entities/product_variant.dart';

/// Result of a variant conversion operation
/// Contains the target variant ID, converted quantity, and adjusted cost
class VariantConversionResult {
  final int targetVariantId;
  final double convertedQuantity;
  final int convertedUnitCostCents;
  final bool wasConverted;

  const VariantConversionResult({
    required this.targetVariantId,
    required this.convertedQuantity,
    required this.convertedUnitCostCents,
    required this.wasConverted,
  });

  /// Factory for when no conversion is needed (sales variant or no linked variant)
  factory VariantConversionResult.noConversion({
    required int variantId,
    required double quantity,
    required int unitCostCents,
  }) {
    return VariantConversionResult(
      targetVariantId: variantId,
      convertedQuantity: quantity,
      convertedUnitCostCents: unitCostCents,
      wasConverted: false,
    );
  }

  /// Factory for successful conversion from purchase to sales variant
  factory VariantConversionResult.converted({
    required int targetVariantId,
    required double convertedQuantity,
    required int convertedUnitCostCents,
  }) {
    return VariantConversionResult(
      targetVariantId: targetVariantId,
      convertedQuantity: convertedQuantity,
      convertedUnitCostCents: convertedUnitCostCents,
      wasConverted: true,
    );
  }
}

/// Exception thrown when variant conversion fails
class VariantConversionException implements Exception {
  final String message;
  const VariantConversionException(this.message);

  @override
  String toString() => 'VariantConversionException: $message';
}

/// Service responsible for converting purchase variants to sales variants
/// Handles the business logic of variant linking and quantity/cost conversion
class VariantConversionService {
  /// Convert a purchase variant to its linked sales variant
  ///
  /// If the variant is a purchase variant with a linked sales variant,
  /// this method will:
  /// 1. Calculate the converted quantity using the conversion factor
  /// 2. Calculate the adjusted unit cost (cost per sales unit)
  /// 3. Return the target sales variant ID
  ///
  /// If the variant is already a sales variant or has no linked variant,
  /// it returns the original values unchanged.
  ///
  /// Throws [VariantConversionException] if:
  /// - The variant type is invalid
  /// - The conversion factor is <= 0
  /// - The linked variant ID is invalid
  VariantConversionResult convertPurchaseToSales({
    required ProductVariant variant,
    required double quantity,
    required int unitCostCents,
  }) {
    // Validate variant type
    if (variant.type != VariantType.purchase &&
        variant.type != VariantType.sales) {
      throw VariantConversionException(
        'Invalid variant type: ${variant.type}. Must be either "purchase" or "sales".',
      );
    }

    // If it's a sales variant, no conversion needed
    if (variant.type == VariantType.sales) {
      return VariantConversionResult.noConversion(
        variantId: variant.id!,
        quantity: quantity,
        unitCostCents: unitCostCents,
      );
    }

    // If it's a purchase variant without a linked variant, no conversion
    if (variant.linkedVariantId == null) {
      return VariantConversionResult.noConversion(
        variantId: variant.id!,
        quantity: quantity,
        unitCostCents: unitCostCents,
      );
    }

    // Validate conversion factor
    final conversionFactor = variant.conversionFactor;
    if (conversionFactor <= 0) {
      throw VariantConversionException(
        'Invalid conversion factor: $conversionFactor. Must be greater than 0.',
      );
    }

    // Perform conversion
    // Example: If buying a box of 12 units at \$120
    // - quantity = 1 box
    // - conversionFactor = 12
    // - unitCostCents = 12000 cents (\$120)
    // Result:
    // - convertedQuantity = 12 units
    // - convertedUnitCostCents = 1000 cents (\$10 per unit)
    final convertedQuantity = quantity * conversionFactor;
    final convertedUnitCostCents = (unitCostCents / conversionFactor).round();

    return VariantConversionResult.converted(
      targetVariantId: variant.linkedVariantId!,
      convertedQuantity: convertedQuantity,
      convertedUnitCostCents: convertedUnitCostCents,
    );
  }

  /// Batch convert multiple purchase items
  /// Useful when receiving multiple items in a purchase order
  List<VariantConversionResult> convertBatch({
    required List<ProductVariant> variants,
    required List<double> quantities,
    required List<int> unitCosts,
  }) {
    if (variants.length != quantities.length ||
        variants.length != unitCosts.length) {
      throw VariantConversionException(
        'Batch conversion requires equal length lists. '
        'Got ${variants.length} variants, ${quantities.length} quantities, ${unitCosts.length} costs.',
      );
    }

    final results = <VariantConversionResult>[];
    for (var i = 0; i < variants.length; i++) {
      results.add(
        convertPurchaseToSales(
          variant: variants[i],
          quantity: quantities[i],
          unitCostCents: unitCosts[i],
        ),
      );
    }
    return results;
  }
}
