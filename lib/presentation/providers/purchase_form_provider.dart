import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/entities/product_variant.dart';
import 'package:posventa/domain/entities/purchase.dart';
import 'package:posventa/domain/entities/purchase_item.dart';
import 'package:posventa/domain/entities/supplier.dart';
import 'package:posventa/domain/entities/warehouse.dart';
import 'package:posventa/presentation/providers/auth_provider.dart';
import 'package:posventa/presentation/providers/purchase_providers.dart';
import 'package:posventa/presentation/providers/purchase_item_providers.dart';
import 'package:posventa/core/utils/purchase_calculations.dart';
import 'package:uuid/uuid.dart';

part 'purchase_form_provider.g.dart';

// --- Purchase Form State ---

class PurchaseFormState {
  final Supplier? supplier;
  final Warehouse? warehouse;
  final String invoiceNumber;
  final DateTime? purchaseDate;
  final List<PurchaseItem> items;
  final bool isLoading;
  final String? error;

  const PurchaseFormState({
    this.supplier,
    this.warehouse,
    this.invoiceNumber = '',
    this.purchaseDate,
    this.items = const [],
    this.isLoading = false,
    this.error,
  });

  PurchaseFormState copyWith({
    Supplier? supplier,
    Warehouse? warehouse,
    String? invoiceNumber,
    DateTime? purchaseDate,
    List<PurchaseItem>? items,
    bool? isLoading,
    String? error,
  }) {
    return PurchaseFormState(
      supplier: supplier ?? this.supplier,
      warehouse: warehouse ?? this.warehouse,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error:
          error, // Nullable, so if not passed, it remains null (or we can clear it)
    );
  }

  // Computed totals
  double get subtotal => items.fold(0, (sum, item) => sum + item.subtotal);
  double get tax => items.fold(0, (sum, item) => sum + item.tax);
  double get total => items.fold(0, (sum, item) => sum + item.total);
}

@riverpod
class PurchaseFormNotifier extends _$PurchaseFormNotifier {
  @override
  PurchaseFormState build() {
    return const PurchaseFormState(
      purchaseDate: null,
    ); // Initialize with defaults
  }

  void initialize({
    required Supplier supplier,
    required Warehouse warehouse,
    required String invoiceNumber,
    required DateTime purchaseDate,
  }) {
    state = state.copyWith(
      supplier: supplier,
      warehouse: warehouse,
      invoiceNumber: invoiceNumber,
      purchaseDate: purchaseDate,
    );
  }

  void addItemDirectly(Product product, ProductVariant? variant) {
    final currentItems = List<PurchaseItem>.from(state.items);

    // Determine quantity to add (default 1, or variant multiplier)
    final double quantityToAdd = variant?.quantity ?? 1.0;

    final double unitCost;
    if (variant != null) {
      // Calculate unit cost from pack cost
      unitCost = (variant.costPriceCents / 100) / quantityToAdd;
    } else {
      unitCost = product.costPriceCents / 100;
    }

    // Check if item already exists
    final existingIndex = currentItems.indexWhere(
      (item) => item.productId == product.id && item.variantId == variant?.id,
    );

    if (existingIndex != -1) {
      // Update existing item
      final existingItem = currentItems[existingIndex];
      final newQuantity = existingItem.quantity + quantityToAdd;

      final updatedItem = PurchaseCalculations.createPurchaseItem(
        product: product,
        quantity: newQuantity,
        unitCost: unitCost,
        existingItem: existingItem,
        variant: variant,
      );

      currentItems[existingIndex] = updatedItem;
    } else {
      // Add new item
      final newItem = PurchaseCalculations.createPurchaseItem(
        product: product,
        quantity: quantityToAdd,
        unitCost: unitCost,
        variant: variant,
      );

      currentItems.add(newItem);
    }

    state = state.copyWith(items: currentItems);
  }

  void updateItem(int index, PurchaseItem updatedItem) {
    final currentItems = List<PurchaseItem>.from(state.items);
    if (index >= 0 && index < currentItems.length) {
      currentItems[index] = updatedItem;
      state = state.copyWith(items: currentItems);
    }
  }

  void removeItem(int index) {
    final currentItems = List<PurchaseItem>.from(state.items);
    if (index >= 0 && index < currentItems.length) {
      currentItems.removeAt(index);
      state = state.copyWith(items: currentItems);
    }
  }

  void updateItemQuantity(int index, double newQuantity, Product product) {
    if (newQuantity <= 0) return;

    final currentItems = List<PurchaseItem>.from(state.items);
    if (index >= 0 && index < currentItems.length) {
      final item = currentItems[index];

      final updatedItem = PurchaseCalculations.createPurchaseItem(
        product: product,
        quantity: newQuantity,
        unitCost: item.unitCost, // Keep current unit cost
        existingItem: item,
      );

      currentItems[index] = updatedItem;
      state = state.copyWith(items: currentItems);
    }
  }

  Future<bool> savePurchase() async {
    if (state.items.isEmpty) {
      state = state.copyWith(error: 'Agregue al menos un producto');
      return false;
    }

    if (state.supplier == null || state.warehouse == null) {
      state = state.copyWith(error: 'Faltan datos de cabecera');
      return false;
    }

    final user = ref.read(authProvider).user;
    if (user == null) {
      state = state.copyWith(error: 'Usuario no autenticado');
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);

    final purchase = Purchase(
      purchaseNumber: 'PUR-${const Uuid().v4().substring(0, 8).toUpperCase()}',
      supplierId: state.supplier!.id!,
      warehouseId: state.warehouse!.id!,
      subtotalCents: (state.subtotal * 100).round(),
      taxCents: (state.tax * 100).round(),
      totalCents: (state.total * 100).round(),
      purchaseDate: state.purchaseDate ?? DateTime.now(),
      supplierInvoiceNumber: state.invoiceNumber.isNotEmpty
          ? state.invoiceNumber
          : null,
      requestedBy: user.id!,
      createdAt: DateTime.now(),
      items: state.items,
      status: PurchaseStatus.pending,
    );

    try {
      await ref.read(purchaseProvider.notifier).addPurchase(purchase);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Error al guardar: $e');
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// --- Purchase Item Form State (for the dialog/page) ---

class PurchaseItemFormState {
  final bool isLoading;
  final String? error;

  const PurchaseItemFormState({this.isLoading = false, this.error});
}

@riverpod
class PurchaseItemFormNotifier extends _$PurchaseItemFormNotifier {
  @override
  PurchaseItemFormState build() {
    return const PurchaseItemFormState();
  }

  // This notifier is simpler because most logic is local to the form or handled by the parent PurchaseFormNotifier
  // But if we want to save directly to DB (like in PurchaseItemFormPage which seems to support standalone item editing),
  // we need logic here.

  // Based on the existing code, PurchaseItemFormPage can edit an existing item (DB) OR create a new one.
  // However, in the context of creating a NEW purchase, items are just in memory.
  // The existing PurchaseItemFormPage seems to be used for BOTH:
  // 1. Editing an item of an EXISTING purchase (persisted in DB).
  // 2. Creating a new item for an EXISTING purchase.

  // The PurchaseFormPage uses PurchaseItemDialog for in-memory items.

  // Let's implement the logic for the "Standalone" item form (persisted).

  Future<bool> saveItem({
    required int? itemId,
    required int? purchaseId,
    required Product product,
    required ProductVariant? variant,
    required double quantity,
    required double unitCost,
    required DateTime? expirationDate,
  }) async {
    state = const PurchaseItemFormState(isLoading: true);

    try {
      final unitCostCents = (unitCost * 100).round();
      final subtotalCents = (unitCostCents * quantity).round();
      const taxCents = 0;
      final totalCents = subtotalCents + taxCents;

      final item = PurchaseItem(
        id: itemId,
        purchaseId: purchaseId,
        productId: product.id!,
        variantId: variant?.id,
        productName: product.name,
        quantity: quantity,
        unitOfMeasure: product.unitOfMeasure,
        unitCostCents: unitCostCents,
        subtotalCents: subtotalCents,
        taxCents: taxCents,
        totalCents: totalCents,
        expirationDate: expirationDate,
        createdAt: DateTime.now(),
      );

      if (itemId == null) {
        // Create new item
        await ref.read(purchaseItemProvider.notifier).addPurchaseItem(item);
      } else {
        // Update existing item
        await ref.read(purchaseItemProvider.notifier).updatePurchaseItem(item);
      }

      state = const PurchaseItemFormState(isLoading: false);
      return true;
    } catch (e) {
      state = PurchaseItemFormState(isLoading: false, error: e.toString());
      return false;
    }
  }
}
