import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/entities/product_tax.dart' as pt;

import 'package:posventa/presentation/providers/product_form_provider.dart';
import 'package:posventa/presentation/providers/tax_rate_provider.dart';
import 'package:posventa/presentation/widgets/products/forms/product_form/product_basic_info_section.dart';
import 'package:posventa/presentation/widgets/products/forms/product_form/product_classification_section.dart';
import 'package:posventa/presentation/widgets/products/forms/product_form/product_tax_selection.dart';
import 'package:posventa/presentation/widgets/products/forms/product_form/product_variants_list.dart';
import 'package:posventa/presentation/widgets/products/forms/product_form/product_pricing_section.dart';
import 'package:posventa/presentation/widgets/products/forms/product_form/product_inventory_section.dart';

import 'package:posventa/domain/entities/product_variant.dart';
import 'package:posventa/domain/entities/unit_of_measure.dart';
import 'package:posventa/presentation/providers/unit_providers.dart';
import 'package:posventa/presentation/widgets/common/selection_sheet.dart';

class ProductFormPage extends ConsumerStatefulWidget {
  final Product? product;

  const ProductFormPage({super.key, this.product});

  @override
  ProductFormPageState createState() => ProductFormPageState();
}

class ProductFormPageState extends ConsumerState<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _codeController;
  late TextEditingController _barcodeController;
  late TextEditingController _descriptionController;

  // Controllers required for ProductPricingSection (hidden in this view)
  late TextEditingController _costController;
  late TextEditingController _priceController;
  late TextEditingController _wholesaleController;

  // Controllers for Inventory (Simple Product)
  late TextEditingController _stockController;
  late TextEditingController _minStockController;
  late TextEditingController _maxStockController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();

    // Listeners to sync with provider
    final notifier = ref.read(productFormProvider(widget.product).notifier);
    _nameController.addListener(() {
      notifier.setName(_nameController.text);
    });
    _codeController.addListener(() {
      notifier.setCode(_codeController.text);
    });
    _barcodeController.addListener(() {
      notifier.setBarcode(_barcodeController.text);
    });
    _descriptionController.addListener(() {
      notifier.setDescription(_descriptionController.text);
    });

    if (widget.product == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializeDefaultTaxes();
      });
    }
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.product?.name);
    _codeController = TextEditingController(text: widget.product?.code);
    _barcodeController = TextEditingController(text: widget.product?.barcode);
    _descriptionController = TextEditingController(
      text: widget.product?.description,
    );
    // Initialize with empty or existing values if available (though prices not shown here)
    ProductVariant? defaultVariant;
    if (widget.product?.variants != null &&
        widget.product!.variants!.isNotEmpty) {
      defaultVariant = widget.product!.variants!.first;
    }

    _costController = TextEditingController(
      text: defaultVariant != null
          ? (defaultVariant.costPriceCents / 100).toStringAsFixed(2)
          : '',
    );
    _priceController = TextEditingController(
      text: defaultVariant != null
          ? (defaultVariant.priceCents / 100).toStringAsFixed(2)
          : '',
    );
    _wholesaleController = TextEditingController(
      text: defaultVariant?.wholesalePriceCents != null
          ? (defaultVariant!.wholesalePriceCents! / 100).toStringAsFixed(2)
          : '',
    );

    _stockController = TextEditingController(
      text: defaultVariant != null ? _formatDouble(defaultVariant.stock) : '',
    );
    _minStockController = TextEditingController(
      text: defaultVariant != null
          ? _formatDouble(defaultVariant.stockMin)
          : '',
    );
    _maxStockController = TextEditingController(
      text: defaultVariant != null
          ? _formatDouble(defaultVariant.stockMax)
          : '',
    );
  }

  String _formatDouble(double? value) {
    if (value == null) return '';
    return value.toString().replaceAll(RegExp(r'\.0$'), ''); // Remove .0
  }

  void _initializeDefaultTaxes() {
    final taxRates = ref.read(taxRateListProvider).asData?.value;
    if (taxRates != null) {
      final defaultTaxes = taxRates.where((t) => t.isDefault).toList();
      final notifier = ref.read(productFormProvider(widget.product).notifier);

      final currentTaxes = ref
          .read(productFormProvider(widget.product))
          .selectedTaxes;
      if (currentTaxes.isEmpty) {
        final newTaxes = defaultTaxes
            .map((tax) => pt.ProductTax(taxRateId: tax.id!, applyOrder: 1))
            .toList();
        for (int i = 0; i < newTaxes.length; i++) {
          newTaxes[i] = newTaxes[i].copyWith(applyOrder: i + 1);
        }
        notifier.setTaxes(newTaxes);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _barcodeController.dispose();
    _descriptionController.dispose();
    _costController.dispose();
    _priceController.dispose();
    _wholesaleController.dispose();
    _stockController.dispose();
    _minStockController.dispose();
    _maxStockController.dispose();
    super.dispose();
  }

  // Helper for Item Selection
  Future<void> _showSelectionSheet<T>({
    required BuildContext context,
    required String title,
    required List<T> items,
    required String Function(T) labelBuilder,
    T? selectedItem,
    required ValueChanged<T?> onSelected,
    VoidCallback? onAdd,
  }) async {
    final result = await showModalBottomSheet<SelectionSheetResult<T>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SelectionSheet<T>(
        title: title,
        items: items,
        itemLabelBuilder: labelBuilder,
        selectedItem: selectedItem,
        areEqual: (a, b) => labelBuilder(a) == labelBuilder(b),
        onAdd: onAdd,
      ),
    );

    if (result != null) {
      if (result.isCleared) {
        onSelected(null);
      } else if (result.value != null) {
        onSelected(result.value);
      }
    }
  }

  // helpers removed

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Por favor, corrija los errores marcados en el formulario.',
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final notifier = ref.read(productFormProvider(widget.product).notifier);

    // State is already sync'd via listeners
    await notifier.validateAndSubmit(
      price: double.tryParse(_priceController.text),
      cost: double.tryParse(_costController.text),
      wholesale: double.tryParse(_wholesaleController.text),
      stock: double.tryParse(_stockController.text),
      minStock: double.tryParse(_minStockController.text),
      maxStock: double.tryParse(_maxStockController.text),
    );
  }

  void _onEditVariant(ProductVariant variant, int index) async {
    final result = await context.push<ProductVariant>(
      '/product-form/variant',
      extra: {
        'variant': variant,
        'productId': widget.product?.id ?? 0,
        'productName': _nameController.text,
        'availableVariants': ref
            .read(productFormProvider(widget.product))
            .variants,
      },
    );

    if (result != null) {
      if (widget.product != null) {
        // Existing Product: Refresh from DB to sync changes (variant saved directly)
        ref.read(productFormProvider(widget.product).notifier).refreshFromDb();
      } else {
        // New Product: Update local list
        ref
            .read(productFormProvider(widget.product).notifier)
            .updateVariant(index, result);
      }
    }
  }

  void _onAddVariant(VariantType type) async {
    final result = await context.push<ProductVariant>(
      '/product-form/variant',
      extra: {
        'productId': widget.product?.id ?? 0,
        'productName': _nameController.text,
        'initialType': type,
        'availableVariants': ref
            .read(productFormProvider(widget.product))
            .variants,
      },
    );

    if (result != null) {
      if (widget.product != null) {
        // Existing Product: Refresh from DB
        ref.read(productFormProvider(widget.product).notifier).refreshFromDb();
      } else {
        // New Product: Add to local list
        ref
            .read(productFormProvider(widget.product).notifier)
            .addVariant(result);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = productFormProvider(widget.product);
    final state = ref.watch(provider);
    final isLoading = state.isLoading;
    final isNewProduct = widget.product == null;
    final theme = Theme.of(context);
    final isModified = state.isModified;
    final isVariable = state.isVariableProduct;

    // Listen for success or error
    ref.listen<ProductFormState>(provider, (previous, next) {
      if (next.error != null && (previous?.error != next.error)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: theme.colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      if (next.isSuccess && (previous?.isSuccess != true)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isNewProduct ? 'Producto Creado' : 'Producto Actualizado',
            ),
            backgroundColor: theme.colorScheme.secondary,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 1),
          ),
        );
        context.pop();
      }
    });

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            isNewProduct ? 'Nuevo Producto' : 'Editar Producto',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              const Tab(text: 'General'),
              const Tab(text: 'Precios e Impuestos'),
              Tab(text: isVariable ? 'Variantes' : 'Inventario'),
            ],
          ),
          actions: [
            if (isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else if (isModified)
              TextButton(
                onPressed: _submit,
                child: Text(
                  'GUARDAR',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: TabBarView(
              children: [
                // TAB 1: GENERAL
                SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Mode Toggle (Crucial Decision First)
                      Center(
                        child: ToggleButtons(
                          borderRadius: BorderRadius.circular(12),
                          constraints: BoxConstraints(
                            minWidth:
                                (MediaQuery.of(context).size.width - 48 - 6) /
                                2,
                            minHeight: 40,
                          ),
                          isSelected: [!isVariable, isVariable],
                          onPressed: (index) {
                            ref
                                .read(provider.notifier)
                                .setVariableProduct(index == 1);
                          },
                          children: const [
                            Text('Producto Simple'),
                            Text('Con Variantes'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      ProductBasicInfoSection(
                        nameController: _nameController,
                        codeController: _codeController,
                        barcodeController: _barcodeController,
                        descriptionController: _descriptionController,
                        imageFile: ref.watch(
                          provider.select((s) => s.imageFile),
                        ),
                        photoUrl: ref.watch(provider.select((s) => s.photoUrl)),
                        onImageSelected: ref.read(provider.notifier).pickImage,
                        onRemoveImage: ref.read(provider.notifier).removeImage,
                      ),
                      const SizedBox(height: 16),
                      Consumer(
                        builder: (context, ref, _) {
                          final isActive = ref.watch(
                            provider.select((s) => s.isActive),
                          );
                          return SwitchListTile(
                            title: const Text('Producto Activo'),
                            subtitle: const Text(
                              'Disponible para venta y operaciones',
                            ),
                            value: isActive,
                            onChanged: ref.read(provider.notifier).setActive,
                            contentPadding: EdgeInsets.zero,
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      ProductClassificationSection(product: widget.product),
                    ],
                  ),
                ),

                // TAB 2: PRICES & TAXES
                SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      if (!isVariable) ...[
                        ProductPricingSection(
                          product: widget.product,
                          costPriceController: _costController,
                          salePriceController: _priceController,
                          wholesalePriceController: _wholesaleController,
                        ),
                        const SizedBox(height: 24),
                      ] else
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondaryContainer
                                .withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: theme.colorScheme.secondary,
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'Los precios se gestionan individualmente en cada variante.',
                                  style: TextStyle(fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 24),
                      // UNIT & WEIGHT (Common config)
                      Consumer(
                        builder: (context, ref, _) {
                          final unitsAsync = ref.watch(unitListProvider);
                          final provider = productFormProvider(widget.product);
                          final selectedUnitId = ref.watch(
                            provider.select((s) => s.unitId),
                          );

                          return unitsAsync.when(
                            data: (units) {
                              final selectedUnit = units
                                  .cast<UnitOfMeasure?>()
                                  .firstWhere(
                                    (u) => u?.id == selectedUnitId,
                                    orElse: () => null,
                                  );

                              return SelectionField(
                                label: 'Unidad de Medida',
                                placeholder: 'Seleccionar unidad',
                                value: selectedUnit?.name,
                                helperText: 'Unidad de venta (ej. Pieza, Kg)',
                                prefixIcon: Icons.scale_rounded,
                                onTap: () => _showSelectionSheet<UnitOfMeasure>(
                                  context: context,
                                  title: 'Seleccionar Unidad',
                                  items: units,
                                  labelBuilder: (u) => '${u.name} (${u.code})',
                                  selectedItem: selectedUnit,
                                  onSelected: (u) => ref
                                      .read(provider.notifier)
                                      .setUnitId(u?.id),
                                ),
                                onClear: () =>
                                    ref.read(provider.notifier).setUnitId(null),
                              );
                            },
                            loading: () => SelectionField(
                              label: 'Unidad de Medida',
                              isLoading: true,
                              onTap: () {},
                            ),
                            error: (e, s) => Text('Error: $e'),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      Consumer(
                        builder: (context, ref, _) {
                          final isSoldByWeight = ref.watch(
                            provider.select((s) => s.isSoldByWeight),
                          );
                          return SwitchListTile(
                            title: const Text('Venta a granel / Por peso'),
                            subtitle: const Text(
                              'Habilita la captura de peso/cantidad en POS',
                            ),
                            value: isSoldByWeight,
                            onChanged: ref
                                .read(provider.notifier)
                                .setSoldByWeight,
                            contentPadding: EdgeInsets.zero,
                          );
                        },
                      ),

                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 24),

                      // TAXES
                      Consumer(
                        builder: (context, ref, child) {
                          final usesTaxes = ref.watch(
                            provider.select((s) => s.usesTaxes),
                          );
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SwitchListTile(
                                title: const Text('¿Aplica Impuestos?'),
                                value: usesTaxes,
                                onChanged: (value) => ref
                                    .read(provider.notifier)
                                    .setUsesTaxes(value),
                                contentPadding: EdgeInsets.zero,
                              ),
                              if (usesTaxes) ...[
                                const SizedBox(height: 8),
                                ProductTaxSelection(product: widget.product),
                              ],
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // TAB 3: INVENTORY OR VARIANTS
                SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      if (!isVariable) ...[
                        ProductInventorySection(
                          product: widget.product,
                          stockController: _stockController,
                          minStockController: _minStockController,
                          maxStockController: _maxStockController,
                        ),
                      ] else ...[
                        ProductVariantsList(
                          product: widget.product,
                          onAddVariant: _onAddVariant,
                          onEditVariant: _onEditVariant,
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () =>
                                    _onAddVariant(VariantType.sales),
                                icon: const Icon(Icons.add_rounded),
                                label: const Text('Venta'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: isNewProduct
                                    ? () {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Guarda el producto primero para agregar variantes de compra.',
                                            ),
                                          ),
                                        );
                                      }
                                    : () => _onAddVariant(VariantType.purchase),
                                icon: const Icon(
                                  Icons.add_shopping_cart_rounded,
                                ),
                                label: const Text('Compra'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Methods removed
}
