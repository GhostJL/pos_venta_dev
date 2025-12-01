import 'package:flutter/material.dart';
import 'package:posventa/core/theme/theme.dart';
import 'package:posventa/domain/entities/product_tax.dart';
import 'package:posventa/domain/entities/tax_rate.dart';

/// Widget for tax selection with chips
class ProductTaxSelection extends StatelessWidget {
  final List<TaxRate> taxRates;
  final List<ProductTax> selectedTaxes;
  final ValueChanged<List<ProductTax>> onTaxesChanged;

  const ProductTaxSelection({
    super.key,
    required this.taxRates,
    required this.selectedTaxes,
    required this.onTaxesChanged,
  });

  void _toggleTax(TaxRate taxRate) {
    final newTaxes = List<ProductTax>.from(selectedTaxes);
    final existingIndex = newTaxes.indexWhere((t) => t.taxRateId == taxRate.id);

    if (existingIndex >= 0) {
      newTaxes.removeAt(existingIndex);
    } else {
      newTaxes.add(
        ProductTax(taxRateId: taxRate.id!, applyOrder: newTaxes.length + 1),
      );
    }

    onTaxesChanged(newTaxes);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Impuestos Aplicables',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: taxRates.map((taxRate) {
            final isSelected = selectedTaxes.any(
              (t) => t.taxRateId == taxRate.id,
            );
            return FilterChip(
              label: Text('${taxRate.name} (${taxRate.rate}%)'),
              selected: isSelected,
              onSelected: (_) => _toggleTax(taxRate),
              selectedColor: AppTheme.primary.withOpacity(0.2),
              checkmarkColor: AppTheme.primary,
            );
          }).toList(),
        ),
      ],
    );
  }
}
