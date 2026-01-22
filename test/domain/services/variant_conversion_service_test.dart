import 'package:flutter_test/flutter_test.dart';
import 'package:posventa/domain/services/variant_conversion_service.dart';
import 'package:posventa/domain/entities/product_variant.dart';

/// Unit tests for VariantConversionService
/// These tests validate the variant conversion logic is working correctly
void main() {
  late VariantConversionService service;

  setUp(() {
    service = VariantConversionService();
  });

  group('VariantConversionService - Basic Conversion', () {
    test('converts purchase variant to sales variant correctly', () {
      // Arrange: Box of 12 units at $120
      final purchaseVariant = ProductVariant(
        id: 1,
        productId: 100,
        variantName: 'Box of 12',
        priceCents: 12000,
        costPriceCents: 10000,
        type: VariantType.purchase,
        linkedVariantId: 2,
        conversionFactor: 12.0,
      );

      // Act: Convert 1 box
      final result = service.convertPurchaseToSales(
        variant: purchaseVariant,
        quantity: 1.0,
        unitCostCents: 12000,
      );

      // Assert: Should convert to 12 units at $10 each
      expect(result.targetVariantId, equals(2));
      expect(result.convertedQuantity, equals(12.0));
      expect(result.convertedUnitCostCents, equals(1000));
      expect(result.wasConverted, isTrue);
    });

    test('returns no conversion for sales variant', () {
      // Arrange: Already a sales variant
      final salesVariant = ProductVariant(
        id: 2,
        productId: 100,
        variantName: 'Unit',
        priceCents: 1500,
        costPriceCents: 1000,
        type: VariantType.sales,
      );

      // Act
      final result = service.convertPurchaseToSales(
        variant: salesVariant,
        quantity: 10.0,
        unitCostCents: 1000,
      );

      // Assert: No conversion should occur
      expect(result.targetVariantId, equals(2));
      expect(result.convertedQuantity, equals(10.0));
      expect(result.convertedUnitCostCents, equals(1000));
      expect(result.wasConverted, isFalse);
    });

    test('handles purchase variant without linked variant', () {
      // Arrange: Purchase variant with no sales link
      final purchaseVariant = ProductVariant(
        id: 1,
        productId: 100,
        variantName: 'Bulk',
        priceCents: 10000,
        costPriceCents: 8000,
        type: VariantType.purchase,
        linkedVariantId: null,
      );

      // Act
      final result = service.convertPurchaseToSales(
        variant: purchaseVariant,
        quantity: 5.0,
        unitCostCents: 8000,
      );

      // Assert: Should return original values
      expect(result.targetVariantId, equals(1));
      expect(result.convertedQuantity, equals(5.0));
      expect(result.convertedUnitCostCents, equals(8000));
      expect(result.wasConverted, isFalse);
    });
  });

  group('VariantConversionService - Validation', () {
    test('throws exception for zero conversion factor', () {
      // Arrange: Invalid conversion factor
      final invalidVariant = ProductVariant(
        id: 1,
        productId: 100,
        variantName: 'Invalid',
        priceCents: 1000,
        costPriceCents: 500,
        type: VariantType.purchase,
        linkedVariantId: 2,
        conversionFactor: 0.0,
      );

      // Act & Assert
      expect(
        () => service.convertPurchaseToSales(
          variant: invalidVariant,
          quantity: 1.0,
          unitCostCents: 1000,
        ),
        throwsA(isA<VariantConversionException>()),
      );
    });

    test('throws exception for negative conversion factor', () {
      // Arrange
      final invalidVariant = ProductVariant(
        id: 1,
        productId: 100,
        variantName: 'Invalid',
        priceCents: 1000,
        costPriceCents: 500,
        type: VariantType.purchase,
        linkedVariantId: 2,
        conversionFactor: -5.0,
      );

      // Act & Assert
      expect(
        () => service.convertPurchaseToSales(
          variant: invalidVariant,
          quantity: 1.0,
          unitCostCents: 1000,
        ),
        throwsA(isA<VariantConversionException>()),
      );
    });
  });

  group('VariantConversionService - Batch Operations', () {
    test('batch conversion processes multiple variants correctly', () {
      // Arrange: Multiple purchase variants
      final variants = [
        ProductVariant(
          id: 1,
          productId: 100,
          variantName: 'Box of 12',
          priceCents: 12000,
          costPriceCents: 10000,
          type: VariantType.purchase,
          linkedVariantId: 2,
          conversionFactor: 12.0,
        ),
        ProductVariant(
          id: 3,
          productId: 101,
          variantName: 'Pack of 6',
          priceCents: 6000,
          costPriceCents: 5000,
          type: VariantType.purchase,
          linkedVariantId: 4,
          conversionFactor: 6.0,
        ),
      ];

      final quantities = [2.0, 3.0]; // 2 boxes, 3 packs
      final costs = [12000, 6000];

      // Act
      final results = service.convertBatch(
        variants: variants,
        quantities: quantities,
        unitCosts: costs,
      );

      // Assert
      expect(results.length, equals(2));
      expect(results[0].convertedQuantity, equals(24.0)); // 2 * 12
      expect(results[0].convertedUnitCostCents, equals(1000)); // 12000 / 12
      expect(results[1].convertedQuantity, equals(18.0)); // 3 * 6
      expect(results[1].convertedUnitCostCents, equals(1000)); // 6000 / 6
    });

    test('batch conversion throws on mismatched array lengths', () {
      // Arrange: Mismatched arrays
      final variants = [
        ProductVariant(
          id: 1,
          productId: 100,
          variantName: 'Box',
          priceCents: 12000,
          costPriceCents: 10000,
          type: VariantType.purchase,
        ),
      ];

      final quantities = [1.0, 2.0]; // Wrong length
      final costs = [1000];

      // Act & Assert
      expect(
        () => service.convertBatch(
          variants: variants,
          quantities: quantities,
          unitCosts: costs,
        ),
        throwsA(isA<VariantConversionException>()),
      );
    });
  });

  group('VariantConversionService - Edge Cases', () {
    test('handles large conversion factors correctly', () {
      // Arrange: Pallet of 1000 units
      final palletVariant = ProductVariant(
        id: 1,
        productId: 100,
        variantName: 'Pallet of 1000',
        priceCents: 100000,
        costPriceCents: 80000,
        type: VariantType.purchase,
        linkedVariantId: 2,
        conversionFactor: 1000.0,
      );

      // Act
      final result = service.convertPurchaseToSales(
        variant: palletVariant,
        quantity: 1.0,
        unitCostCents: 100000,
      );

      // Assert
      expect(result.convertedQuantity, equals(1000.0));
      expect(result.convertedUnitCostCents, equals(100));
    });

    test('handles fractional quantities correctly', () {
      // Arrange
      final variant = ProductVariant(
        id: 1,
        productId: 100,
        variantName: 'Box of 12',
        priceCents: 12000,
        costPriceCents: 10000,
        type: VariantType.purchase,
        linkedVariantId: 2,
        conversionFactor: 12.0,
      );

      // Act: 0.5 boxes
      final result = service.convertPurchaseToSales(
        variant: variant,
        quantity: 0.5,
        unitCostCents: 12000,
      );

      // Assert: Should be 6 units
      expect(result.convertedQuantity, equals(6.0));
    });
  });
}
