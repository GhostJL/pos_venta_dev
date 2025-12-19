import 'package:flutter/material.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/entities/product_variant.dart';

import 'package:posventa/presentation/providers/purchase_form_provider.dart';
import 'package:posventa/presentation/widgets/purchases/cards/purchase_header_card.dart';
import 'package:posventa/presentation/widgets/purchases/lists/purchase_items_list_widget.dart';
import 'package:posventa/presentation/widgets/purchases/misc/purchase_product_grid.dart';
import 'package:posventa/presentation/widgets/purchases/cards/purchase_totals_footer.dart';

class PurchaseFormDesktopLayout extends StatelessWidget {
  final PurchaseFormState formState;
  final Map<int, Product> productMap;
  final Function(Product, ProductVariant?) onProductSelected;
  final Function(int) onEditItem;
  final Function(int) onRemoveItem;
  final Function(int, double) onQuantityChanged;
  final VoidCallback onSavePurchase;
  final GlobalKey<FormState> formKey;

  const PurchaseFormDesktopLayout({
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Compra'),
        backgroundColor: Colors.transparent,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: FilledButton.icon(
              onPressed: onSavePurchase,
              icon: const Icon(Icons.check),
              label: const Text('Confirmar Orden'),
            ),
          ),
        ],
      ),
      body: Form(
        key: formKey,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Side: Product Selection
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  border: Border(
                    right: BorderSide(
                      color: colorScheme.outlineVariant,
                      width: 1,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Catálogo de Productos',
                            style: textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            'Seleccione los artículos para agregar a la orden.',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: PurchaseProductGrid(
                          onProductSelected: onProductSelected,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Right Side: Order Summary
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(24),
                      children: [
                        Text(
                          'Resumen de Orden',
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (formState.supplier != null &&
                            formState.warehouse != null)
                          PurchaseHeaderCard(
                            supplier: formState.supplier!,
                            warehouse: formState.warehouse!,
                            invoiceNumber: formState.invoiceNumber,
                            purchaseDate:
                                formState.purchaseDate ?? DateTime.now(),
                          ),
                        const SizedBox(height: 32),
                        Row(
                          children: [
                            const Icon(Icons.shopping_cart_outlined, size: 20),
                            const SizedBox(width: 12),
                            Text(
                              'Artículos Seleccionados',
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${formState.items.length} Productos',
                              style: textTheme.labelLarge?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        PurchaseItemsListWidget(
                          items: formState.items,
                          productMap: productMap,
                          onEditItem: onEditItem,
                          onRemoveItem: onRemoveItem,
                          onQuantityChanged: onQuantityChanged,
                        ),
                      ],
                    ),
                  ),
                  PurchaseTotalsFooter(
                    itemsCount: formState.items.length,
                    total: formState.total,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
