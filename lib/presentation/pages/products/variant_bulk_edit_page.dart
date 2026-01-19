import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/entities/product_variant.dart';
import 'package:posventa/presentation/providers/product_form_provider.dart';
import 'package:posventa/presentation/widgets/common/misc/barcode_scanner_widget.dart';

class VariantBulkEditPage extends ConsumerStatefulWidget {
  final Product product;
  final VariantType filterType;

  const VariantBulkEditPage({
    super.key,
    required this.product,
    this.filterType = VariantType.sales,
  });

  @override
  ConsumerState<VariantBulkEditPage> createState() =>
      _VariantBulkEditPageState();
}

class _VariantBulkEditPageState extends ConsumerState<VariantBulkEditPage> {
  // Sales Controllers
  final TextEditingController _bulkPriceController = TextEditingController();
  final TextEditingController _bulkCostController = TextEditingController();
  final TextEditingController _bulkWholesaleController =
      TextEditingController();
  final TextEditingController _bulkMinStockController = TextEditingController();
  final TextEditingController _bulkMaxStockController = TextEditingController();

  // Purchase Controllers
  final TextEditingController _bulkConversionController =
      TextEditingController();

  // Note: Purchase cost shares _bulkCostController

  @override
  void dispose() {
    _bulkPriceController.dispose();
    _bulkCostController.dispose();
    _bulkWholesaleController.dispose();
    _bulkMinStockController.dispose();
    _bulkMaxStockController.dispose();
    _bulkConversionController.dispose();
    super.dispose();
  }

  void _applyBulkUpdate(ProductVariant Function(ProductVariant) updateFn) {
    final notifier = ref.read(productFormProvider(widget.product).notifier);
    final state = ref.read(productFormProvider(widget.product));
    final allVariants = List<ProductVariant>.from(state.variants);
    bool changed = false;

    for (int i = 0; i < allVariants.length; i++) {
      if (allVariants[i].type == widget.filterType) {
        allVariants[i] = updateFn(allVariants[i]);
        changed = true;
      }
    }

    if (changed) {
      notifier.setVariants(allVariants);
    }
  }

  void _applyBulkPrice() {
    final val = double.tryParse(_bulkPriceController.text);
    if (val != null) {
      _applyBulkUpdate((v) => v.copyWith(priceCents: (val * 100).round()));
      _bulkPriceController.clear();
    }
  }

  void _applyBulkCost() {
    final val = double.tryParse(_bulkCostController.text);
    if (val != null) {
      _applyBulkUpdate((v) => v.copyWith(costPriceCents: (val * 100).round()));
      _bulkCostController.clear();
    }
  }

  void _applyBulkWholesale() {
    final val = double.tryParse(_bulkWholesaleController.text);
    if (val != null) {
      _applyBulkUpdate(
        (v) => v.copyWith(wholesalePriceCents: (val * 100).round()),
      );
      _bulkWholesaleController.clear();
    }
  }

  void _applyBulkMinStock() {
    final val = double.tryParse(_bulkMinStockController.text);
    if (val != null) {
      _applyBulkUpdate((v) => v.copyWith(stockMin: val));
      _bulkMinStockController.clear();
    }
  }

  void _applyBulkMaxStock() {
    final val = double.tryParse(_bulkMaxStockController.text);
    if (val != null) {
      _applyBulkUpdate((v) => v.copyWith(stockMax: val));
      _bulkMaxStockController.clear();
    }
  }

  void _applyBulkConversion() {
    final val = double.tryParse(_bulkConversionController.text);
    if (val != null) {
      _applyBulkUpdate((v) => v.copyWith(conversionFactor: val));
      _bulkConversionController.clear();
    }
  }

  String? _validateVariants(List<ProductVariant> variants) {
    if (variants.isEmpty) return 'No hay variantes para editar.';

    for (var variant in variants) {
      if (variant.type != widget.filterType) continue;

      if (widget.filterType == VariantType.sales) {
        if (variant.price <= 0) {
          return 'El precio de ${variant.variantName} debe ser mayor a 0';
        }
      } else {
        // Purchase Variants
        if (variant.costPrice <= 0) {
          return 'El costo de ${variant.variantName} debe ser mayor a 0';
        }
        if (variant.conversionFactor <= 0) {
          return 'El factor de conversión de ${variant.variantName} debe ser positivo';
        }
        if (variant.linkedVariantId == null) {
          return 'La variante ${variant.variantName} debe estar vinculada a un producto de venta';
        }
      }
    }
    return null;
  }

  Future<void> _handleSave() async {
    final state = ref.read(productFormProvider(widget.product));

    // Validate filtered variants
    final validationError = _validateVariants(state.variants);
    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(validationError),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    final success = await ref
        .read(productFormProvider(widget.product).notifier)
        .validateAndSubmit();

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cambios guardados correctamente'),
          backgroundColor: Colors.green,
        ),
      );
      // Use Navigator.pop to ensure compatibility if pushed via MaterialPageRoute
      Navigator.of(context).pop();
    } else if (mounted) {
      // Show form level error if save failed
      final error = ref.read(productFormProvider(widget.product)).error;
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = productFormProvider(widget.product);
    final state = ref.watch(provider);
    final theme = Theme.of(context);

    // Filter variants based on filterType
    final filteredIndexedVariants = state.variants
        .asMap()
        .entries
        .where((e) => e.value.type == widget.filterType)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.filterType == VariantType.sales
              ? 'Edición Masiva (Venta)'
              : 'Edición Masiva (Compra)',
        ),
        actions: [
          if (state.isModified && !state.isLoading)
            IconButton(icon: const Icon(Icons.save), onPressed: _handleSave),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth > 900;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Editar Variantes',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Edita precios y parámetros de las ${filteredIndexedVariants.length} variantes. Los cambios se aplicarán al guardar.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Bulk Edit Section
                      Card(
                        margin: EdgeInsets.zero,
                        clipBehavior: Clip.antiAlias,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: theme.colorScheme.primaryContainer,
                          ),
                        ),
                        color: theme.colorScheme.primaryContainer.withValues(
                          alpha: 0.2,
                        ),
                        child: ExpansionTile(
                          initiallyExpanded: false,
                          shape: const Border(),
                          collapsedShape: const Border(),
                          leading: Icon(
                            Icons.edit_note,
                            color: theme.colorScheme.primary,
                          ),
                          title: Text(
                            'Edición Masiva',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          childrenPadding: const EdgeInsets.fromLTRB(
                            16,
                            0,
                            16,
                            16,
                          ),
                          children: [
                            if (isDesktop)
                              _buildDesktopBulkInputs()
                            else
                              _buildMobileBulkInputs(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      if (filteredIndexedVariants.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Text('No hay variantes de este tipo.'),
                          ),
                        )
                      else
                        // Variants List/Table
                        isDesktop
                            ? _buildDesktopTable(filteredIndexedVariants, theme)
                            : _buildMobileList(filteredIndexedVariants, theme),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildDesktopBulkInputs() {
    if (widget.filterType == VariantType.sales) {
      return Row(
        children: [
          Expanded(
            child: _buildBulkField(
              _bulkPriceController,
              'Precio Venta',
              _applyBulkPrice,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildBulkField(
              _bulkCostController,
              'Costo',
              _applyBulkCost,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildBulkField(
              _bulkWholesaleController,
              'Mayoreo',
              _applyBulkWholesale,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildBulkField(
              _bulkMinStockController,
              'Min',
              _applyBulkMinStock,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildBulkField(
              _bulkMaxStockController,
              'Max',
              _applyBulkMaxStock,
            ),
          ),
        ],
      );
    } else {
      // Purchase Bulk Inputs
      return Row(
        children: [
          Expanded(
            child: _buildBulkField(
              _bulkCostController,
              'Costo Compra',
              _applyBulkCost,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildBulkField(
              _bulkConversionController,
              'Conversión',
              _applyBulkConversion,
            ),
          ),
          const Spacer(flex: 2),
        ],
      );
    }
  }

  Widget _buildMobileBulkInputs() {
    if (widget.filterType == VariantType.sales) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildBulkField(
                  _bulkPriceController,
                  'Precio Venta',
                  _applyBulkPrice,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildBulkField(
                  _bulkCostController,
                  'Costo',
                  _applyBulkCost,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildBulkField(
                  _bulkWholesaleController,
                  'Mayoreo',
                  _applyBulkWholesale,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildBulkField(
                  _bulkMinStockController,
                  'Min',
                  _applyBulkMinStock,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildBulkField(
                  _bulkMaxStockController,
                  'Max',
                  _applyBulkMaxStock,
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      // Purchase Mobile Bulk Settings
      return Row(
        children: [
          Expanded(
            child: _buildBulkField(
              _bulkCostController,
              'Costo',
              _applyBulkCost,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildBulkField(
              _bulkConversionController,
              'Conversión',
              _applyBulkConversion,
            ),
          ),
        ],
      );
    }
  }

  Widget _buildBulkField(
    TextEditingController controller,
    String label,
    VoidCallback onApply,
  ) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: const Icon(Icons.check_circle_outline),
          onPressed: onApply,
          tooltip: 'Aplicar a todos',
        ),
      ),
      onSubmitted: (_) => onApply(),
    );
  }

  Widget _buildDesktopTable(
    List<MapEntry<int, ProductVariant>> indexedVariants,
    ThemeData theme,
  ) {
    final isSales = widget.filterType == VariantType.sales;
    final state = ref.watch(productFormProvider(widget.product));
    final existingSalesVariants = state.variants
        .where((v) => v.type == VariantType.sales)
        .toList();

    TextStyle headerStyle(ThemeData theme) =>
        theme.textTheme.bodyMedium!.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurfaceVariant,
        );

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Header
          Container(
            color: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.5,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text('Variante', style: headerStyle(theme)),
                ),
                if (isSales) ...[
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: Text('Precio', style: headerStyle(theme)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: Text('Costo', style: headerStyle(theme)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: Text('Mayoreo', style: headerStyle(theme)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: Text('Min', style: headerStyle(theme)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: Text('Max', style: headerStyle(theme)),
                  ),
                ] else ...[
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: Text('Costo Compra', style: headerStyle(theme)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: Text('Conversión', style: headerStyle(theme)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 3,
                    child: Text('Código Barras', style: headerStyle(theme)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 3,
                    child: Text('Vinculado a', style: headerStyle(theme)),
                  ),
                ],
              ],
            ),
          ),
          // List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: indexedVariants.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
            itemBuilder: (context, listIndex) {
              final entry = indexedVariants[listIndex];
              final index = entry.key;
              final variant = entry.value;

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        variant.variantName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (isSales) ...[
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: _EditableCell(
                          key: ValueKey('price_${index}_${variant.price}'),
                          value: variant.price.toStringAsFixed(2),
                          onChanged: (val) {
                            final d = double.tryParse(val) ?? 0;
                            final updated = variant.copyWith(
                              priceCents: (d * 100).round(),
                            );
                            ref
                                .read(
                                  productFormProvider(widget.product).notifier,
                                )
                                .updateVariant(index, updated);
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: _EditableCell(
                          key: ValueKey('cost_${index}_${variant.costPrice}'),
                          value: variant.costPrice.toStringAsFixed(2),
                          onChanged: (val) {
                            final d = double.tryParse(val) ?? 0;
                            final updated = variant.copyWith(
                              costPriceCents: (d * 100).round(),
                            );
                            ref
                                .read(
                                  productFormProvider(widget.product).notifier,
                                )
                                .updateVariant(index, updated);
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: _EditableCell(
                          key: ValueKey(
                            'wholesale_${index}_${variant.wholesalePriceCents}',
                          ),
                          value:
                              (variant.wholesalePriceCents != null
                                      ? variant.wholesalePriceCents! / 100.0
                                      : 0.0)
                                  .toStringAsFixed(2),
                          onChanged: (val) {
                            final d = double.tryParse(val) ?? 0;
                            final updated = variant.copyWith(
                              wholesalePriceCents: (d * 100).round(),
                            );
                            ref
                                .read(
                                  productFormProvider(widget.product).notifier,
                                )
                                .updateVariant(index, updated);
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 1,
                        child: _EditableCell(
                          key: ValueKey('min_${index}_${variant.stockMin}'),
                          value: (variant.stockMin ?? 0).toStringAsFixed(0),
                          onChanged: (val) {
                            final d = double.tryParse(val) ?? 0;
                            final updated = variant.copyWith(stockMin: d);
                            ref
                                .read(
                                  productFormProvider(widget.product).notifier,
                                )
                                .updateVariant(index, updated);
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 1,
                        child: _EditableCell(
                          key: ValueKey('max_${index}_${variant.stockMax}'),
                          value: (variant.stockMax ?? 0).toStringAsFixed(0),
                          onChanged: (val) {
                            final d = double.tryParse(val) ?? 0;
                            final updated = variant.copyWith(stockMax: d);
                            ref
                                .read(
                                  productFormProvider(widget.product).notifier,
                                )
                                .updateVariant(index, updated);
                          },
                        ),
                      ),
                    ] else ...[
                      // Purchase Cells
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: _EditableCell(
                          key: ValueKey('cost_${index}_${variant.costPrice}'),
                          value: variant.costPrice.toStringAsFixed(2),
                          onChanged: (val) {
                            final d = double.tryParse(val) ?? 0;
                            final updated = variant.copyWith(
                              costPriceCents: (d * 100).round(),
                            );
                            ref
                                .read(
                                  productFormProvider(widget.product).notifier,
                                )
                                .updateVariant(index, updated);
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: _EditableCell(
                          key: ValueKey(
                            'factor_${index}_${variant.conversionFactor}',
                          ),
                          value: variant.conversionFactor.toStringAsFixed(2),
                          onChanged: (val) {
                            final d = double.tryParse(val) ?? 1.0;
                            final updated = variant.copyWith(
                              conversionFactor: d,
                            );
                            ref
                                .read(
                                  productFormProvider(widget.product).notifier,
                                )
                                .updateVariant(index, updated);
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 3,
                        child: _EditableCell(
                          key: ValueKey('barcode_${index}_${variant.barcode}'),
                          value: variant.barcode ?? '',
                          isNumeric: false,
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.qr_code_scanner, size: 18),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => BarcodeScannerWidget(
                                    onBarcodeScanned: (context, code) {
                                      final updated = variant.copyWith(
                                        barcode: code,
                                      );
                                      ref
                                          .read(
                                            productFormProvider(
                                              widget.product,
                                            ).notifier,
                                          )
                                          .updateVariant(index, updated);
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                          onChanged: (val) {
                            final updated = variant.copyWith(
                              barcode: val.isEmpty ? null : val,
                            );
                            ref
                                .read(
                                  productFormProvider(widget.product).notifier,
                                )
                                .updateVariant(index, updated);
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 3,
                        child: DropdownButton<int>(
                          value: variant.linkedVariantId,
                          isExpanded: true,
                          hint: const Text('Sin vinculo'),
                          underline: const SizedBox(),
                          items: [
                            const DropdownMenuItem<int>(
                              value: null,
                              child: Text('Sin vinculo'),
                            ),
                            ...existingSalesVariants.map(
                              (v) => DropdownMenuItem<int>(
                                value: v.id,
                                child: Text(
                                  v.variantName,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                          onChanged: (val) {
                            final updated = variant.copyWith(
                              linkedVariantId: val,
                            );
                            ref
                                .read(
                                  productFormProvider(widget.product).notifier,
                                )
                                .updateVariant(index, updated);
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMobileList(
    List<MapEntry<int, ProductVariant>> indexedVariants,
    ThemeData theme,
  ) {
    final isSales = widget.filterType == VariantType.sales;
    final state = ref.watch(productFormProvider(widget.product));
    final existingSalesVariants = state.variants
        .where((v) => v.type == VariantType.sales)
        .toList();

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: indexedVariants.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, listIndex) {
        final entry = indexedVariants[listIndex];
        final index = entry.key;
        final variant = entry.value;

        return Card(
          elevation: 0,
          color: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: theme.colorScheme.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  variant.variantName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                if (isSales) ...[
                  Row(
                    children: [
                      Expanded(
                        child: _CompactInput(
                          key: ValueKey('price_${index}_${variant.price}'),
                          label: 'Precio',
                          value: variant.price.toStringAsFixed(2),
                          onChanged: (val) {
                            final d = double.tryParse(val) ?? 0;
                            final updated = variant.copyWith(
                              priceCents: (d * 100).round(),
                            );
                            ref
                                .read(
                                  productFormProvider(widget.product).notifier,
                                )
                                .updateVariant(index, updated);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _CompactInput(
                          key: ValueKey('cost_${index}_${variant.costPrice}'),
                          label: 'Costo',
                          value: variant.costPrice.toStringAsFixed(2),
                          onChanged: (val) {
                            final d = double.tryParse(val) ?? 0;
                            final updated = variant.copyWith(
                              costPriceCents: (d * 100).round(),
                            );
                            ref
                                .read(
                                  productFormProvider(widget.product).notifier,
                                )
                                .updateVariant(index, updated);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _CompactInput(
                          key: ValueKey(
                            'wholesale_${index}_${variant.wholesalePriceCents}',
                          ),
                          label: 'Mayoreo',
                          value:
                              (variant.wholesalePriceCents != null
                                      ? variant.wholesalePriceCents! / 100.0
                                      : 0.0)
                                  .toStringAsFixed(2),
                          onChanged: (val) {
                            final d = double.tryParse(val) ?? 0;
                            final updated = variant.copyWith(
                              wholesalePriceCents: (d * 100).round(),
                            );
                            ref
                                .read(
                                  productFormProvider(widget.product).notifier,
                                )
                                .updateVariant(index, updated);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _CompactInput(
                          key: ValueKey('min_${index}_${variant.stockMin}'),
                          label: 'Min',
                          value: (variant.stockMin ?? 0).toStringAsFixed(0),
                          onChanged: (val) {
                            final d = double.tryParse(val) ?? 0;
                            final updated = variant.copyWith(stockMin: d);
                            ref
                                .read(
                                  productFormProvider(widget.product).notifier,
                                )
                                .updateVariant(index, updated);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _CompactInput(
                          key: ValueKey('max_${index}_${variant.stockMax}'),
                          label: 'Max',
                          value: (variant.stockMax ?? 0).toStringAsFixed(0),
                          onChanged: (val) {
                            final d = double.tryParse(val) ?? 0;
                            final updated = variant.copyWith(stockMax: d);
                            ref
                                .read(
                                  productFormProvider(widget.product).notifier,
                                )
                                .updateVariant(index, updated);
                          },
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  // Purchase Mobile
                  Row(
                    children: [
                      Expanded(
                        child: _CompactInput(
                          key: ValueKey('cost_${index}_${variant.costPrice}'),
                          label: 'Costo',
                          value: variant.costPrice.toStringAsFixed(2),
                          onChanged: (val) {
                            final d = double.tryParse(val) ?? 0;
                            final updated = variant.copyWith(
                              costPriceCents: (d * 100).round(),
                            );
                            ref
                                .read(
                                  productFormProvider(widget.product).notifier,
                                )
                                .updateVariant(index, updated);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _CompactInput(
                          key: ValueKey(
                            'factor_${index}_${variant.conversionFactor}',
                          ),
                          label: 'Conversión',
                          value: variant.conversionFactor.toStringAsFixed(2),
                          onChanged: (val) {
                            final d = double.tryParse(val) ?? 1.0;
                            final updated = variant.copyWith(
                              conversionFactor: d,
                            );
                            ref
                                .read(
                                  productFormProvider(widget.product).notifier,
                                )
                                .updateVariant(index, updated);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _CompactInput(
                    key: ValueKey('barcode_${index}_${variant.barcode}'),
                    label: 'Código Barras',
                    value: variant.barcode ?? '',
                    isNumeric: false,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.qr_code_scanner),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => BarcodeScannerWidget(
                              onBarcodeScanned: (context, code) {
                                final updated = variant.copyWith(barcode: code);
                                ref
                                    .read(
                                      productFormProvider(
                                        widget.product,
                                      ).notifier,
                                    )
                                    .updateVariant(index, updated);
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                        );
                      },
                    ),
                    onChanged: (val) {
                      final updated = variant.copyWith(
                        barcode: val.isEmpty ? null : val,
                      );
                      ref
                          .read(productFormProvider(widget.product).notifier)
                          .updateVariant(index, updated);
                    },
                  ),
                  const SizedBox(height: 8),
                  InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Vincular a',
                      isDense: true,
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: variant.linkedVariantId,
                        isDense: true,
                        items: [
                          const DropdownMenuItem<int>(
                            value: null,
                            child: Text('Sin vínculo'),
                          ),
                          ...existingSalesVariants.map(
                            (v) => DropdownMenuItem<int>(
                              value: v.id,
                              child: Text(
                                v.variantName,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                        onChanged: (val) {
                          final updated = variant.copyWith(
                            linkedVariantId: val,
                          );
                          ref
                              .read(
                                productFormProvider(widget.product).notifier,
                              )
                              .updateVariant(index, updated);
                        },
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EditableCell extends StatefulWidget {
  final String value;
  final ValueChanged<String> onChanged;
  final bool isNumeric;
  final Widget? suffixIcon;

  const _EditableCell({
    super.key,
    required this.value,
    required this.onChanged,
    this.isNumeric = true,
    this.suffixIcon,
  });

  @override
  State<_EditableCell> createState() => _EditableCellState();
}

class _EditableCellState extends State<_EditableCell> {
  late TextEditingController _controller;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant _EditableCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _controller.text && !_controller.selection.isValid) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      widget.onChanged(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      keyboardType: widget.isNumeric
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      decoration: InputDecoration(
        isDense: true,
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
        suffixIcon: widget.suffixIcon,
      ),
      onChanged: _onChanged,
    );
  }
}

class _CompactInput extends StatefulWidget {
  final String label;
  final String value;
  final ValueChanged<String> onChanged;
  final bool isNumeric;
  final Widget? suffixIcon;

  const _CompactInput({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.isNumeric = true,
    this.suffixIcon,
  });

  @override
  State<_CompactInput> createState() => _CompactInputState();
}

class _CompactInputState extends State<_CompactInput> {
  late TextEditingController _controller;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant _CompactInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update if value changed externally and not focused?
    // Simplified: update if value mismatches strongly, but careful not to overwrite typing.
    // Ideally we rely on local state while typing.
    if (widget.value != _controller.text && !_controller.selection.isValid) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      widget.onChanged(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      keyboardType: widget.isNumeric
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      decoration: InputDecoration(
        labelText: widget.label,
        isDense: true,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        suffixIcon: widget.suffixIcon,
      ),
      onChanged: _onChanged,
    );
  }
}
