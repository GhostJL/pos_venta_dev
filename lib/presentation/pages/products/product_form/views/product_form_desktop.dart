import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/entities/product_variant.dart';
import 'package:posventa/domain/entities/unit_of_measure.dart';
import 'package:posventa/presentation/pages/products/product_form/product_form_controllers.dart';
import 'package:posventa/presentation/providers/product_form_provider.dart';
import 'package:posventa/presentation/providers/settings_provider.dart';
import 'package:posventa/presentation/providers/unit_providers.dart';
import 'package:posventa/presentation/widgets/common/selection_sheet.dart';
import 'package:posventa/presentation/widgets/products/forms/product_form/product_basic_info_section.dart';
import 'package:posventa/presentation/widgets/products/forms/product_form/product_classification_section.dart';
import 'package:posventa/presentation/widgets/products/forms/product_form/product_inventory_section.dart';
import 'package:posventa/presentation/widgets/products/forms/product_form/product_pricing_section.dart';
import 'package:posventa/presentation/widgets/products/forms/product_form/product_tax_selection.dart';
import 'package:posventa/presentation/widgets/products/forms/product_form/product_variants_list.dart';

class ProductFormDesktop extends ConsumerWidget {
  final Product? product;
  final ProductFormControllers controllers;
  final GlobalKey<FormState> formKey;
  final VoidCallback onSubmit;
  final Function(ProductVariant variant, int index) onEditVariant;
  final Function(VariantType type) onAddVariant;
  final VoidCallback onGenerateVariants;

  const ProductFormDesktop({
    super.key,
    required this.product,
    required this.controllers,
    required this.formKey,
    required this.onSubmit,
    required this.onEditVariant,
    required this.onAddVariant,
    required this.onGenerateVariants,
  });

  Future<void> _showSelectionSheet<T>({
    required BuildContext context,
    required String title,
    required List<T> items,
    required String Function(T) labelBuilder,
    T? selectedItem,
    required ValueChanged<T?> onSelected,
  }) async {
    // For Desktop, we could use a Dialog instead of a BottomSheet
    final result = await showDialog<SelectionSheetResult<T>>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
          child: SelectionSheet<T>(
            title: title,
            items: items,
            itemLabelBuilder: labelBuilder,
            selectedItem: selectedItem,
            areEqual: (a, b) => labelBuilder(a) == labelBuilder(b),
          ),
        ),
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = productFormProvider(product);
    final state = ref.watch(provider);
    final isNewProduct = product == null || product?.id == null;
    final theme = Theme.of(context);
    final isVariable = state.isVariableProduct;

    final settingsAsync = ref.watch(settingsProvider);
    final useInventory = settingsAsync.value?.useInventory ?? true;
    final useTax = settingsAsync.value?.useTax ?? true;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isNewProduct ? 'Nuevo Producto' : 'Editar Producto',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (state.isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: FilledButton.icon(
                onPressed: state.isModified ? onSubmit : null,
                icon: const Icon(Icons.save),
                label: const Text('GUARDAR'),
              ),
            ),
        ],
      ),
      body: Form(
        key: formKey,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // LEFT COLUMN: Basic Info & Classification
            Expanded(
              flex: 4,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    _buildCard(
                      context,
                      title: 'Información Básica',
                      child: Column(
                        children: [
                          // Mode Toggle
                          Center(
                            child: ToggleButtons(
                              borderRadius: BorderRadius.circular(8),
                              constraints: const BoxConstraints(
                                minWidth: 120,
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
                            product: product,
                            nameController: controllers.nameController,
                            codeController: controllers.codeController,
                            barcodeController: controllers.barcodeController,
                            descriptionController:
                                controllers.descriptionController,
                            imageFile: ref.watch(
                              provider.select((s) => s.imageFile),
                            ),
                            photoUrl: ref.watch(
                              provider.select((s) => s.photoUrl),
                            ),
                            onImageSelected: ref
                                .read(provider.notifier)
                                .pickImage,
                            onRemoveImage: ref
                                .read(provider.notifier)
                                .removeImage,
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
                                onChanged: ref
                                    .read(provider.notifier)
                                    .setActive,
                                contentPadding: EdgeInsets.zero,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildCard(
                      context,
                      title: 'Clasificación',
                      child: ProductClassificationSection(product: product),
                    ),
                  ],
                ),
              ),
            ),

            // RIGHT COLUMN: Pricing, Inventory, Taxes
            Expanded(
              flex: 5,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    if (!isVariable) ...[
                      _buildCard(
                        context,
                        title: 'Precios',
                        child: ProductPricingSection(
                          product: product,
                          costPriceController: controllers.costController,
                          salePriceController: controllers.priceController,
                          wholesalePriceController:
                              controllers.wholesaleController,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildCard(
                        context,
                        title: 'Unidad y Peso',
                        child: Column(
                          children: [
                            Consumer(
                              builder: (context, ref, _) {
                                final unitsAsync = ref.watch(unitListProvider);
                                final provider = productFormProvider(product);
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
                                      helperText:
                                          'Unidad de venta (ej. Pieza, Kg)',
                                      prefixIcon: Icons.scale_rounded,
                                      onTap: () =>
                                          _showSelectionSheet<UnitOfMeasure>(
                                            context: context,
                                            title: 'Seleccionar Unidad',
                                            items: units,
                                            labelBuilder: (u) =>
                                                '${u.name} (${u.code})',
                                            selectedItem: selectedUnit,
                                            onSelected: (u) => ref
                                                .read(provider.notifier)
                                                .setUnitId(u?.id),
                                          ),
                                      onClear: () => ref
                                          .read(provider.notifier)
                                          .setUnitId(null),
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
                                  title: const Text(
                                    'Venta a granel / Por peso',
                                  ),
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
                          ],
                        ),
                      ),
                    ] else
                      _buildCard(
                        context,
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: theme.colorScheme.secondary,
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Precios, costos, unidades y control de peso se gestionan individualmente en cada variante.',
                                style: TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 16),

                    if (useInventory && !isVariable)
                      _buildCard(
                        context,
                        title: 'Inventario',
                        child: ProductInventorySection(
                          product: product,
                          stockController: controllers.stockController,
                          minStockController: controllers.minStockController,
                          maxStockController: controllers.maxStockController,
                        ),
                      ),

                    if (isVariable)
                      _buildCard(
                        context,
                        title: 'Variantes',
                        child: Column(
                          children: [
                            ProductVariantsList(
                              product: product,
                              onAddVariant: onAddVariant,
                              onEditVariant: onEditVariant,
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.tonalIcon(
                                onPressed: onGenerateVariants,
                                icon: const Icon(Icons.auto_awesome),
                                label: const Text(
                                  'Generar Combinaciones (Matriz)',
                                ),
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () =>
                                        onAddVariant(VariantType.sales),
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
                                        : () => onAddVariant(
                                            VariantType.purchase,
                                          ),
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
                        ),
                      ),

                    if (useTax) ...[
                      const SizedBox(height: 16),
                      _buildCard(
                        context,
                        title: 'Impuestos',
                        child: Consumer(
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
                                  ProductTaxSelection(product: product),
                                ],
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    String? title,
    required Widget child,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
            ],
            child,
          ],
        ),
      ),
    );
  }
}
