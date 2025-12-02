import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/entities/product_variant.dart';
import 'package:posventa/domain/entities/purchase_item.dart';
import 'package:posventa/presentation/providers/product_provider.dart';
import 'package:posventa/presentation/providers/purchase_item_providers.dart';
import 'package:posventa/presentation/providers/purchase_providers.dart';

/// Helper class to represent a product or product variant as a single selectable item
class ProductVariantItem {
  final Product product;
  final ProductVariant? variant;

  ProductVariantItem({required this.product, this.variant});

  String get displayName {
    if (variant != null) {
      return '${product.name} - ${variant!.description} (Factor: ${variant!.quantity})';
    }
    return product.name;
  }

  int get costPriceCents {
    return variant?.costPriceCents ?? product.costPriceCents;
  }

  String get unitOfMeasure {
    return product.unitOfMeasure;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductVariantItem &&
          runtimeType == other.runtimeType &&
          product.id == other.product.id &&
          variant?.id == other.variant?.id;

  @override
  int get hashCode => product.id.hashCode ^ (variant?.id.hashCode ?? 0);
}

/// Form page for creating or editing a purchase item
/// Can be used standalone or as part of a purchase creation flow
class PurchaseItemFormPage extends ConsumerStatefulWidget {
  final int? itemId; // null for create, non-null for edit
  final int? purchaseId; // Optional: pre-select purchase

  const PurchaseItemFormPage({super.key, this.itemId, this.purchaseId});

  @override
  ConsumerState<PurchaseItemFormPage> createState() =>
      _PurchaseItemFormPageState();
}

class _PurchaseItemFormPageState extends ConsumerState<PurchaseItemFormPage> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _quantityController = TextEditingController();
  final _unitCostController = TextEditingController();
  final _lotNumberController = TextEditingController();

  // Form state
  ProductVariantItem? _selectedItem;
  int? _selectedPurchaseId;
  DateTime? _expirationDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedPurchaseId = widget.purchaseId;

    // Load existing item data if editing
    if (widget.itemId != null) {
      _loadItemData();
    }
  }

  Future<void> _loadItemData() async {
    final item = await ref.read(
      purchaseItemByIdProvider(widget.itemId!).future,
    );
    if (item != null && mounted) {
      setState(() {
        _quantityController.text = item.quantity.toString();
        _unitCostController.text = item.unitCost.toStringAsFixed(2);
        // _lotNumberController.text = item.lotNumber ?? '';
        _selectedPurchaseId = item.purchaseId;
        _expirationDate = item.expirationDate;
        // Note: We can't set _selectedProduct here without loading products
        // But we can store the variantId to set it later if needed,
        // or rely on the user re-selecting if they edit.
        // Ideally we should load the product and variant.
      });
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _unitCostController.dispose();
    _lotNumberController.dispose();
    super.dispose();
  }

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedItem == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Seleccione un producto')));
      return;
    }

    if (_selectedPurchaseId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Seleccione una compra')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final quantity = double.parse(_quantityController.text);
      final unitCost = double.parse(_unitCostController.text);
      final unitCostCents = (unitCost * 100).round();
      final subtotalCents = (unitCostCents * quantity).round();

      // Simple tax calculation (0 for now, can be enhanced)
      const taxCents = 0;
      final totalCents = subtotalCents + taxCents;

      final item = PurchaseItem(
        id: widget.itemId,
        purchaseId: _selectedPurchaseId,
        productId: _selectedItem!.product.id!,
        variantId: _selectedItem!.variant?.id,
        productName: _selectedItem!.product.name,
        quantity: quantity,
        unitOfMeasure: _selectedItem!.unitOfMeasure,
        unitCostCents: unitCostCents,
        subtotalCents: subtotalCents,
        taxCents: taxCents,
        totalCents: totalCents,
        // lotNumber: _lotNumberController.text.isEmpty
        //     ? null
        //     : _lotNumberController.text,
        expirationDate: _expirationDate,
        createdAt: DateTime.now(),
      );

      if (widget.itemId == null) {
        // Create new item
        await ref.read(purchaseItemProvider.notifier).addPurchaseItem(item);
      } else {
        // Update existing item
        await ref.read(purchaseItemProvider.notifier).updatePurchaseItem(item);
      }

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.itemId == null
                  ? 'Artículo creado exitosamente'
                  : 'Artículo actualizado exitosamente',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productNotifierProvider);
    final purchasesAsync = ref.watch(purchaseProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.itemId == null
              ? 'Nuevo Artículo de Compra'
              : 'Editar Artículo de Compra',
        ),
        actions: [
          if (!_isLoading)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveItem,
              tooltip: 'Guardar',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Selection
                    Text(
                      'Información del Producto',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<ProductVariantItem>(
                      initialValue: _selectedItem,
                      decoration: const InputDecoration(
                        labelText: 'Producto / Variante *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.shopping_bag),
                      ),
                      items: productsAsync.when(
                        data: (products) {
                          // Flatten products and variants into a single list
                          final List<ProductVariantItem> items = [];
                          for (final product in products) {
                            if (product.variants != null &&
                                product.variants!.isNotEmpty) {
                              // Add each variant as a separate item
                              for (final variant in product.variants!) {
                                items.add(
                                  ProductVariantItem(
                                    product: product,
                                    variant: variant,
                                  ),
                                );
                              }
                            } else {
                              // Add product without variant
                              items.add(ProductVariantItem(product: product));
                            }
                          }
                          return items
                              .map(
                                (item) => DropdownMenuItem(
                                  value: item,
                                  child: Text(
                                    item.displayName,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList();
                        },
                        loading: () => [],
                        error: (_, __) => [],
                      ),
                      onChanged: (value) {
                        setState(() {
                          _selectedItem = value;
                          if (value != null) {
                            // Pre-fill cost from product or variant
                            _unitCostController.text =
                                (value.costPriceCents / 100).toStringAsFixed(2);
                          }
                        });
                      },
                      validator: (value) => value == null ? 'Requerido' : null,
                    ),

                    const SizedBox(height: 24),

                    // Purchase Selection (if not pre-selected)
                    if (widget.purchaseId == null) ...[
                      Text(
                        'Compra Asociada',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        initialValue: _selectedPurchaseId,
                        decoration: const InputDecoration(
                          labelText: 'Compra *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.shopping_cart),
                        ),
                        items: purchasesAsync.when(
                          data: (purchases) => purchases
                              .map(
                                (p) => DropdownMenuItem(
                                  value: p.id,
                                  child: Text(
                                    '${p.purchaseNumber} - ${p.supplierName ?? 'N/A'}',
                                  ),
                                ),
                              )
                              .toList(),
                          loading: () => [],
                          error: (_, __) => [],
                        ),
                        onChanged: (value) {
                          setState(() => _selectedPurchaseId = value);
                        },
                        validator: (value) =>
                            value == null ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Quantity and Cost
                    Text(
                      'Cantidad y Precio',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _quantityController,
                            decoration: const InputDecoration(
                              labelText: 'Cantidad *',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.inventory),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Requerido';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Inválido';
                              }
                              if (double.parse(value) <= 0) {
                                return 'Debe ser mayor a 0';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _unitCostController,
                            decoration: const InputDecoration(
                              labelText: 'Costo Unitario *',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.attach_money),
                              prefixText: '\$ ',
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Requerido';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Inválido';
                              }
                              if (double.parse(value) < 0) {
                                return 'No puede ser negativo';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Optional Fields
                    Text(
                      'Información Adicional (Opcional)',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),

                    // TODO: Implement Lot Selection/Creation
                    // TextFormField(
                    //   controller: _lotNumberController,
                    //   decoration: const InputDecoration(
                    //     labelText: 'Número de Lote',
                    //     border: OutlineInputBorder(),
                    //     prefixIcon: Icon(Icons.qr_code),
                    //     hintText: 'Ej: LOT-2024-001',
                    //   ),
                    // ),
                    const SizedBox(height: 16),

                    // Expiration Date
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _expirationDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 3650),
                          ),
                        );
                        if (picked != null) {
                          setState(() => _expirationDate = picked);
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Fecha de Vencimiento',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.event_busy),
                        ),
                        child: Text(
                          _expirationDate != null
                              ? '${_expirationDate!.day}/${_expirationDate!.month}/${_expirationDate!.year}'
                              : 'Sin fecha de vencimiento',
                          style: TextStyle(
                            color: _expirationDate != null
                                ? Colors.black
                                : Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Calculated Totals Preview
                    if (_quantityController.text.isNotEmpty &&
                        _unitCostController.text.isNotEmpty &&
                        double.tryParse(_quantityController.text) != null &&
                        double.tryParse(_unitCostController.text) != null) ...[
                      Card(
                        color: Theme.of(context).primaryColor.withAlpha(100),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Resumen',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Subtotal:'),
                                  Text(
                                    '\$${(double.parse(_quantityController.text) * double.parse(_unitCostController.text)).toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Impuestos:'),
                                  Text(
                                    '\$0.00',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'TOTAL:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    '\$${(double.parse(_quantityController.text) * double.parse(_unitCostController.text)).toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _saveItem,
                        icon: const Icon(Icons.save),
                        label: Text(
                          widget.itemId == null
                              ? 'Crear Artículo'
                              : 'Guardar Cambios',
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
