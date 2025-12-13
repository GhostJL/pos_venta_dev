import 'package:flutter/material.dart';
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
              label: Text(
                '${taxRate.name} (${taxRate.rate}%)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
              selected: isSelected,
              onSelected: (_) => _toggleTax(taxRate),
              selectedColor: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outline,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              checkmarkColor: Theme.of(context).colorScheme.primary,
              selectedShadowColor: Theme.of(context).colorScheme.primary,

              backgroundColor: Theme.of(context).colorScheme.surface,

              labelPadding: const EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 2,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
