import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/entities/product_variant.dart';
import 'package:posventa/presentation/providers/product_form_provider.dart';

class VariantBulkEditPage extends ConsumerStatefulWidget {
  final Product product;

  const VariantBulkEditPage({super.key, required this.product});

  @override
  ConsumerState<VariantBulkEditPage> createState() =>
      _VariantBulkEditPageState();
}

class _VariantBulkEditPageState extends ConsumerState<VariantBulkEditPage> {
  final TextEditingController _bulkPriceController = TextEditingController();
  final TextEditingController _bulkCostController = TextEditingController();
  final TextEditingController _bulkWholesaleController =
      TextEditingController();
  final TextEditingController _bulkMinStockController = TextEditingController();
  final TextEditingController _bulkMaxStockController = TextEditingController();

  @override
  void dispose() {
    _bulkPriceController.dispose();
    _bulkCostController.dispose();
    _bulkWholesaleController.dispose();
    _bulkMinStockController.dispose();
    _bulkMaxStockController.dispose();
    super.dispose();
  }

  void _applyBulkPrice() {
    final val = double.tryParse(_bulkPriceController.text);
    if (val != null) {
      ref
          .read(productFormProvider(widget.product).notifier)
          .updateAllPrices(val);
      _bulkPriceController.clear();
    }
  }

  void _applyBulkCost() {
    final val = double.tryParse(_bulkCostController.text);
    if (val != null) {
      ref
          .read(productFormProvider(widget.product).notifier)
          .updateAllCosts(val);
      _bulkCostController.clear();
    }
  }

  void _applyBulkWholesale() {
    final val = double.tryParse(_bulkWholesaleController.text);
    if (val != null) {
      ref
          .read(productFormProvider(widget.product).notifier)
          .updateAllWholesalePrices(val);
      _bulkWholesaleController.clear();
    }
  }

  void _applyBulkMinStock() {
    final val = double.tryParse(_bulkMinStockController.text);
    if (val != null) {
      ref
          .read(productFormProvider(widget.product).notifier)
          .updateAllMinStocks(val);
      _bulkMinStockController.clear();
    }
  }

  void _applyBulkMaxStock() {
    final val = double.tryParse(_bulkMaxStockController.text);
    if (val != null) {
      ref
          .read(productFormProvider(widget.product).notifier)
          .updateAllMaxStocks(val);
      _bulkMaxStockController.clear();
    }
  }

  Future<void> _handleSave() async {
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
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = productFormProvider(widget.product);
    final state = ref.watch(provider);
    final theme = Theme.of(context);
    final variants = state.variants;
    final isModified = state.isModified;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edición Masiva'),
        actions: [
          if (isModified && !state.isLoading)
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
                        'Edita precios y parámetros de las ${variants.length} variantes. Los cambios se aplicarán al guardar.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Bulk Edit Section
                      Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer.withValues(
                            alpha: 0.1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.colorScheme.primaryContainer
                                .withValues(alpha: 0.5),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.edit_note,
                                    color: theme.colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Aplicar a todos',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                          color: theme.colorScheme.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            if (isDesktop)
                              _buildDesktopBulkInputs()
                            else
                              _buildMobileBulkInputs(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Variants List/Table
                      if (isDesktop)
                        _buildDesktopTable(variants, theme)
                      else
                        _buildMobileList(variants, theme),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildDesktopBulkInputs() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
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
            ],
          ),
        ),
        const SizedBox(height: 8),
        ExpansionTile(
          title: const Text('Ediciones Adicionales'),
          subtitle: const Text('Mayoreo y Límites de Stock'),
          childrenPadding: const EdgeInsets.all(16),
          initiallyExpanded: false,
          children: [
            Row(
              children: [
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
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMobileBulkInputs() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              _buildBulkField(
                _bulkPriceController,
                'Precio Venta',
                _applyBulkPrice,
              ),
              const SizedBox(height: 12),
              _buildBulkField(_bulkCostController, 'Costo', _applyBulkCost),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ExpansionTile(
          title: const Text('Ediciones Adicionales'),
          childrenPadding: const EdgeInsets.all(16),
          initiallyExpanded: false,
          children: [
            _buildBulkField(
              _bulkWholesaleController,
              'Mayoreo',
              _applyBulkWholesale,
            ),
            const SizedBox(height: 12),
            _buildBulkField(_bulkMinStockController, 'Min', _applyBulkMinStock),
            const SizedBox(height: 12),
            _buildBulkField(_bulkMaxStockController, 'Max', _applyBulkMaxStock),
          ],
        ),
      ],
    );
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

  Widget _buildDesktopTable(List<ProductVariant> variants, ThemeData theme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Container(
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(
              theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            ),
            columnSpacing: 24,
            columns: const [
              DataColumn(label: Text('Variante')),
              DataColumn(label: Text('Precio')),
              DataColumn(label: Text('Costo')),
              DataColumn(label: Text('Mayoreo')),
              DataColumn(label: Text('Min')),
              DataColumn(label: Text('Max')),
            ],
            rows: variants.asMap().entries.map((entry) {
              final index = entry.key;
              final variant = entry.value;
              return DataRow(
                cells: [
                  DataCell(
                    Text(
                      variant.variantName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataCell(
                    _EditableCell(
                      key: ValueKey('price_${index}_${variant.price}'),
                      value: variant.price.toStringAsFixed(2),
                      onChanged: (val) {
                        final d = double.tryParse(val) ?? 0;
                        final updated = variant.copyWith(
                          priceCents: (d * 100).round(),
                        );
                        ref
                            .read(productFormProvider(widget.product).notifier)
                            .updateVariant(index, updated);
                      },
                    ),
                  ),
                  DataCell(
                    _EditableCell(
                      key: ValueKey('cost_${index}_${variant.costPrice}'),
                      value: variant.costPrice.toStringAsFixed(2),
                      onChanged: (val) {
                        final d = double.tryParse(val) ?? 0;
                        final updated = variant.copyWith(
                          costPriceCents: (d * 100).round(),
                        );
                        ref
                            .read(productFormProvider(widget.product).notifier)
                            .updateVariant(index, updated);
                      },
                    ),
                  ),
                  DataCell(
                    _EditableCell(
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
                            .read(productFormProvider(widget.product).notifier)
                            .updateVariant(index, updated);
                      },
                    ),
                  ),
                  DataCell(
                    _EditableCell(
                      key: ValueKey('min_${index}_${variant.stockMin}'),
                      value: (variant.stockMin ?? 0).toStringAsFixed(0),
                      onChanged: (val) {
                        final d = double.tryParse(val) ?? 0;
                        final updated = variant.copyWith(stockMin: d);
                        ref
                            .read(productFormProvider(widget.product).notifier)
                            .updateVariant(index, updated);
                      },
                    ),
                  ),
                  DataCell(
                    _EditableCell(
                      key: ValueKey('max_${index}_${variant.stockMax}'),
                      value: (variant.stockMax ?? 0).toStringAsFixed(0),
                      onChanged: (val) {
                        final d = double.tryParse(val) ?? 0;
                        final updated = variant.copyWith(stockMax: d);
                        ref
                            .read(productFormProvider(widget.product).notifier)
                            .updateVariant(index, updated);
                      },
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileList(List<ProductVariant> variants, ThemeData theme) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: variants.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final variant = variants[index];
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
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EditableCell extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _EditableCell({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: const InputDecoration(
        isDense: true,
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(vertical: 8),
      ),
      onFieldSubmitted: onChanged,
    );
  }
}

class _CompactInput extends StatelessWidget {
  final String label;
  final String value;
  final ValueChanged<String> onChanged;

  const _CompactInput({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
      onFieldSubmitted: onChanged,
    );
  }
}
