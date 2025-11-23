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

  @override
  void dispose() {
    super.dispose();
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  Future<void> _openAddItemDialog(Product product) async {
    final result = await showDialog<PurchaseItem>(
      context: context,
      builder: (context) =>
          _AddItemDialog(warehouseId: _warehouse.id!, product: product),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Producto encontrado: ${product.name}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        _openAddItemDialog(product);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Producto no encontrado'),
            backgroundColor: Colors.orange,
          ),
        );
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
            builder: (context) => _EditItemDialog(
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

  double get _subtotal => _items.fold(0, (sum, item) => sum + item.subtotal);
  double get _tax => _items.fold(0, (sum, item) => sum + item.tax);
  double get _total => _items.fold(0, (sum, item) => sum + item.total);

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
      purchaseNumber:
          'PUR-${const Uuid().v4().substring(0, 8).toUpperCase()}', // Temporary generation
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
      status: PurchaseStatus.pending, // Start as pending, complete on reception
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
                    // Header Info Display (Read-only from previous step)
                    Card(
                      color: Colors.blue.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.blue.shade700,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Información de la Compra',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade900,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Proveedor:',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                      Text(
                                        _supplier.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Almacén:',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                      Text(
                                        _warehouse.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                if (_invoiceNumber.isNotEmpty)
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Factura:',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                        Text(
                                          _invoiceNumber,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Fecha:',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                      Text(
                                        "${_purchaseDate.day.toString().padLeft(2, '0')}/${_purchaseDate.month.toString().padLeft(2, '0')}/${_purchaseDate.year}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Items Section
                    const SizedBox(height: 16),
                    // Product Search/Selection
                    ref
                        .watch(productNotifierProvider)
                        .when(
                          data: (products) {
                            return Row(
                              children: [
                                Expanded(
                                  child: Autocomplete<Product>(
                                    optionsBuilder:
                                        (TextEditingValue textEditingValue) {
                                          if (textEditingValue.text.isEmpty) {
                                            return const Iterable<
                                              Product
                                            >.empty();
                                          }
                                          return products.where((product) {
                                            return product.name
                                                    .toLowerCase()
                                                    .contains(
                                                      textEditingValue.text
                                                          .toLowerCase(),
                                                    ) ||
                                                (product.barcode?.contains(
                                                      textEditingValue.text,
                                                    ) ??
                                                    false);
                                          });
                                        },
                                    displayStringForOption: (Product option) =>
                                        option.name,
                                    onSelected: (Product product) {
                                      _openAddItemDialog(product);
                                    },
                                    fieldViewBuilder:
                                        (
                                          context,
                                          controller,
                                          focusNode,
                                          onEditingComplete,
                                        ) {
                                          return TextField(
                                            controller: controller,
                                            focusNode: focusNode,
                                            decoration: InputDecoration(
                                              labelText: 'Buscar Producto',
                                              hintText:
                                                  'Nombre o Código de Barras',
                                              border:
                                                  const OutlineInputBorder(),
                                              prefixIcon: const Icon(
                                                Icons.search,
                                              ),
                                              suffixIcon:
                                                  controller.text.isNotEmpty
                                                  ? IconButton(
                                                      icon: const Icon(
                                                        Icons.clear,
                                                      ),
                                                      onPressed: () {
                                                        controller.clear();
                                                      },
                                                    )
                                                  : null,
                                            ),
                                            onEditingComplete:
                                                onEditingComplete,
                                          );
                                        },
                                    optionsViewBuilder:
                                        (context, onSelected, options) {
                                          return Align(
                                            alignment: Alignment.topLeft,
                                            child: Material(
                                              elevation: 4,
                                              child: ConstrainedBox(
                                                constraints:
                                                    const BoxConstraints(
                                                      maxHeight: 200,
                                                      maxWidth: 400,
                                                    ),
                                                child: ListView.builder(
                                                  padding: EdgeInsets.zero,
                                                  shrinkWrap: true,
                                                  itemCount: options.length,
                                                  itemBuilder: (context, index) {
                                                    final product = options
                                                        .elementAt(index);
                                                    return ListTile(
                                                      title: Text(product.name),
                                                      subtitle: Text(
                                                        'Costo: \$${(product.costPriceCents / 100).toStringAsFixed(2)}',
                                                        style: TextStyle(
                                                          color: Colors
                                                              .grey
                                                              .shade600,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                      onTap: () =>
                                                          onSelected(product),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton.filled(
                                  onPressed: () => _scanProduct(products),
                                  icon: const Icon(Icons.qr_code_scanner),
                                  tooltip: 'Escanear código de barras',
                                  style: IconButton.styleFrom(
                                    padding: const EdgeInsets.all(16),
                                  ),
                                ),
                              ],
                            );
                          },
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (_, __) =>
                              const Text('Error al cargar productos'),
                        ),
                    const SizedBox(height: 16),

                    if (_items.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(32),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('No hay productos agregados'),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _items.length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          final item = _items[index];
                          return ListTile(
                            title: Text(item.productName ?? 'Producto'),
                            subtitle: Text(
                              '${item.quantity} ${item.unitOfMeasure} x \$${item.unitCost.toStringAsFixed(2)}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '\$${item.total.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () => _editItem(index),
                                  tooltip: 'Editar',
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _removeItem(index),
                                  tooltip: 'Eliminar',
                                ),
                              ],
                            ),
                            onTap: () => _editItem(index),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),

            // Footer Totals
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(100),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Subtotal:'),
                      Text('\$${_subtotal.toStringAsFixed(2)}'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Impuestos:'),
                      Text('\$${_tax.toStringAsFixed(2)}'),
                    ],
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'TOTAL:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '\$${_total.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
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

class _AddItemDialog extends ConsumerStatefulWidget {
  final int warehouseId;
  final Product product;

  const _AddItemDialog({required this.warehouseId, required this.product});

  @override
  ConsumerState<_AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends ConsumerState<_AddItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController(text: '1');
  final _costController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _costController.text = (widget.product.costPriceCents / 100)
        .toStringAsFixed(2);
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _costController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Agregar ${widget.product.name}'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Cost Reference
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Costo anterior: \$${(widget.product.costPriceCents / 100).toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Colors.blue.shade900,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: 'Cantidad',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.inventory_2),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Requerido';
                  if (double.tryParse(value) == null) return 'Inválido';
                  if (double.parse(value) <= 0) return 'Debe ser mayor a 0';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _costController,
                decoration: const InputDecoration(
                  labelText: 'Costo Unitario',
                  prefixText: '\$ ',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Requerido';
                  if (double.tryParse(value) == null) return 'Inválido';
                  if (double.parse(value) < 0) return 'No puede ser negativo';
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final quantity = double.parse(_quantityController.text);
              final cost = double.parse(_costController.text);
              final costCents = (cost * 100).round();
              final subtotalCents = (costCents * quantity).round();

              // Simple tax calculation (e.g., 0 for now, or fetch product tax)
              // For now assuming 0 tax on purchases unless specified
              const taxCents = 0;
              final totalCents = subtotalCents + taxCents;

              final item = PurchaseItem(
                productId: widget.product.id!,
                productName: widget.product.name,
                quantity: quantity,
                unitOfMeasure: widget.product.unitOfMeasure,
                unitCostCents: costCents,
                subtotalCents: subtotalCents,
                taxCents: taxCents,
                totalCents: totalCents,
                createdAt: DateTime.now(),
              );
              context.pop(item);
            }
          },
          child: const Text('Agregar'),
        ),
      ],
    );
  }
}

class _EditItemDialog extends ConsumerStatefulWidget {
  final int warehouseId;
  final PurchaseItem existingItem;
  final Product product;

  const _EditItemDialog({
    required this.warehouseId,
    required this.existingItem,
    required this.product,
  });

  @override
  ConsumerState<_EditItemDialog> createState() => _EditItemDialogState();
}

class _EditItemDialogState extends ConsumerState<_EditItemDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _quantityController;
  late TextEditingController _costController;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(
      text: widget.existingItem.quantity.toString(),
    );
    _costController = TextEditingController(
      text: widget.existingItem.unitCost.toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _costController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Editar ${widget.product.name}'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _quantityController,
              decoration: const InputDecoration(
                labelText: 'Cantidad',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.inventory_2),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Requerido';
                if (double.tryParse(value) == null) return 'Inválido';
                if (double.parse(value) <= 0) return 'Debe ser mayor a 0';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _costController,
              decoration: const InputDecoration(
                labelText: 'Costo Unitario',
                prefixText: '\$ ',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Requerido';
                if (double.tryParse(value) == null) return 'Inválido';
                if (double.parse(value) < 0) return 'No puede ser negativo';
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final quantity = double.parse(_quantityController.text);
              final cost = double.parse(_costController.text);
              final costCents = (cost * 100).round();
              final subtotalCents = (costCents * quantity).round();

              const taxCents = 0;
              final totalCents = subtotalCents + taxCents;

              final updatedItem = PurchaseItem(
                id: widget.existingItem.id,
                purchaseId: widget.existingItem.purchaseId,
                productId: widget.existingItem.productId,
                productName: widget.existingItem.productName,
                quantity: quantity,
                unitOfMeasure: widget.existingItem.unitOfMeasure,
                unitCostCents: costCents,
                subtotalCents: subtotalCents,
                taxCents: taxCents,
                totalCents: totalCents,
                lotNumber: widget.existingItem.lotNumber,
                expirationDate: widget.existingItem.expirationDate,
                createdAt: widget.existingItem.createdAt,
              );

              context.pop(updatedItem);
            }
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
