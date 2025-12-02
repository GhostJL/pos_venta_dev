import 'package:posventa/domain/entities/customer.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/entities/product_variant.dart';
import 'package:posventa/domain/entities/sale.dart';
import 'package:posventa/domain/entities/sale_item.dart';
import 'package:posventa/domain/entities/sale_item_tax.dart';
import 'package:posventa/domain/entities/sale_payment.dart';
import 'package:posventa/presentation/providers/auth_provider.dart';
import 'package:posventa/presentation/providers/product_provider.dart';
import 'package:posventa/presentation/providers/providers.dart';
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

  Future<String?> addToCart(Product product, {ProductVariant? variant}) async {
    // Calculate quantity multiplier (how much stock to deduct per unit sold)
    final quantityMultiplier = variant?.quantity ?? 1.0;

    // Validate stock availability
    final stockError = await _validateStock(
      product.id!,
      1.0 * quantityMultiplier,
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
      final newQuantity = existingItem.quantity + 1;

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
        taxes: taxes,
        unitsPerPack: existingItem.unitsPerPack,
      );

      newCart = List<SaleItem>.from(state.cart);
      newCart[existingIndex] = updatedItem;
    } else {
      // Add new item
      // Fetch taxes
      final productRepository = ref.read(productRepositoryProvider);
      final productTaxes = await productRepository.getTaxRatesForProduct(
        product.id!,
      );

      final unitPriceCents = variant != null
          ? variant.priceCents
          : (product.price * 100).round();
      final costPriceCents = variant != null
          ? variant.costPriceCents
          : (product.costPrice * 100).round();
      final productName = variant != null
          ? '${product.name} (${variant.description})'
          : product.name;

      final quantity = 1.0;
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
        taxes: taxes,
        unitsPerPack: variant?.quantity ?? 1.0,
      );

      newCart = [...state.cart, newItem];
    }

    state = state.copyWith(cart: newCart);
    return null; // Success
  }

  /// Validates if there's enough stock for the requested quantity
  /// Returns error message if insufficient stock, null if OK
  Future<String?> _validateStock(
    int productId,
    double additionalQuantity,
  ) async {
    try {
      // Get current warehouse from active session
      final currentSession = await ref.read(getCurrentSessionProvider).call();
      if (currentSession == null) {
        return 'No hay sesión de caja activa';
      }

      // Get inventory for this product in current warehouse
      final inventories = await ref
          .read(getInventoryByProductProvider)
          .call(productId);

      final inventory = inventories.firstWhere(
        (inv) => inv.warehouseId == currentSession.warehouseId,
        orElse: () => throw Exception('No inventory'),
      );

      // Calculate total quantity needed (existing in cart + new)
      final currentStockInCart = state.cart
          .where((item) => item.productId == productId)
          .fold(0.0, (sum, item) => sum + (item.quantity * item.unitsPerPack));

      final totalNeeded = currentStockInCart + additionalQuantity;

      // Check if enough stock
      if (inventory.quantityOnHand < totalNeeded) {
        return 'Stock insuficiente (disponible: ${inventory.quantityOnHand.toStringAsFixed(0)})';
      }

      return null; // Stock OK
    } catch (e) {
      return 'Producto sin inventario registrado';
    }
  }

  void removeFromCart(int productId) {
    final newCart = state.cart
        .where((item) => item.productId != productId)
        .toList();
    state = state.copyWith(cart: newCart);
  }

  Future<String?> updateQuantity(int productId, double quantity) async {
    if (quantity <= 0) {
      removeFromCart(productId);
      return null;
    }

    final index = state.cart.indexWhere((item) => item.productId == productId);
    if (index >= 0) {
      final existingItem = state.cart[index];

      // Validate stock if increasing quantity
      if (quantity > existingItem.quantity) {
        final additionalNeeded =
            (quantity - existingItem.quantity) * existingItem.unitsPerPack;
        final stockError = await _validateStock(productId, additionalNeeded);
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
        quantity: quantity,
        unitOfMeasure: existingItem.unitOfMeasure,
        unitPriceCents: unitPriceCents,
        subtotalCents: subtotalCents,
        taxCents: taxCents,
        totalCents: totalCents,
        costPriceCents: existingItem.costPriceCents,
        productName: existingItem.productName,
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

      // Invalidate product list to refresh stock
      ref.invalidate(productListProvider);

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
