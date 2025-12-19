import 'package:flutter/material.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/entities/product_variant.dart';

import 'package:posventa/presentation/providers/purchase_form_provider.dart';
import 'package:posventa/presentation/widgets/purchases/cards/purchase_header_card.dart';
import 'package:posventa/presentation/widgets/purchases/lists/purchase_items_list_widget.dart';
import 'package:posventa/presentation/widgets/purchases/misc/purchase_product_grid.dart';
import 'package:posventa/presentation/widgets/purchases/cards/purchase_totals_footer.dart';

class PurchaseFormMobileLayout extends StatelessWidget {
  final PurchaseFormState formState;
  final Map<int, Product> productMap;
  final Function(Product, ProductVariant?) onProductSelected;
  final Function(int) onEditItem;
  final Function(int) onRemoveItem;
  final Function(int, double) onQuantityChanged;
  final VoidCallback onSavePurchase;
  final GlobalKey<FormState> formKey;

  const PurchaseFormMobileLayout({
    super.key,
    required this.formState,
    required this.productMap,
    required this.onProductSelected,
    required this.onEditItem,
    required this.onRemoveItem,
    required this.onQuantityChanged,
    required this.onSavePurchase,
    required this.formKey,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Nueva Compra'),
          backgroundColor: Colors.transparent,
          bottom: TabBar(
            dividerColor: Colors.transparent,
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: textTheme.labelLarge,
            tabs: const [
              Tab(text: 'Catálogo'),
              Tab(text: 'Orden'),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                onPressed: onSavePurchase,
                icon: const Icon(Icons.check),
                tooltip: 'Confirmar Orden',
              ),
            ),
          ],
        ),
        body: Form(
          key: formKey,
          child: TabBarView(
            children: [
              // Tab 1: Product Grid
              Column(
                children: [
                  Expanded(
                    child: PurchaseProductGrid(
                      onProductSelected: onProductSelected,
                    ),
                  ),
                  _MiniSummary(
                    itemCount: formState.items.length,
                    total: formState.total,
                  ),
                ],
              ),

              // Tab 2: Order Details
              Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        if (formState.supplier != null &&
                            formState.warehouse != null)
                          PurchaseHeaderCard(
                            supplier: formState.supplier!,
                            warehouse: formState.warehouse!,
                            invoiceNumber: formState.invoiceNumber,
                            purchaseDate:
                                formState.purchaseDate ?? DateTime.now(),
                          ),
                        const SizedBox(height: 24),
                        Text(
                          'Detalle de Productos',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        PurchaseItemsListWidget(
                          items: formState.items,
                          productMap: productMap,
                          onEditItem: onEditItem,
                          onRemoveItem: onRemoveItem,
                          onQuantityChanged: onQuantityChanged,
                        ),
                        const SizedBox(height: 80), // Space for footer
                      ],
                    ),
                  ),
                  PurchaseTotalsFooter(
                    itemsCount: formState.items.length,
                    total: formState.total,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniSummary extends StatelessWidget {
  final int itemCount;
  final double total;

  const _MiniSummary({required this.itemCount, required this.total});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(color: colorScheme.primaryContainer),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              color: colorScheme.onPrimaryContainer,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              '$itemCount Producto ${itemCount > 1 ? 's' : ''}',
              style: textTheme.titleSmall?.copyWith(
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Text(
              '\$ ${total.toStringAsFixed(2)}',
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
