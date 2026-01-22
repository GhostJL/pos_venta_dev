import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/customer.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/entities/product_variant.dart';
import 'package:posventa/domain/entities/sale.dart';
import 'package:posventa/domain/entities/sale_item.dart';
import 'package:posventa/domain/entities/sale_item_tax.dart';
import 'package:posventa/domain/entities/sale_payment.dart';
import 'package:posventa/domain/entities/sale_transaction.dart';
import 'package:posventa/domain/entities/tax_rate.dart';
import 'package:posventa/domain/services/printer_service.dart';
import 'package:posventa/data/services/printer_service_impl.dart';
import 'package:posventa/presentation/providers/auth_provider.dart';
import 'package:posventa/presentation/providers/product_provider.dart';
import 'package:posventa/presentation/providers/di/sale_di.dart';
import 'package:posventa/presentation/providers/di/product_di.dart';
import 'package:posventa/presentation/providers/di/inventory_di.dart';
import 'package:posventa/presentation/providers/settings_provider.dart';

import 'package:posventa/presentation/providers/customer_providers.dart';
import 'package:posventa/presentation/providers/notification_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:posventa/core/error/domain_exceptions.dart';
import 'package:posventa/core/error/error_reporter.dart';

import 'package:posventa/presentation/providers/pos_grid_provider.dart';
import 'package:posventa/presentation/providers/paginated_products_provider.dart';
import 'package:posventa/presentation/providers/inventory_providers.dart';

import 'package:posventa/domain/entities/discount.dart';
import 'package:posventa/presentation/providers/di/discount_di.dart';

part 'pos_providers.g.dart';

class POSState {
  final List<SaleItem> cart;
  final Customer? selectedCustomer;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;
  final Sale? lastCompletedSale;

  const POSState({
    this.cart = const [],
    this.selectedCustomer,
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
    this.lastCompletedSale,
  });

  POSState copyWith({
    List<SaleItem>? cart,
    Object? selectedCustomer = _undefined,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    Object? lastCompletedSale = _undefined,
  }) {
    return POSState(
      cart: cart ?? this.cart,
      selectedCustomer: selectedCustomer == _undefined
          ? this.selectedCustomer
          : selectedCustomer as Customer?,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
      lastCompletedSale: lastCompletedSale == _undefined
          ? this.lastCompletedSale
          : lastCompletedSale as Sale?,
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
    // Listen to settings changes to ensure cart reflects current tax settings
    ref.listen(settingsProvider, (previous, next) {
      final prevUseTax = previous?.value?.useTax;
      final nextUseTax = next.value?.useTax;

      if (prevUseTax != nextUseTax && nextUseTax != null) {
        _recalculateTaxes(nextUseTax);
      }
    });
    return const POSState();
  }

  Future<void> _recalculateTaxes(bool useTax) async {
    if (state.cart.isEmpty) return;

    state = state.copyWith(isLoading: true);

    try {
      final newCart = <SaleItem>[];

      for (final item in state.cart) {
        final productRepo = ref.read(productRepositoryProvider);
        final productResult = await productRepo.getProductById(item.productId);
        final product = productResult.getOrElse((_) => null);

        if (product != null) {
          ProductVariant? variant;
          if (item.variantId != null && product.variants != null) {
            try {
              variant = product.variants!.firstWhere(
                (v) => v.id == item.variantId,
              );
            } catch (_) {
              // Variant not found, keep as null
              variant = null;
            }
          }

          final newItem = await _calculateItemAndReturn(
            product: product,
            variant: variant,
            quantity: item.quantity,
            useTax: useTax,
            existingItem: item,
          );
          newCart.add(newItem);
        } else {
          // Fallback: If product/variant not found, keep item as is (or partial update?)
          // Without product, we can't reliably calc tax or discounts.
          newCart.add(item);
        }
      }
      state = state.copyWith(cart: newCart, isLoading: false);
    } catch (e, stackTrace) {
      AppErrorReporter().reportError(
        e,
        stackTrace,
        context: 'POSNotifier - recalculateTaxes',
      );
      state = state.copyWith(isLoading: false);
    }
  }

  Future<String?> addToCart(
    Product product, {
    ProductVariant? variant,
    double quantity = 1.0,
  }) async {
    // Validate stock availability using domain service
    // We need the current cart to calculate total stock needed
    // Check settings
    final settingsAsync = ref.read(settingsProvider);
    final useInventory = settingsAsync.value?.useInventory ?? true;
    final useTax = settingsAsync.value?.useTax ?? true;

    // Validate stock availability using domain service
    // We need the current cart to calculate total stock needed
    // Fetch fresh product data to ensure stock is up to date
    Product productToCheck = product;
    final productRepo = ref.read(productRepositoryProvider);
    final freshProductResult = await productRepo.getProductById(product.id!);
    freshProductResult.fold(
      (failure) {
        // Log error, continue with existing product data as fallback?
        // Or fail? Better to warn but maybe proceed with best effort.
        // For strictness, we might want to fail, but let's use existing.
        AppErrorReporter().reportError(
          failure,
          null,
          context: 'addToCart - refreshProduct',
        );
      },
      (freshProduct) {
        if (freshProduct != null) {
          productToCheck = freshProduct;
        }
      },
    );

    // If variant is provided, we should also try to get the fresh variant from the fresh product
    ProductVariant? variantToCheck = variant;
    if (variant != null && productToCheck.variants != null) {
      try {
        variantToCheck = productToCheck.variants!.firstWhere(
          (v) => v.id == variant.id,
        );
      } catch (_) {
        // Variant might have been deleted? Use old one or fail?
      }
    }

    try {
      await ref
          .read(stockValidatorServiceProvider)
          .validateStock(
            product: productToCheck,
            quantityToAdd: quantity,
            variant: variantToCheck,
            currentCart: state.cart,
            useInventory: useInventory,
          );
    } catch (e) {
      if (e is StockInsufficientException) {
        return e.toString();
      }
      return 'Error al validar stock: $e';
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

      final updatedItem = await _calculateItemAndReturn(
        product: product,
        variant: variant,
        quantity: newQuantity,
        useTax: useTax,
        existingItem: existingItem,
      );

      newCart = List<SaleItem>.from(state.cart);
      newCart[existingIndex] = updatedItem;
    } else {
      // Add new item
      final newItem = await _calculateItemAndReturn(
        product: product,
        variant: variant,
        quantity: quantity,
        useTax: useTax,
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

    // Check settings
    final settingsAsync = ref.read(settingsProvider);
    final useInventory = settingsAsync.value?.useInventory ?? true;
    final useTax = settingsAsync.value?.useTax ?? true;

    final index = state.cart.indexWhere(
      (item) => item.productId == product.id && item.variantId == variant?.id,
    );

    if (index >= 0) {
      final existingItem = state.cart[index];

      // Validate stock if increasing quantity
      if (quantity > existingItem.quantity) {
        final additionalNeeded = quantity - existingItem.quantity;

        try {
          await ref
              .read(stockValidatorServiceProvider)
              .validateStock(
                product: product,
                quantityToAdd: additionalNeeded,
                variant: variant,
                currentCart: state.cart,
                useInventory: useInventory,
              );
        } catch (e) {
          if (e is StockInsufficientException) {
            return e.toString();
          }
          return 'Error al validar stock: $e';
        }
      }

      final updatedItem = await _calculateItemAndReturn(
        product: product,
        variant: variant,
        quantity: quantity,
        useTax: useTax,
        existingItem: existingItem,
      );

      final newCart = List<SaleItem>.from(state.cart);
      newCart[index] = updatedItem;
      state = state.copyWith(cart: newCart);
    } else {
      // Add as new item with specific quantity
      // Validate stock
      try {
        await ref
            .read(stockValidatorServiceProvider)
            .validateStock(
              product: product,
              quantityToAdd: quantity,
              variant: variant,
              currentCart: state.cart,
              useInventory: useInventory,
            );
      } catch (e) {
        if (e is StockInsufficientException) {
          return e.toString();
        }
        return 'Error al validar stock: $e';
      }

      final newItem = await _calculateItemAndReturn(
        product: product,
        variant: variant,
        quantity: quantity,
        useTax: useTax,
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

    // Check settings
    final settingsAsync = ref.read(settingsProvider);
    final useInventory = settingsAsync.value?.useInventory ?? true;
    final useTax = settingsAsync.value?.useTax ?? true;

    final index = state.cart.indexWhere(
      (item) => item.productId == productId && item.variantId == variantId,
    );
    if (index >= 0) {
      final existingItem = state.cart[index];

      // Validate stock if increasing quantity
      if (quantity > existingItem.quantity) {
        final additionalNeeded = quantity - existingItem.quantity;

        try {
          // Fetch fresh product data to ensure stock is up to date
          // The existing code already calls getProductById, but let's ensure we use the result correctly
          final productRepo = ref.read(productRepositoryProvider);
          final productResult = await productRepo.getProductById(productId);

          // Handle Either
          String? errorMessage;
          await productResult.fold(
            (failure) async {
              AppErrorReporter().reportError(
                failure,
                null,
                context: 'updateQuantity - fetchProduct',
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
                  } catch (_) {
                    // Variant might have been deleted, validation will use product stock if variant is null?
                    // Or should we fail?
                  }
                }

                try {
                  await ref
                      .read(stockValidatorServiceProvider)
                      .validateStock(
                        product: product,
                        quantityToAdd: additionalNeeded,
                        variant: variant,
                        currentCart: state.cart,
                        useInventory: useInventory,
                      );
                } catch (e) {
                  if (e is StockInsufficientException) {
                    errorMessage = e.toString();
                  } else {
                    errorMessage = 'Error al validar stock: $e';
                  }
                }
              }
            },
          );

          if (errorMessage != null) {
            return errorMessage;
          }
        } catch (e, stackTrace) {
          AppErrorReporter().reportError(
            e,
            stackTrace,
            context: 'updateQuantity - validation',
          );
        }
      }

      // Fetch product to recalculate prices/discounts
      final productRepo = ref.read(productRepositoryProvider);
      final productRes = await productRepo.getProductById(productId);
      final product = productRes.getOrElse((_) => null);

      SaleItem updatedItem;
      if (product != null) {
        ProductVariant? variant;
        if (variantId != null && product.variants != null) {
          try {
            variant = product.variants!.firstWhere((v) => v.id == variantId);
          } catch (_) {
            // Variant not found, keep as null
            variant = null;
          }
        }
        updatedItem = await _calculateItemAndReturn(
          product: product,
          variant: variant,
          quantity: quantity,
          useTax: useTax,
          existingItem: existingItem,
        );
      } else {
        // Fallback: simple scaling (no discount update)
        final unitPriceCents = existingItem.unitPriceCents;
        final subtotalCents = (unitPriceCents * quantity).round();

        // Helper to recalc tax
        int taxCents = 0;
        final taxes = <SaleItemTax>[];
        if (useTax) {
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
        }
        final totalCents = subtotalCents + taxCents;

        updatedItem = existingItem.copyWith(
          quantity: quantity,
          subtotalCents: subtotalCents,
          taxCents: taxCents,
          totalCents: totalCents,
          taxes: taxes,
        );
      }

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

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      lastCompletedSale: null,
    ); // Reset last sale

    try {
      final user = ref.read(authProvider).user;
      if (user == null) throw Exception('Usuario no autenticado');

      final saleNumber = await ref
          .read(generateNextSaleNumberUseCaseProvider)
          .call();

      // Calculate totals
      int subtotalCents = 0;
      int discountCents = 0;
      int taxCents = 0;
      int totalCents = 0;

      for (var item in state.cart) {
        subtotalCents += item.subtotalCents;
        discountCents += item.discountCents;
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
        discountCents: discountCents,
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

      final createSale = await ref.read(createSaleUseCaseProvider.future);

      // Credit Logic
      if (paymentMethod == 'Crédito') {
        if (state.selectedCustomer == null) {
          throw Exception('Debe seleccionar un cliente para ventas a crédito');
        }

        // Fetch fresh customer data to ensure up-to-date credit usage
        // This prevents bypassing limit if multiple sales are made in session without re-selecting customer
        final customerResult = await ref.read(
          customerByIdProvider(state.selectedCustomer!.id!).future,
        );

        if (customerResult == null) {
          throw Exception('Cliente no encontrado al validar crédito');
        }

        final customer = customerResult;
        final newBalance = customer.creditUsed + (totalCents / 100.0);

        if (customer.creditLimit != null &&
            newBalance > customer.creditLimit!) {
          throw Exception(
            'El cliente excede su límite de crédito. Disponible: \$${(customer.creditLimit! - customer.creditUsed).toStringAsFixed(2)}',
          );
        }

        final update = CreditUpdate(
          customerId: customer.id!,
          amountCents: totalCents,
          isIncrement: true,
        );

        await createSale.call(sale, creditUpdate: update);

        // Invalidate the customer provider to ensure next fetch gets updated credit usage
        ref.invalidate(customerByIdProvider(customer.id!));

        // Update selected customer in state to reflect new balance immediately for UI
        state = state.copyWith(
          selectedCustomer: customer.copyWith(creditUsed: newBalance),
        );
      } else {
        await createSale.call(sale);
      }

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
        } catch (e, stackTrace) {
          AppErrorReporter().reportError(
            e,
            stackTrace,
            context: 'completeSale - recordChange',
          );
        }
      }

      // Explicitly Refresh POS Product Grids to reflect stock changes immediately
      ref.invalidate(posGridItemsProvider);
      ref.invalidate(paginatedProductsPageProvider);

      // Invalidate product list to refresh stock
      ref.invalidate(productListProvider);
      // Invalidate dashboard metrics
      ref.invalidate(todaysRevenueProvider);
      ref.invalidate(todaysTransactionsProvider);
      ref.invalidate(inventoryProvider);

      // Check stock levels and trigger notifications
      // Only runs if Inventory Management is enabled
      final settingsAsync = ref.read(settingsProvider);
      final useInventory = settingsAsync.value?.useInventory ?? true;

      if (useInventory) {
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
        } catch (e, stackTrace) {
          // Silently fail notification checks to not disrupt sale completion
          AppErrorReporter().reportError(
            e,
            stackTrace,
            context: 'completeSale - checkStockLevels',
          );
        }
      }

      state = state.copyWith(
        isLoading: false,
        cart: const [],
        selectedCustomer: null,
        successMessage: 'Venta realizada con éxito: $saleNumber',
        lastCompletedSale: sale,
      );
    } catch (e, stackTrace) {
      AppErrorReporter().reportError(
        e,
        stackTrace,
        context: 'completeSale - main',
      );
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<SaleItem> _calculateItemAndReturn({
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
      final discounts = await ref
          .read(getDiscountsForVariantUseCaseProvider)
          .execute(variant.id!);
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
      final taxesResult = await ref
          .read(productRepositoryProvider)
          .getTaxRatesForProduct(product.id!);
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

final printerServiceProvider = Provider<PrinterService>((ref) {
  return PrinterServiceImpl();
});
