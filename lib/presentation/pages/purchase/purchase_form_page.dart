import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/entities/purchase_item.dart';
import 'package:posventa/domain/entities/supplier.dart';
import 'package:posventa/domain/entities/warehouse.dart';
import 'package:posventa/presentation/providers/product_provider.dart';
import 'package:posventa/presentation/providers/purchase_form_provider.dart';
import 'package:posventa/presentation/widgets/purchase/purchase_product_grid.dart';
import 'package:posventa/presentation/widgets/purchase/purchase_header_card.dart';
import 'package:posventa/presentation/widgets/purchase/purchase_item_dialog.dart';
import 'package:posventa/presentation/widgets/purchase/purchase_items_list_widget.dart';
import 'package:posventa/presentation/widgets/purchase/purchase_totals_footer.dart';
import 'package:posventa/domain/entities/product_variant.dart';

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
    // Initialize notifier with header data
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
    // Find the product for this item
    final productsAsync = ref.read(productNotifierProvider);
    Product? product;

    await productsAsync.when(
      data: (products) async {
        product = products.where((p) => p.id == item.productId).firstOrNull;

        if (product != null) {
          // Find the variant if this item has a variantId
          ProductVariant? variant;
          if (item.variantId != null) {
            variant = product!.variants
                ?.where((v) => v.id == item.variantId)
                .firstOrNull;
          }

          // Get warehouseId from state
          final warehouseId = ref.read(purchaseFormProvider).warehouse?.id;
          if (warehouseId == null) return;

          final result = await showDialog<PurchaseItem>(
            context: context,
            builder: (context) => PurchaseItemDialog(
              warehouseId: warehouseId,
              existingItem: item,
              product: product!,
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Duration(milliseconds: 500),
          content: Text('Compra registrada exitosamente'),
        ),
      );
    } else {
      final error = ref.read(purchaseFormProvider).error;
      if (error != null && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error)));
        ref.read(purchaseFormProvider.notifier).clearError();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    final productsAsync = ref.watch(productNotifierProvider);
    final formState = ref.watch(purchaseFormProvider);

    // Show loading overlay if saving
    if (formState.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return productsAsync.when(
      data: (products) {
        final productMap = {for (var p in products) p.id!: p};

        if (isMobile) {
          return DefaultTabController(
            length: 2,
            child: Scaffold(
              appBar: AppBar(
                title: const Text('Nueva Compra'),
                bottom: const TabBar(
                  tabs: [
                    Tab(text: 'Productos'),
                    Tab(text: 'Tu compra'),
                  ],
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.save),
                    onPressed: _savePurchase,
                  ),
                ],
              ),
              body: Form(
                key: _formKey,
                child: TabBarView(
                  children: [
                    // Tab 1: Product Grid
                    Column(
                      children: [
                        Expanded(
                          child: PurchaseProductGrid(
                            onProductSelected: (product, variant) {
                              ref
                                  .read(purchaseFormProvider.notifier)
                                  .addItemDirectly(product, variant);

                              ScaffoldMessenger.of(
                                context,
                              ).hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Agregado: ${product.name} ${variant != null ? '(${variant.description})' : ''}',
                                  ),
                                  duration: const Duration(milliseconds: 500),
                                ),
                              );
                            },
                          ),
                        ),
                        // Mini summary bar
                        Container(
                          padding: const EdgeInsets.all(12),
                          color: Theme.of(context).primaryColor.withAlpha(20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${formState.items.length} productos',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Total: \$${formState.total.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Tab 2: Order Details
                    Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (formState.supplier != null &&
                                    formState.warehouse != null)
                                  PurchaseHeaderCard(
                                    supplier: formState.supplier!,
                                    warehouse: formState.warehouse!,
                                    invoiceNumber: formState.invoiceNumber,
                                    purchaseDate:
                                        formState.purchaseDate ??
                                        DateTime.now(),
                                  ),
                                const SizedBox(height: 24),
                                PurchaseItemsListWidget(
                                  items: formState.items,
                                  productMap: productMap,
                                  onEditItem: (index) =>
                                      _editItem(index, formState.items[index]),
                                  onRemoveItem: (index) => ref
                                      .read(purchaseFormProvider.notifier)
                                      .removeItem(index),
                                  onQuantityChanged: (index, quantity) {
                                    final item = formState.items[index];
                                    final product = productMap[item.productId];
                                    if (product != null) {
                                      ref
                                          .read(purchaseFormProvider.notifier)
                                          .updateItemQuantity(
                                            index,
                                            quantity,
                                            product,
                                          );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        PurchaseTotalsFooter(total: formState.total),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Nueva Compra'),
            actions: [
              IconButton(
                icon: const Icon(Icons.save),
                onPressed: _savePurchase,
              ),
            ],
          ),
          body: Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Side: Product Grid (60% width)
                      Expanded(
                        flex: 6,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          color: Colors.grey.shade50,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Selección de Productos',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Expanded(
                                child: PurchaseProductGrid(
                                  onProductSelected: (product, variant) {
                                    ref
                                        .read(purchaseFormProvider.notifier)
                                        .addItemDirectly(product, variant);

                                    ScaffoldMessenger.of(
                                      context,
                                    ).hideCurrentSnackBar();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Agregado: ${product.name} ${variant != null ? '(${variant.description})' : ''}',
                                        ),
                                        duration: const Duration(
                                          milliseconds: 500,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Vertical Divider
                      const VerticalDivider(width: 1),

                      // Right Side: Order Details (40% width)
                      Expanded(
                        flex: 4,
                        child: Column(
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Header Info Card
                                    if (formState.supplier != null &&
                                        formState.warehouse != null)
                                      PurchaseHeaderCard(
                                        supplier: formState.supplier!,
                                        warehouse: formState.warehouse!,
                                        invoiceNumber: formState.invoiceNumber,
                                        purchaseDate:
                                            formState.purchaseDate ??
                                            DateTime.now(),
                                      ),
                                    const SizedBox(height: 24),

                                    const Text(
                                      'Items del Pedido',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),

                                    // Items List
                                    PurchaseItemsListWidget(
                                      items: formState.items,
                                      productMap: productMap,
                                      onEditItem: (index) => _editItem(
                                        index,
                                        formState.items[index],
                                      ),
                                      onRemoveItem: (index) => ref
                                          .read(purchaseFormProvider.notifier)
                                          .removeItem(index),
                                      onQuantityChanged: (index, quantity) {
                                        final item = formState.items[index];
                                        final product =
                                            productMap[item.productId];
                                        if (product != null) {
                                          ref
                                              .read(
                                                purchaseFormProvider.notifier,
                                              )
                                              .updateItemQuantity(
                                                index,
                                                quantity,
                                                product,
                                              );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Totals Footer
                            PurchaseTotalsFooter(total: formState.total),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) =>
          Scaffold(body: Center(child: Text('Error: $error'))),
    );
  }
}
