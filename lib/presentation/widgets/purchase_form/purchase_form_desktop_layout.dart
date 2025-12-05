import 'package:flutter/material.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/entities/product_variant.dart';

import 'package:posventa/presentation/providers/purchase_form_provider.dart';
import 'package:posventa/presentation/widgets/purchase/purchase_header_card.dart';
import 'package:posventa/presentation/widgets/purchase/purchase_items_list_widget.dart';
import 'package:posventa/presentation/widgets/purchase/purchase_product_grid.dart';
import 'package:posventa/presentation/widgets/purchase/purchase_totals_footer.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Compra'),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: onSavePurchase),
        ],
      ),
      body: Form(
        key: formKey,
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
                              onProductSelected: onProductSelected,
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
                                  onEditItem: onEditItem,
                                  onRemoveItem: onRemoveItem,
                                  onQuantityChanged: onQuantityChanged,
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
  }
}
