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
import 'package:posventa/presentation/widgets/purchase/product_search_bar.dart';
import 'package:posventa/presentation/widgets/purchase/purchase_header_card.dart';
import 'package:posventa/presentation/widgets/purchase/purchase_item_dialog.dart';
import 'package:posventa/presentation/widgets/purchase/purchase_items_list_widget.dart';
import 'package:posventa/presentation/widgets/purchase/purchase_totals_footer.dart';
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

  Future<void> _openAddItemDialog(Product product) async {
    final result = await showDialog<PurchaseItem>(
      context: context,
      builder: (context) =>
          PurchaseItemDialog(warehouseId: _warehouse.id!, product: product),
    );

    if (result != null) {
      setState(() {
        _items.add(result);
      });
    }
  }

  Future<void> _scanProduct(List<Product> products) async {
    final barcode = await context.push<String>('/scanner');

    if (barcode != null && mounted) {
      final product = products.where((p) => p.barcode == barcode).firstOrNull;
      if (product != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Producto encontrado: ${product.name}'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
          _openAddItemDialog(product);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Producto no encontrado'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
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
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Compra registrada exitosamente')),
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

                    // Product Search
                    ref
                        .watch(productNotifierProvider)
                        .when(
                          data: (products) => ProductSearchBar(
                            products: products,
                            onProductSelected: _openAddItemDialog,
                            onScanPressed: () => _scanProduct(products),
                          ),
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (_, __) =>
                              const Text('Error al cargar productos'),
                        ),
                    const SizedBox(height: 16),

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
            PurchaseTotalsFooter(subtotal: _subtotal, tax: _tax, total: _total),
          ],
        ),
      ),
    );
  }
}
