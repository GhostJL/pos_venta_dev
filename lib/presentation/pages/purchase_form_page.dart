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
import 'package:posventa/presentation/providers/supplier_providers.dart';
import 'package:posventa/presentation/providers/warehouse_providers.dart';
import 'package:posventa/presentation/widgets/barcode_scanner_widget.dart';
import 'package:uuid/uuid.dart';

class PurchaseFormPage extends ConsumerStatefulWidget {
  const PurchaseFormPage({super.key});

  @override
  ConsumerState<PurchaseFormPage> createState() => _PurchaseFormPageState();
}

class _PurchaseFormPageState extends ConsumerState<PurchaseFormPage> {
  final _formKey = GlobalKey<FormState>();

  Supplier? _selectedSupplier;
  Warehouse? _selectedWarehouse;
  final _supplierInvoiceController = TextEditingController();
  DateTime _purchaseDate = DateTime.now();

  // Items state
  final List<PurchaseItem> _items = [];

  @override
  void dispose() {
    _supplierInvoiceController.dispose();
    super.dispose();
  }

  void _addItem() async {
    if (_selectedWarehouse == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione un almacén primero')),
      );
      return;
    }

    final result = await showDialog<PurchaseItem>(
      context: context,
      builder: (context) =>
          _AddItemDialog(warehouseId: _selectedWarehouse!.id!),
    );

    if (result != null) {
      setState(() {
        _items.add(result);
      });
    }
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  double get _subtotal => _items.fold(0, (sum, item) => sum + item.subtotal);
  double get _tax => _items.fold(0, (sum, item) => sum + item.tax);
  double get _total => _items.fold(0, (sum, item) => sum + item.total);

  Future<void> _savePurchase() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSupplier == null || _selectedWarehouse == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complete todos los campos requeridos')),
      );
      return;
    }
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
      supplierId: _selectedSupplier!.id!,
      warehouseId: _selectedWarehouse!.id!,
      subtotalCents: (_subtotal * 100).round(),
      taxCents: (_tax * 100).round(),
      totalCents: (_total * 100).round(),
      purchaseDate: _purchaseDate,
      supplierInvoiceNumber: _supplierInvoiceController.text,
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
    final suppliersAsync = ref.watch(supplierListProvider);
    final warehousesAsync = ref.watch(warehouseProvider);

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
                    // Header Inputs
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<Supplier>(
                            initialValue: _selectedSupplier,
                            decoration: const InputDecoration(
                              labelText: 'Proveedor',
                              border: OutlineInputBorder(),
                            ),
                            items: suppliersAsync.when(
                              data: (suppliers) => suppliers
                                  .map(
                                    (s) => DropdownMenuItem(
                                      value: s,
                                      child: Text(s.name),
                                    ),
                                  )
                                  .toList(),
                              loading: () => [],
                              error: (_, __) => [],
                            ),
                            onChanged: (value) =>
                                setState(() => _selectedSupplier = value),
                            validator: (value) =>
                                value == null ? 'Requerido' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<Warehouse>(
                            initialValue: _selectedWarehouse,
                            decoration: const InputDecoration(
                              labelText: 'Almacén Destino',
                              border: OutlineInputBorder(),
                            ),
                            items: warehousesAsync.when(
                              data: (warehouses) => warehouses
                                  .map(
                                    (w) => DropdownMenuItem(
                                      value: w,
                                      child: Text(w.name),
                                    ),
                                  )
                                  .toList(),
                              loading: () => [],
                              error: (_, __) => [],
                            ),
                            onChanged: (value) {
                              if (_items.isNotEmpty) {
                                // Warn about clearing items if warehouse changes?
                                // For now just allow change
                              }
                              setState(() => _selectedWarehouse = value);
                            },
                            validator: (value) =>
                                value == null ? 'Requerido' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _supplierInvoiceController,
                            decoration: const InputDecoration(
                              labelText: 'Factura Proveedor (Opcional)',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _purchaseDate,
                                firstDate: DateTime(2000),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) {
                                setState(() => _purchaseDate = picked);
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Fecha de Compra',
                                border: OutlineInputBorder(),
                              ),
                              child: Text(
                                "${_purchaseDate.day}/${_purchaseDate.month}/${_purchaseDate.year}",
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Items Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Productos',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        ElevatedButton.icon(
                          onPressed: _addItem,
                          icon: const Icon(Icons.add),
                          label: const Text('Agregar Producto'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

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
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _removeItem(index),
                                ),
                              ],
                            ),
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

  const _AddItemDialog({required this.warehouseId});

  @override
  ConsumerState<_AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends ConsumerState<_AddItemDialog> {
  final _formKey = GlobalKey<FormState>();
  Product? _selectedProduct;
  final _quantityController = TextEditingController(text: '1');
  final _costController = TextEditingController();
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _quantityController.dispose();
    _costController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _selectProduct(Product product) {
    setState(() {
      _selectedProduct = product;
      _searchController.text = product.name;
      // Pre-fill with current cost
      _costController.text = (product.costPriceCents / 100).toStringAsFixed(2);
    });
  }

  Future<void> _scanBarcode() async {
    final productsAsync = ref.read(productNotifierProvider);

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BarcodeScannerWidget(
          title: 'Escanear Producto',
          hint: 'Escanea el código de barras del producto',
          onBarcodeScanned: (ctx, barcode) async {
            // Search for product by barcode
            productsAsync.whenData((products) {
              final product = products
                  .where((p) => p.barcode == barcode)
                  .firstOrNull;
              if (product != null) {
                _selectProduct(product);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Producto encontrado: ${product.name}'),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 2),
                  ),
                );
              } else {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Producto no encontrado'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productNotifierProvider);

    return AlertDialog(
      title: Row(
        children: [
          const Expanded(child: Text('Agregar Producto')),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: _scanBarcode,
            tooltip: 'Escanear código de barras',
            color: Theme.of(context).primaryColor,
          ),
        ],
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Product Search/Selection
              productsAsync.when(
                data: (products) {
                  return Autocomplete<Product>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return products;
                      }
                      return products.where((product) {
                        return product.name.toLowerCase().contains(
                              textEditingValue.text.toLowerCase(),
                            ) ||
                            (product.barcode?.contains(textEditingValue.text) ??
                                false);
                      });
                    },
                    displayStringForOption: (Product option) => option.name,
                    onSelected: _selectProduct,
                    fieldViewBuilder:
                        (context, controller, focusNode, onEditingComplete) {
                          _searchController.text = controller.text;
                          return TextFormField(
                            controller: controller,
                            focusNode: focusNode,
                            decoration: InputDecoration(
                              labelText: 'Buscar Producto',
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.search),
                              suffixIcon: _selectedProduct != null
                                  ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        controller.clear();
                                        setState(() => _selectedProduct = null);
                                      },
                                    )
                                  : null,
                            ),
                            validator: (value) => _selectedProduct == null
                                ? 'Seleccione un producto'
                                : null,
                          );
                        },
                    optionsViewBuilder: (context, onSelected, options) {
                      return Align(
                        alignment: Alignment.topLeft,
                        child: Material(
                          elevation: 4,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 200),
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              itemCount: options.length,
                              itemBuilder: (context, index) {
                                final product = options.elementAt(index);
                                return ListTile(
                                  title: Text(product.name),
                                  subtitle: Text(
                                    'Costo actual: \$${(product.costPriceCents / 100).toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                                  onTap: () => onSelected(product),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (_, __) => const Text('Error al cargar productos'),
              ),

              // Cost Reference (if product selected)
              if (_selectedProduct != null) ...[
                const SizedBox(height: 12),
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
                          'Costo anterior: \$${(_selectedProduct!.costPriceCents / 100).toStringAsFixed(2)}',
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
              ],

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
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate() && _selectedProduct != null) {
              final quantity = double.parse(_quantityController.text);
              final cost = double.parse(_costController.text);
              final costCents = (cost * 100).round();
              final subtotalCents = (costCents * quantity).round();

              // Simple tax calculation (e.g., 0 for now, or fetch product tax)
              // For now assuming 0 tax on purchases unless specified
              const taxCents = 0;
              final totalCents = subtotalCents + taxCents;

              final item = PurchaseItem(
                productId: _selectedProduct!.id!,
                productName: _selectedProduct!.name,
                quantity: quantity,
                unitOfMeasure: _selectedProduct!.unitOfMeasure,
                unitCostCents: costCents,
                subtotalCents: subtotalCents,
                taxCents: taxCents,
                totalCents: totalCents,
                createdAt: DateTime.now(),
              );
              Navigator.pop(context, item);
            }
          },
          child: const Text('Agregar'),
        ),
      ],
    );
  }
}
