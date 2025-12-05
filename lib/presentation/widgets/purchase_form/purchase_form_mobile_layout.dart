import 'package:flutter/material.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/entities/product_variant.dart';

import 'package:posventa/presentation/providers/purchase_form_provider.dart';
import 'package:posventa/presentation/widgets/purchase/purchase_header_card.dart';
import 'package:posventa/presentation/widgets/purchase/purchase_items_list_widget.dart';
import 'package:posventa/presentation/widgets/purchase/purchase_product_grid.dart';
import 'package:posventa/presentation/widgets/purchase/purchase_totals_footer.dart';

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
            IconButton(icon: const Icon(Icons.save), onPressed: onSavePurchase),
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
                  // Mini summary bar
                  Container(
                    padding: const EdgeInsets.all(12),
                    color: Theme.of(context).primaryColor.withAlpha(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${formState.items.length} productos',
                          style: const TextStyle(fontWeight: FontWeight.bold),
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
                                  formState.purchaseDate ?? DateTime.now(),
                            ),
                          const SizedBox(height: 24),
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
}
