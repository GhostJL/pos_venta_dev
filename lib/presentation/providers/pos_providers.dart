import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/customer.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/entities/product_variant.dart';
import 'package:posventa/domain/entities/sale.dart';
import 'package:posventa/domain/entities/sale_item.dart';
import 'package:posventa/domain/entities/sale_item_tax.dart';
import 'package:posventa/domain/entities/sale_payment.dart';
import 'package:posventa/domain/entities/tax_rate.dart';
import 'package:posventa/presentation/providers/auth_provider.dart';
import 'package:posventa/presentation/providers/product_provider.dart';
import 'package:posventa/presentation/providers/di/sale_di.dart';
import 'package:posventa/presentation/providers/di/product_di.dart';
import 'package:posventa/presentation/providers/di/inventory_di.dart';

import 'package:posventa/presentation/providers/notification_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pos_providers.g.dart';

class POSState {
  final List<SaleItem> cart;
  final Customer? selectedCustomer;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  const POSState({
    this.cart = const [],
    this.selectedCustomer,
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  POSState copyWith({
    List<SaleItem>? cart,
    Object? selectedCustomer = _undefined,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
  }) {
    return POSState(
      cart: cart ?? this.cart,
      selectedCustomer: selectedCustomer == _undefined
          ? this.selectedCustomer
          : selectedCustomer as Customer?,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  // Getters for totals (converting from cents to dollars)
  double get subtotal =>
      cart.fold(0.0, (sum, item) => sum + (item.subtotalCents / 100));
  double get tax => cart.fold(0.0, (sum, item) => sum + (item.taxCents / 100));
  double get discount =>
      cart.fold(0.0, (sum, item) => sum + (item.discountCents / 100));
  double get total =>
      cart.fold(0.0, (sum, item) => sum + (item.totalCents / 100));
}

// Sentinel value for copyWith
const Object _undefined = Object();

@Riverpod(keepAlive: true)
class POSNotifier extends _$POSNotifier {
  @override
  POSState build() {
    return const POSState();
  }

  Future<String?> addToCart(
    Product product, {
    ProductVariant? variant,
    double quantity = 1.0,
  }) async {
    // Validate stock availability using domain service
    // We need the current cart to calculate total stock needed
    final stockError = await ref
        .read(stockValidatorServiceProvider)
        .validateStock(
          product: product,
          quantityToAdd: quantity,
          variant: variant,
          currentCart: state.cart,
        );

    if (stockError != null) {
      return stockError;
    }

    // Check if product (and variant) already in cart
    final existingIndex = state.cart.indexWhere(
      (item) => item.productId == product.id && item.variantId == variant?.id,
    );

    List<SaleItem> newCart;
    if (existingIndex >= 0) {
      // Update quantity
      final existingItem = state.cart[existingIndex];
      final newQuantity = existingItem.quantity + quantity;

      // Recalculate totals for item
      // Use existing item's unit price to respect variant price
      final unitPriceCents = existingItem.unitPriceCents;
      final subtotalCents = (unitPriceCents * newQuantity).round();

      int taxCents = 0;
      final taxes = <SaleItemTax>[];
      for (final tax in existingItem.taxes) {
        final taxAmount = (subtotalCents * tax.taxRate).round();
        taxCents += taxAmount;
        taxes.add(
          SaleItemTax(
            taxRateId: tax.taxRateId,
            taxName: tax.taxName,
            taxRate: tax.taxRate,
            taxAmountCents: taxAmount,
          ),
        );
      }

      final totalCents = subtotalCents + taxCents;

      final updatedItem = SaleItem(
        id: existingItem.id,
        productId: product.id!,
        variantId: variant?.id,
        quantity: newQuantity,
        unitOfMeasure: product.unitOfMeasure,
        unitPriceCents: unitPriceCents,
        subtotalCents: subtotalCents,
        taxCents: taxCents,
        totalCents: totalCents,
        costPriceCents: existingItem.costPriceCents,
        productName: existingItem.productName,
        variantDescription: existingItem.variantDescription,
        taxes: taxes,
        unitsPerPack: existingItem.unitsPerPack,
      );

      newCart = List<SaleItem>.from(state.cart);
      newCart[existingIndex] = updatedItem;
    } else {
      // Add new item
      // Fetch taxes
      final productRepository = ref.read(productRepositoryProvider);

      // Handle Either return type
      final taxesResult = await productRepository.getTaxRatesForProduct(
        product.id!,
      );

      final productTaxes = taxesResult.fold(
        (failure) => <TaxRate>[], // Fallback to empty taxes on error
        (rates) => rates,
      );

      final unitPriceCents = variant != null
          ? variant.priceCents
          : (product.price * 100).round();
      final costPriceCents = variant != null
          ? variant.costPriceCents
          : (product.costPrice * 100).round();
      final productName = product.name;
      final variantDescription = variant?.description;
      // final quantity = 1.0; // REMOVED: Use argument quantity
      final subtotalCents = (unitPriceCents * quantity).round();

      int taxCents = 0;
      final taxes = <SaleItemTax>[];
      for (final tax in productTaxes) {
        final taxAmount = (subtotalCents * tax.rate).round();
        taxCents += taxAmount;
        taxes.add(
          SaleItemTax(
            taxRateId: tax.id!,
            taxName: tax.name,
            taxRate: tax.rate,
            taxAmountCents: taxAmount,
          ),
        );
      }

      final totalCents = subtotalCents + taxCents;

      final newItem = SaleItem(
        productId: product.id!,
        variantId: variant?.id,
        quantity: quantity,
        unitOfMeasure: product.unitOfMeasure,
        unitPriceCents: unitPriceCents,
        subtotalCents: subtotalCents,
        taxCents: taxCents,
        totalCents: totalCents,
        costPriceCents: costPriceCents,
        productName: productName,
        variantDescription: variantDescription,
        taxes: taxes,
        unitsPerPack: variant?.quantity ?? 1.0,
      );

      newCart = [...state.cart, newItem];
    }

    state = state.copyWith(cart: newCart);
    return null; // Success
  }

  void removeFromCart(int productId, {int? variantId}) {
    final newCart = state.cart.where((item) {
      if (item.productId != productId) return true;
      // If productId matches, check variantId
      return item.variantId != variantId;
    }).toList();
    state = state.copyWith(cart: newCart);
  }

  Future<String?> setQuantity(
    Product product,
    double quantity, {
    ProductVariant? variant,
  }) async {
    if (quantity <= 0) {
      removeFromCart(product.id!, variantId: variant?.id);
      return null;
    }

    final index = state.cart.indexWhere(
      (item) => item.productId == product.id && item.variantId == variant?.id,
    );

    if (index >= 0) {
      final existingItem = state.cart[index];

      // Validate stock if increasing quantity
      if (quantity > existingItem.quantity) {
        final additionalNeeded = quantity - existingItem.quantity;

        final stockError = await ref
            .read(stockValidatorServiceProvider)
            .validateStock(
              product: product,
              quantityToAdd: additionalNeeded,
              variant: variant,
              currentCart: state.cart,
            );

        if (stockError != null) {
          return stockError;
        }
      }

      final unitPriceCents = existingItem.unitPriceCents;
      final subtotalCents = (unitPriceCents * quantity).round();

      int taxCents = 0;
      final taxes = <SaleItemTax>[];
      for (final tax in existingItem.taxes) {
        final taxAmount = (subtotalCents * tax.taxRate).round();
        taxCents += taxAmount;
        taxes.add(
          SaleItemTax(
            taxRateId: tax.taxRateId,
            taxName: tax.taxName,
            taxRate: tax.taxRate,
            taxAmountCents: taxAmount,
          ),
        );
      }

      final totalCents = subtotalCents + taxCents;

      final updatedItem = SaleItem(
        id: existingItem.id,
        productId: existingItem.productId,
        variantId: existingItem.variantId, // KEEP VARIANT ID
        quantity: quantity,
        unitOfMeasure: existingItem.unitOfMeasure,
        unitPriceCents: unitPriceCents,
        subtotalCents: subtotalCents,
        taxCents: taxCents,
        totalCents: totalCents,
        costPriceCents: existingItem.costPriceCents,
        productName: existingItem.productName,
        variantDescription: existingItem.variantDescription,
        taxes: taxes,
        unitsPerPack: existingItem.unitsPerPack,
      );

      final newCart = List<SaleItem>.from(state.cart);
      newCart[index] = updatedItem;
      state = state.copyWith(cart: newCart);
    } else {
      // Add as new item with specific quantity
      // Validate stock
      final stockError = await ref
          .read(stockValidatorServiceProvider)
          .validateStock(
            product: product,
            quantityToAdd: quantity,
            variant: variant,
            currentCart: state.cart,
          );

      if (stockError != null) {
        return stockError;
      }

      // Fetch taxes
      final productRepository = ref.read(productRepositoryProvider);
      final taxesResult = await productRepository.getTaxRatesForProduct(
        product.id!,
      );
      final productTaxes = taxesResult.fold((l) => <TaxRate>[], (r) => r);

      final unitPriceCents = variant != null
          ? variant.priceCents
          : (product.price * 100).round();
      final costPriceCents = variant != null
          ? variant.costPriceCents
          : (product.costPrice * 100).round();

      final subtotalCents = (unitPriceCents * quantity).round();

      int taxCents = 0;
      final taxes = <SaleItemTax>[];
      for (final tax in productTaxes) {
        final taxAmount = (subtotalCents * tax.rate).round();
        taxCents += taxAmount;
        taxes.add(
          SaleItemTax(
            taxRateId: tax.id!,
            taxName: tax.name,
            taxRate: tax.rate,
            taxAmountCents: taxAmount,
          ),
        );
      }

      final totalCents = subtotalCents + taxCents;

      final newItem = SaleItem(
        productId: product.id!,
        variantId: variant?.id,
        quantity: quantity,
        unitOfMeasure: product.unitOfMeasure,
        unitPriceCents: unitPriceCents,
        subtotalCents: subtotalCents,
        taxCents: taxCents,
        totalCents: totalCents,
        costPriceCents: costPriceCents,
        productName: product.name,
        variantDescription: variant?.description,
        taxes: taxes,
        unitsPerPack: variant?.quantity ?? 1.0,
      );

      state = state.copyWith(cart: [...state.cart, newItem]);
    }
    return null;
  }

  Future<String?> updateQuantity(
    int productId,
    double quantity, {
    int? variantId,
  }) async {
    if (quantity <= 0) {
      removeFromCart(productId, variantId: variantId);
      return null;
    }

    final index = state.cart.indexWhere(
      (item) => item.productId == productId && item.variantId == variantId,
    );
    if (index >= 0) {
      final existingItem = state.cart[index];

      // Validate stock if increasing quantity
      if (quantity > existingItem.quantity) {
        final additionalNeeded = quantity - existingItem.quantity;

        try {
          final productRepo = ref.read(productRepositoryProvider);
          final productResult = await productRepo.getProductById(productId);

          // Handle Either
          await productResult.fold(
            (failure) async {
              debugPrint(
                'Error validating stock inside updateQuantity: ${failure.message}',
              );
            },
            (product) async {
              if (product != null) {
                ProductVariant? variant;
                if (variantId != null && product.variants != null) {
                  try {
                    variant = product.variants!.firstWhere(
                      (v) => v.id == variantId,
                    );
                  } catch (_) {}
                }

                final stockError = await ref
                    .read(stockValidatorServiceProvider)
                    .validateStock(
                      product: product,
                      quantityToAdd: additionalNeeded,
                      variant: variant,
                      currentCart: state.cart,
                    );

                if (stockError != null) {
                  // ignore: curly_braces_in_flow_control_structures
                  return stockError; // This return is technically void because of async closure
                }
              }
            },
          );

          if (productResult.isRight()) {
            final product = productResult.getRight().toNullable();
            if (product != null) {
              ProductVariant? variant;
              if (variantId != null && product.variants != null) {
                try {
                  variant = product.variants!.firstWhere(
                    (v) => v.id == variantId,
                  );
                } catch (_) {}
              }

              final stockError = await ref
                  .read(stockValidatorServiceProvider)
                  .validateStock(
                    product: product,
                    quantityToAdd: additionalNeeded,
                    variant: variant,
                    currentCart: state.cart,
                  );
              if (stockError != null) return stockError;
            }
          }
        } catch (e) {
          debugPrint('Error validating stock in updateQuantity: $e');
        }
      }

      final unitPriceCents = existingItem.unitPriceCents;
      final subtotalCents = (unitPriceCents * quantity).round();

      int taxCents = 0;
      final taxes = <SaleItemTax>[];
      for (final tax in existingItem.taxes) {
        final taxAmount = (subtotalCents * tax.taxRate).round();
        taxCents += taxAmount;
        taxes.add(
          SaleItemTax(
            taxRateId: tax.taxRateId,
            taxName: tax.taxName,
            taxRate: tax.taxRate,
            taxAmountCents: taxAmount,
          ),
        );
      }

      final totalCents = subtotalCents + taxCents;

      final updatedItem = SaleItem(
        id: existingItem.id,
        productId: existingItem.productId,
        variantId: existingItem.variantId,
        quantity: quantity,
        unitOfMeasure: existingItem.unitOfMeasure,
        unitPriceCents: unitPriceCents,
        subtotalCents: subtotalCents,
        taxCents: taxCents,
        totalCents: totalCents,
        costPriceCents: existingItem.costPriceCents,
        productName: existingItem.productName,
        variantDescription: existingItem.variantDescription,
        taxes: taxes,
        unitsPerPack: existingItem.unitsPerPack,
      );

      final newCart = List<SaleItem>.from(state.cart);
      newCart[index] = updatedItem;
      state = state.copyWith(cart: newCart);
    }
    return null;
  }

  void selectCustomer(Customer? customer) {
    state = state.copyWith(selectedCustomer: customer);
  }

  void clearCart() {
    state = state.copyWith(cart: const [], selectedCustomer: null);
  }

  Future<void> completeSale(String paymentMethod, double amountPaid) async {
    if (state.cart.isEmpty) {
      state = state.copyWith(errorMessage: 'El carrito está vacío');
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final user = ref.read(authProvider).user;
      if (user == null) throw Exception('Usuario no autenticado');

      final saleNumber = await ref
          .read(generateNextSaleNumberUseCaseProvider)
          .call();

      // Calculate totals
      int subtotalCents = 0;
      int taxCents = 0;
      int totalCents = 0;

      for (var item in state.cart) {
        subtotalCents += item.subtotalCents;
        taxCents += item.taxCents;
        totalCents += item.totalCents;
      }

      // Get warehouse from active session
      int warehouseId = 1; // Default fallback
      try {
        final currentSession = await ref.read(getCurrentSessionProvider).call();
        if (currentSession != null) {
          warehouseId = currentSession.warehouseId;
        }
      } catch (_) {
        // If fetching session fails (e.g. no user), keep default
      }

      final sale = Sale(
        saleNumber: saleNumber,
        warehouseId: warehouseId,
        customerId: state.selectedCustomer?.id,
        cashierId: user.id!,
        subtotalCents: subtotalCents,
        taxCents: taxCents,
        totalCents: totalCents,
        saleDate: DateTime.now(),
        createdAt: DateTime.now(),
        items: state.cart,
        payments: [
          SalePayment(
            paymentMethod: paymentMethod,
            amountCents: (amountPaid * 100).round(),
            paymentDate: DateTime.now(),
            receivedBy: user.id!,
          ),
        ],
      );

      await ref.read(createSaleUseCaseProvider).call(sale);

      // Record change as a cash movement if applicable
      final change = amountPaid - (totalCents / 100.0);
      if (change > 0) {
        try {
          final currentSession = await ref
              .read(getCurrentSessionProvider)
              .call();
          if (currentSession != null) {
            await ref
                .read(createCashMovementUseCaseProvider)
                .call(
                  currentSession.id!,
                  'withdrawal',
                  (change * 100).round(),
                  'Cambio',
                  description: 'Cambio Venta #$saleNumber',
                );
          }
        } catch (e) {
          debugPrint('Error recording change movement: $e');
        }
      }

      // Invalidate product list to refresh stock
      ref.invalidate(productListProvider);
      // Invalidate dashboard metrics
      ref.invalidate(todaysRevenueProvider);
      ref.invalidate(todaysTransactionsProvider);

      // Check stock levels and trigger notifications
      try {
        final notificationService = ref.read(notificationServiceProvider);
        final productRepository = ref.read(productRepositoryProvider);

        for (final item in state.cart) {
          if (item.variantId != null) {
            // Fetch fresh product/variant data
            final productResult = await productRepository.getProductById(
              item.productId,
            );

            productResult.fold((failure) => null, (product) async {
              if (product != null) {
                final variant = product.variants?.firstWhere(
                  (v) => v.id == item.variantId,
                  orElse: () => throw Exception('Variant not found'),
                );

                if (variant != null) {
                  // Determine stock. If getProductById populates it, use it.
                  // Otherwise we might need to fetch it specifically.
                  // Assuming variant.stock is populated (as per implementation plan review).
                  await notificationService.checkStockLevel(
                    variant: variant,
                    productName: product.name,
                    currentStock: variant.stock ?? 0,
                  );
                }
              }
            });
          }
        }
      } catch (e) {
        // Silently fail notification checks to not disrupt sale completion
        debugPrint('Error checking stock levels: $e');
      }

      state = state.copyWith(
        isLoading: false,
        cart: const [],
        selectedCustomer: null,
        successMessage: 'Venta realizada con éxito: $saleNumber',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}

final posTaxBreakdownProvider = Provider<Map<String, double>>((ref) {
  final cart = ref.watch(pOSProvider.select((s) => s.cart));
  final Map<String, double> taxBreakdown = {};
  for (var item in cart) {
    for (var tax in item.taxes) {
      final key = '${tax.taxName} (${(tax.taxRate * 100).toStringAsFixed(0)}%)';
      taxBreakdown[key] = (taxBreakdown[key] ?? 0) + (tax.taxAmountCents / 100);
    }
  }
  return taxBreakdown;
});

@Riverpod(keepAlive: true)
Future<List<TaxRate>> allTaxRates(Ref ref) async {
  final getAllTaxRates = ref.read(getAllTaxRatesUseCaseProvider);
  return await getAllTaxRates.call();
}

/// Provides a Map of TaxRates keyed by ID for O(1) lookup
final taxRatesMapProvider = Provider<Map<int, TaxRate>>((ref) {
  final ratesAsync = ref.watch(allTaxRatesProvider);
  return ratesAsync.maybeWhen(
    data: (rates) => {for (var rate in rates) rate.id!: rate},
    orElse: () => const {},
  );
});
