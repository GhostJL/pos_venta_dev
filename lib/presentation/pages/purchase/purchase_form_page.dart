import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/entities/purchase.dart';
import 'package:posventa/domain/entities/purchase_item.dart';
import 'package:posventa/domain/entities/supplier.dart';
import 'package:posventa/domain/entities/warehouse.dart';
import 'package:posventa/presentation/providers/auth_provider.dart';
import 'package:posventa/presentation/providers/product_provider.dart';
import 'package:posventa/presentation/providers/purchase_providers.dart';
import 'package:posventa/presentation/widgets/purchase/purchase_product_grid.dart';
import 'package:posventa/presentation/widgets/purchase/purchase_header_card.dart';
import 'package:posventa/presentation/widgets/purchase/purchase_item_dialog.dart';
import 'package:posventa/presentation/widgets/purchase/purchase_items_list_widget.dart';
import 'package:posventa/presentation/widgets/purchase/purchase_totals_footer.dart';
import 'package:posventa/domain/entities/product_variant.dart';
import 'package:posventa/core/utils/purchase_calculations.dart';
import 'package:uuid/uuid.dart';

class PurchaseFormPage extends ConsumerStatefulWidget {
  final Map<String, dynamic>? headerData;

  const PurchaseFormPage({super.key, this.headerData});

  @override
  ConsumerState<PurchaseFormPage> createState() => _PurchaseFormPageState();
}

class _PurchaseFormPageState extends ConsumerState<PurchaseFormPage> {
  final _formKey = GlobalKey<FormState>();

  // Header data from previous step
  late final Supplier _supplier;
  late final Warehouse _warehouse;
  late final String _invoiceNumber;
  late final DateTime _purchaseDate;

  // Items state
  final List<PurchaseItem> _items = [];

  @override
  void initState() {
    super.initState();
    // Initialize from header data
    if (widget.headerData != null) {
      _supplier = widget.headerData!['supplier'] as Supplier;
      _warehouse = widget.headerData!['warehouse'] as Warehouse;
      _invoiceNumber = widget.headerData!['invoiceNumber'] as String;
      _purchaseDate = widget.headerData!['purchaseDate'] as DateTime;
    }
  }

  // Computed totals
  double get _subtotal => _items.fold(0, (sum, item) => sum + item.subtotal);
  double get _tax => _items.fold(0, (sum, item) => sum + item.tax);
  double get _total => _items.fold(0, (sum, item) => sum + item.total);

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  Future<void> _addItemDirectly(
    Product product,
    ProductVariant? variant,
  ) async {
    // Determine quantity to add (default 1, or variant multiplier)
    final double quantityToAdd = variant?.quantity ?? 1.0;

    // Determine UNIT cost (cost per single unit)
    // If variant is selected, its costPriceCents is the cost of the PACK.
    // So Unit Cost = Pack Cost / Pack Quantity.
    final double unitCost;
    if (variant != null) {
      unitCost = (variant.costPriceCents / 100) / quantityToAdd;
    } else {
      unitCost = product.costPriceCents / 100;
    }

    // Check if item already exists
    final existingIndex = _items.indexWhere(
      (item) => item.productId == product.id && item.variantId == variant?.id,
    );

    if (existingIndex != -1) {
      // Update existing item
      final existingItem = _items[existingIndex];
      final newQuantity = existingItem.quantity + quantityToAdd;

      final updatedItem = PurchaseCalculations.createPurchaseItem(
        product: product,
        quantity: newQuantity,
        unitCost: unitCost,
        existingItem: existingItem,
        variant: variant,
      );

      setState(() {
        _items[existingIndex] = updatedItem;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Cantidad actualizada: ${product.name} (+${quantityToAdd.toStringAsFixed(0)})',
            ),
            duration: const Duration(milliseconds: 500),
          ),
        );
      }
    } else {
      // Add new item
      final newItem = PurchaseCalculations.createPurchaseItem(
        product: product,
        quantity: quantityToAdd,
        unitCost: unitCost,
        variant: variant,
      );

      setState(() {
        _items.add(newItem);
      });
    }
  }

  Future<void> _editItem(int index) async {
    final item = _items[index];

    // Find the product for this item
    final productsAsync = ref.read(productNotifierProvider);
    Product? product;

    await productsAsync.when(
      data: (products) async {
        product = products.where((p) => p.id == item.productId).firstOrNull;

        if (product != null) {
          final result = await showDialog<PurchaseItem>(
            context: context,
            builder: (context) => PurchaseItemDialog(
              warehouseId: _warehouse.id!,
              existingItem: item,
              product: product!,
            ),
          );

          if (result != null) {
            setState(() {
              _items[index] = result;
            });
          }
        }
      },
      loading: () {},
      error: (_, __) {},
    );
  }

  Future<void> _savePurchase() async {
    if (!_formKey.currentState!.validate()) return;
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agregue al menos un producto')),
      );
      return;
    }

    final user = ref.read(authProvider).user;
    if (user == null) return;

    final purchase = Purchase(
      purchaseNumber: 'PUR-${const Uuid().v4().substring(0, 8).toUpperCase()}',
      supplierId: _supplier.id!,
      warehouseId: _warehouse.id!,
      subtotalCents: (_subtotal * 100).round(),
      taxCents: (_tax * 100).round(),
      totalCents: (_total * 100).round(),
      purchaseDate: _purchaseDate,
      supplierInvoiceNumber: _invoiceNumber.isNotEmpty ? _invoiceNumber : null,
      requestedBy: user.id!,
      createdAt: DateTime.now(),
      items: _items,
      status: PurchaseStatus.pending,
    );

    try {
      await ref.read(purchaseProvider.notifier).addPurchase(purchase);
      if (mounted) {
        context.go('/purchases');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            duration: Duration(milliseconds: 500),
            content: Text('Compra registrada exitosamente'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al guardar: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    if (isMobile) {
      return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Nueva Compra'),
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Productos', icon: Icon(Icons.grid_view)),
                Tab(text: 'Detalle', icon: Icon(Icons.receipt_long)),
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
                        onProductSelected: _addItemDirectly,
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
                            '${_items.length} items',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Total: \$${_total.toStringAsFixed(2)}',
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
                            PurchaseHeaderCard(
                              supplier: _supplier,
                              warehouse: _warehouse,
                              invoiceNumber: _invoiceNumber,
                              purchaseDate: _purchaseDate,
                            ),
                            const SizedBox(height: 24),
                            PurchaseItemsListWidget(
                              items: _items,
                              onEditItem: _editItem,
                              onRemoveItem: _removeItem,
                            ),
                          ],
                        ),
                      ),
                    ),
                    PurchaseTotalsFooter(
                      subtotal: _subtotal,
                      tax: _tax,
                      total: _total,
                    ),
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
          IconButton(icon: const Icon(Icons.save), onPressed: _savePurchase),
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
                              onProductSelected: _addItemDirectly,
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
                                PurchaseHeaderCard(
                                  supplier: _supplier,
                                  warehouse: _warehouse,
                                  invoiceNumber: _invoiceNumber,
                                  purchaseDate: _purchaseDate,
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
                                  items: _items,
                                  onEditItem: _editItem,
                                  onRemoveItem: _removeItem,
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Totals Footer
                        PurchaseTotalsFooter(
                          subtotal: _subtotal,
                          tax: _tax,
                          total: _total,
                        ),
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
