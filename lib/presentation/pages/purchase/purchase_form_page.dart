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
    final productsAsync = ref.read(productNotifierProvider);

    await productsAsync.when(
      data: (products) async {
        // final products = state.products; // Removed
        final product = products
            .where((p) => p.id == item.productId)
            .firstOrNull;

        if (product != null) {
          final variant = item.variantId != null
              ? product.variants
                    ?.where((v) => v.id == item.variantId)
                    .firstOrNull
              : null;

          final warehouseId = ref.read(purchaseFormProvider).warehouse?.id;
          if (warehouseId == null) return;

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
      },
      loading: () {},
      error: (_, __) {},
    );
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

  void _onQuantityChanged(
    int index,
    double quantity,
    Map<int, Product> productMap,
  ) {
    final item = ref.read(purchaseFormProvider).items[index];
    final product = productMap[item.productId];
    if (product != null) {
      ref
          .read(purchaseFormProvider.notifier)
          .updateItemQuantity(index, quantity, product);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    final productsAsync = ref.watch(productNotifierProvider);
    final formState = ref.watch(purchaseFormProvider);

    if (formState.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return productsAsync.when(
      data: (products) {
        // final products = state.products; // Removed
        final productMap = {for (var p in products) p.id!: p};

        if (isMobile) {
          return PurchaseFormMobileLayout(
            formState: formState,
            productMap: productMap,
            onProductSelected: _onProductSelected,
            onEditItem: (index) => _editItem(index, formState.items[index]),
            onRemoveItem: (index) =>
                ref.read(purchaseFormProvider.notifier).removeItem(index),
            onQuantityChanged: (index, quantity) =>
                _onQuantityChanged(index, quantity, productMap),
            onSavePurchase: _savePurchase,
            formKey: _formKey,
          );
        }

        return PurchaseFormDesktopLayout(
          formState: formState,
          productMap: productMap,
          onProductSelected: _onProductSelected,
          onEditItem: (index) => _editItem(index, formState.items[index]),
          onRemoveItem: (index) =>
              ref.read(purchaseFormProvider.notifier).removeItem(index),
          onQuantityChanged: (index, quantity) =>
              _onQuantityChanged(index, quantity, productMap),
          onSavePurchase: _savePurchase,
          formKey: _formKey,
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) =>
          Scaffold(body: Center(child: Text('Error: $error'))),
    );
  }
}
