import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/product_variant.dart';
import 'package:posventa/presentation/pages/products/matrix_generator/matrix_generator_controller.dart';
import 'package:posventa/presentation/widgets/common/misc/barcode_scanner_widget.dart';

class VariantPreviewStep extends ConsumerStatefulWidget {
  final int productId;
  final VariantType targetType;
  final List<ProductVariant> existingVariants;

  const VariantPreviewStep({
    super.key,
    required this.productId,
    this.targetType = VariantType.sales,
    this.existingVariants = const [],
  });

  @override
  ConsumerState<VariantPreviewStep> createState() => _VariantPreviewStepState();
}

class _VariantPreviewStepState extends ConsumerState<VariantPreviewStep> {
  final TextEditingController _bulkPriceController = TextEditingController();
  final TextEditingController _bulkCostController = TextEditingController();
  final TextEditingController _bulkWholesaleController =
      TextEditingController();
  final TextEditingController _bulkMinStockController = TextEditingController();
  final TextEditingController _bulkMaxStockController = TextEditingController();
  final TextEditingController _bulkConversionController =
      TextEditingController();

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

  void _applyBulkWholesale() {
    final val = double.tryParse(_bulkWholesaleController.text);
    if (val != null) {
      ref
          .read(matrixGeneratorProvider(widget.productId).notifier)
          .updateAllWholesalePrices(val);
      _bulkWholesaleController.clear();
    }
  }

  void _applyBulkMinStock() {
    final val = double.tryParse(_bulkMinStockController.text);
    if (val != null) {
      ref
          .read(matrixGeneratorProvider(widget.productId).notifier)
          .updateAllMinStocks(val);
      _bulkMinStockController.clear();
    }
  }

  void _applyBulkMaxStock() {
    final val = double.tryParse(_bulkMaxStockController.text);
    if (val != null) {
      ref
          .read(matrixGeneratorProvider(widget.productId).notifier)
          .updateAllMaxStocks(val);
      _bulkMaxStockController.clear();
    }
  }

  void _applyBulkConversion() {
    final val = double.tryParse(_bulkConversionController.text);
    if (val != null) {
      ref
          .read(matrixGeneratorProvider(widget.productId).notifier)
          .updateAllConversionFactors(val);
      _bulkConversionController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(matrixGeneratorProvider(widget.productId));
    final variants = state.generatedVariants;
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Revisar y Editar Variantes Generadas (${variants.length})',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.targetType == VariantType.sales
                      ? 'Ajusta precios y stock antes de confirmar.'
                      : 'Ajusta costos, códigos y factores de conversión.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),

                // Bulk Edit Section
                Card(
                  margin: EdgeInsets.zero,
                  clipBehavior: Clip.antiAlias,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: theme.colorScheme.primaryContainer),
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
                    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    children: [
                      if (isDesktop)
                        _buildDesktopBulkInputs()
                      else
                        _buildMobileBulkInputs(),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),

          if (variants.isEmpty)
            const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text('No hay variantes generadas'),
                ),
              ),
            )
          else if (isDesktop)
            SliverToBoxAdapter(child: _buildDesktopTable(variants, theme))
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) =>
                    _buildMobileItem(context, index, variants, theme),
                childCount: variants.length,
              ),
            ),

          // Bottom padding
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  Widget _buildDesktopBulkInputs() {
    if (widget.targetType == VariantType.sales) {
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
      // Purchase Variant Bulk Inputs
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
    if (widget.targetType == VariantType.sales) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildBulkField(
                  _bulkPriceController,
                  'Precio',
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
      // Purchase Mobile Inputs
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

  Widget _buildDesktopTable(List<ProductVariant> variants, ThemeData theme) {
    final isSales = widget.targetType == VariantType.sales;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: SizedBox(
        width: double.infinity,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(
              theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            ),
            columns: [
              const DataColumn(label: Text('Variante')),
              if (isSales) ...const [
                DataColumn(label: Text('Precio')),
                DataColumn(label: Text('Costo')),
                DataColumn(label: Text('Mayoreo')),
                DataColumn(label: Text('Min')),
                DataColumn(label: Text('Max')),
              ] else ...const [
                DataColumn(label: Text('Costo Compra')),
                DataColumn(label: Text('Conversión')),
                DataColumn(label: Text('Código Barras')),
                DataColumn(label: Text('Vinculado a')),
              ],
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
                  if (isSales) ...[
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
                                matrixGeneratorProvider(
                                  widget.productId,
                                ).notifier,
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
                                matrixGeneratorProvider(
                                  widget.productId,
                                ).notifier,
                              )
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
                              .read(
                                matrixGeneratorProvider(
                                  widget.productId,
                                ).notifier,
                              )
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
                              .read(
                                matrixGeneratorProvider(
                                  widget.productId,
                                ).notifier,
                              )
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
                              .read(
                                matrixGeneratorProvider(
                                  widget.productId,
                                ).notifier,
                              )
                              .updateVariant(index, updated);
                        },
                      ),
                    ),
                  ] else ...[
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
                                matrixGeneratorProvider(
                                  widget.productId,
                                ).notifier,
                              )
                              .updateVariant(index, updated);
                        },
                      ),
                    ),
                    DataCell(
                      _EditableCell(
                        key: ValueKey(
                          'factor_${index}_${variant.conversionFactor}',
                        ),
                        value: variant.conversionFactor.toStringAsFixed(2),
                        onChanged: (val) {
                          final d = double.tryParse(val) ?? 1.0;
                          final updated = variant.copyWith(conversionFactor: d);
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
                    DataCell(
                      _EditableCell(
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
                                          matrixGeneratorProvider(
                                            widget.productId,
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
                                matrixGeneratorProvider(
                                  widget.productId,
                                ).notifier,
                              )
                              .updateVariant(index, updated);
                        },
                      ),
                    ),
                    DataCell(
                      DropdownButton<int>(
                        value: variant.linkedVariantId,
                        hint: const Text('Sin vinculo'),
                        underline: const SizedBox(),
                        items: [
                          const DropdownMenuItem<int>(
                            value: null,
                            child: Text('Sin vinculo'),
                          ),
                          ...widget.existingVariants
                              .where((v) => v.type == VariantType.sales)
                              .map(
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
                                matrixGeneratorProvider(
                                  widget.productId,
                                ).notifier,
                              )
                              .updateVariant(index, updated);
                        },
                      ),
                    ),
                  ],
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileItem(
    BuildContext context,
    int index,
    List<ProductVariant> variants,
    ThemeData theme,
  ) {
    final isSales = widget.targetType == VariantType.sales;
    final variant = variants[index];

    return Card(
      elevation: 0,
      color: theme.colorScheme.surface,
      margin: const EdgeInsets.only(bottom: 12),
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
                      key: ValueKey('max_${index}_${variant.stockMax}'),
                      label: 'Max',
                      value: (variant.stockMax ?? 0).toStringAsFixed(0),
                      onChanged: (val) {
                        final d = double.tryParse(val) ?? 0;
                        final updated = variant.copyWith(stockMax: d);
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
            ] else ...[
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
                      key: ValueKey(
                        'factor_${index}_${variant.conversionFactor}',
                      ),
                      label: 'Conversión',
                      value: variant.conversionFactor.toStringAsFixed(2),
                      onChanged: (val) {
                        final d = double.tryParse(val) ?? 1.0;
                        final updated = variant.copyWith(conversionFactor: d);
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
              const SizedBox(height: 8),
              _CompactInput(
                key: ValueKey('barcode_${index}_${variant.barcode}'),
                label: 'Código Barras',
                value: variant.barcode ?? '',
                onChanged: (val) {
                  final updated = variant.copyWith(
                    barcode: val.isEmpty ? null : val,
                  );
                  ref
                      .read(matrixGeneratorProvider(widget.productId).notifier)
                      .updateVariant(index, updated);
                },
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
                                  matrixGeneratorProvider(
                                    widget.productId,
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
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                initialValue: variant.linkedVariantId,
                decoration: const InputDecoration(
                  labelText: 'Vincular a',
                  isDense: true,
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                items: [
                  const DropdownMenuItem<int>(
                    value: null,
                    child: Text('Sin vínculo'),
                  ),
                  ...widget.existingVariants
                      .where((v) => v.type == VariantType.sales)
                      .map(
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
                  final updated = variant.copyWith(linkedVariantId: val);
                  ref
                      .read(matrixGeneratorProvider(widget.productId).notifier)
                      .updateVariant(index, updated);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EditableCell extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value,
      keyboardType: isNumeric
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      decoration: InputDecoration(
        isDense: true,
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
        suffixIcon: suffixIcon,
      ),
      onFieldSubmitted: onChanged,
    );
  }
}

class _CompactInput extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value,
      keyboardType: isNumeric
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        suffixIcon: suffixIcon,
      ),
      onFieldSubmitted: onChanged,
    );
  }
}
