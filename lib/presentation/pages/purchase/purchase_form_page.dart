import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/entities/product_variant.dart';
import 'package:posventa/domain/entities/purchase_item.dart';
import 'package:posventa/domain/entities/supplier.dart';
import 'package:posventa/domain/entities/warehouse.dart';
import 'package:posventa/presentation/providers/product_provider.dart';
import 'package:posventa/presentation/providers/purchase_form_provider.dart';
import 'package:posventa/presentation/widgets/purchases/dialogs/purchase_item_dialog.dart';
import 'package:posventa/presentation/widgets/purchases/forms/purchase_form/purchase_form_mobile_layout.dart';
import 'package:posventa/presentation/widgets/purchases/forms/purchase_form/purchase_form_desktop_layout.dart';

class PurchaseFormPage extends ConsumerStatefulWidget {
  final Map<String, dynamic>? headerData;

  const PurchaseFormPage({super.key, this.headerData});

  @override
  ConsumerState<PurchaseFormPage> createState() => _PurchaseFormPageState();
}

class _PurchaseFormPageState extends ConsumerState<PurchaseFormPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.headerData != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(purchaseFormProvider.notifier)
            .initialize(
              supplier: widget.headerData!['supplier'] as Supplier,
              warehouse: widget.headerData!['warehouse'] as Warehouse,
              invoiceNumber: widget.headerData!['invoiceNumber'] as String,
              purchaseDate: widget.headerData!['purchaseDate'] as DateTime,
            );
      });
    }
  }

  Future<void> _editItem(int index, PurchaseItem item) async {
    // Determine product via provider check or reuse
    // Since we don't hold the full list, we request it by ID via productProvider
    // Using `ref.read` on a future provider?

    // We can't synchronously get it if not loaded.
    // But `_editItem` is async.

    try {
      final product = await ref.read(productProvider(item.productId).future);
      if (product != null) {
        final variant = item.variantId != null
            ? product.variants?.where((v) => v.id == item.variantId).firstOrNull
            : null;

        final warehouseId = ref.read(purchaseFormProvider).warehouse?.id;
        if (warehouseId == null) return;

        if (!mounted) return;

        final result = await showDialog<PurchaseItem>(
          context: context,
          builder: (context) => PurchaseItemDialog(
            warehouseId: warehouseId,
            existingItem: item,
            product: product,
            variant: variant,
          ),
        );

        if (result != null) {
          ref.read(purchaseFormProvider.notifier).updateItem(index, result);
        }
      }
    } catch (_) {
      // Handle error if product load fails or network error
      if (mounted) _showSnackBar('Error cargando producto para edición');
    }
  }

  Future<void> _savePurchase() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref
        .read(purchaseFormProvider.notifier)
        .savePurchase();

    if (success && mounted) {
      context.go('/purchases');
      _showSnackBar('Compra registrada exitosamente');
    } else {
      final error = ref.read(purchaseFormProvider).error;
      if (error != null && mounted) {
        _showSnackBar(error);
        ref.read(purchaseFormProvider.notifier).clearError();
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _onProductSelected(Product product, ProductVariant? variant) {
    ref.read(purchaseFormProvider.notifier).addItemDirectly(product, variant);
    _showSnackBar(
      'Agregado: ${product.name} ${variant != null ? '(${variant.description})' : ''}',
    );
  }

  Future<void> _onQuantityChanged(int index, double quantity) async {
    final item = ref.read(purchaseFormProvider).items[index];
    // Fetch product to ensure valid update or just pass product stub if we only need basic info?
    // updateItemQuantity usages `product` to recalculate costs if unit cost changes?
    // Actually `PurchaseFormNotifier.updateItemQuantity` uses `product` to Re-calculate defaults?
    // checking `PurchaseFormNotifier`:
    // updateItemQuantity(index, newQty, product) -> calls PurchaseCalculations.createPurchaseItem...
    // which effectively just updates totals. It optionally updates unitCost if default logic applies.
    // If we only change quantity, we might not strictly need the full product re-fetch if we trust `item.unitCost`.
    // BUT `updateItemQuantity` signature requires `Product`.

    // So we fetch it.
    try {
      final product = await ref.read(productProvider(item.productId).future);
      if (product != null) {
        ref
            .read(purchaseFormProvider.notifier)
            .updateItemQuantity(index, quantity, product);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    // Removed ref.watch(productNotifierProvider) to avoid full rebuilds on search
    final formState = ref.watch(purchaseFormProvider);

    if (formState.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (isMobile) {
      return PurchaseFormMobileLayout(
        formState: formState,
        onProductSelected: _onProductSelected,
        onEditItem: (index) => _editItem(index, formState.items[index]),
        onRemoveItem: (index) =>
            ref.read(purchaseFormProvider.notifier).removeItem(index),
        onQuantityChanged: _onQuantityChanged,
        onSavePurchase: _savePurchase,
        formKey: _formKey,
      );
    }

    return PurchaseFormDesktopLayout(
      formState: formState,
      onProductSelected: _onProductSelected,
      onEditItem: (index) => _editItem(index, formState.items[index]),
      onRemoveItem: (index) =>
          ref.read(purchaseFormProvider.notifier).removeItem(index),
      onQuantityChanged: _onQuantityChanged,
      onSavePurchase: _savePurchase,
      formKey: _formKey,
    );
  }
}
