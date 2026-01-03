import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/product_variant.dart';
import 'package:posventa/presentation/pages/products/matrix_generator/matrix_generator_controller.dart';

class VariantPreviewStep extends ConsumerStatefulWidget {
  final int productId;

  const VariantPreviewStep({super.key, required this.productId});

  @override
  ConsumerState<VariantPreviewStep> createState() => _VariantPreviewStepState();
}

class _VariantPreviewStepState extends ConsumerState<VariantPreviewStep> {
  final TextEditingController _bulkPriceController = TextEditingController();
  final TextEditingController _bulkCostController = TextEditingController();
  final TextEditingController _bulkStockController = TextEditingController();

  @override
  void dispose() {
    _bulkPriceController.dispose();
    _bulkCostController.dispose();
    _bulkStockController.dispose();
    super.dispose();
  }

  void _applyBulkPrice() {
    final val = double.tryParse(_bulkPriceController.text);
    if (val != null) {
      ref
          .read(matrixGeneratorProvider(widget.productId).notifier)
          .updateAllPrices(val);
      _bulkPriceController.clear();
    }
  }

  void _applyBulkCost() {
    final val = double.tryParse(_bulkCostController.text);
    if (val != null) {
      ref
          .read(matrixGeneratorProvider(widget.productId).notifier)
          .updateAllCosts(val);
      _bulkCostController.clear();
    }
  }

  void _applyBulkStock() {
    final val = double.tryParse(_bulkStockController.text);
    if (val != null) {
      ref
          .read(matrixGeneratorProvider(widget.productId).notifier)
          .updateAllStocks(val);
      _bulkStockController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(matrixGeneratorProvider(widget.productId));
    final theme = Theme.of(context);
    final variants = state.generatedVariants;

    // Use LayoutBuilder for responsiveness
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 800;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Paso 2: Previsualización y Edición',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Revisa las ${variants.length} variantes generadas. Puedes editar precios y stock de forma masiva o individual.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),

              // Bulk Edit Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(
                    alpha: 0.2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.colorScheme.primaryContainer),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.edit_note, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Edición Masiva',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
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
    );
  }

  Widget _buildDesktopBulkInputs() {
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
          child: _buildBulkField(_bulkCostController, 'Costo', _applyBulkCost),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildBulkField(
            _bulkStockController,
            'Stock Inicial',
            _applyBulkStock,
          ),
        ),
      ],
    );
  }

  Widget _buildMobileBulkInputs() {
    return Column(
      children: [
        _buildBulkField(_bulkPriceController, 'Precio Venta', _applyBulkPrice),
        const SizedBox(height: 12),
        _buildBulkField(_bulkCostController, 'Costo', _applyBulkCost),
        const SizedBox(height: 12),
        _buildBulkField(_bulkStockController, 'Stock Inicial', _applyBulkStock),
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
      child: SizedBox(
        width: double.infinity,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(
            theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          ),
          columns: const [
            DataColumn(label: Text('Variante')),
            DataColumn(label: Text('Precio')),
            DataColumn(label: Text('Costo')),
            DataColumn(label: Text('Stock')),
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
                          .read(
                            matrixGeneratorProvider(widget.productId).notifier,
                          )
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
                          .read(
                            matrixGeneratorProvider(widget.productId).notifier,
                          )
                          .updateVariant(index, updated);
                    },
                  ),
                ),
                DataCell(
                  _EditableCell(
                    key: ValueKey('stock_${index}_${variant.stock}'),
                    value: (variant.stock ?? 0).toStringAsFixed(0),
                    onChanged: (val) {
                      final d = double.tryParse(val) ?? 0;
                      final updated = variant.copyWith(stock: d);
                      ref
                          .read(
                            matrixGeneratorProvider(widget.productId).notifier,
                          )
                          .updateVariant(index, updated);
                    },
                  ),
                ),
              ],
            );
          }).toList(),
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
                                matrixGeneratorProvider(
                                  widget.productId,
                                ).notifier,
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
                                matrixGeneratorProvider(
                                  widget.productId,
                                ).notifier,
                              )
                              .updateVariant(index, updated);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _CompactInput(
                        key: ValueKey('stock_${index}_${variant.stock}'),
                        label: 'Stock',
                        value: (variant.stock ?? 0).toStringAsFixed(0),
                        onChanged: (val) {
                          final d = double.tryParse(val) ?? 0;
                          final updated = variant.copyWith(stock: d);
                          ref
                              .read(
                                matrixGeneratorProvider(
                                  widget.productId,
                                ).notifier,
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
