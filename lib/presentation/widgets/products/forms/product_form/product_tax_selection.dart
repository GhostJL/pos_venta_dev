import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/entities/product_tax.dart';
import 'package:posventa/domain/entities/tax_rate.dart';
import 'package:posventa/presentation/providers/product_form_provider.dart';
import 'package:posventa/presentation/providers/tax_rate_provider.dart';

/// Widget for tax selection with chips
class ProductTaxSelection extends ConsumerWidget {
  final Product? product;

  const ProductTaxSelection({super.key, required this.product});

  void _toggleTax(
    WidgetRef ref,
    List<TaxRate> taxRates,
    TaxRate taxRate,
    List<ProductTax> currentSelectedTaxes,
  ) {
    final newTaxes = List<ProductTax>.from(currentSelectedTaxes);
    final existingIndex = newTaxes.indexWhere((t) => t.taxRateId == taxRate.id);
    final isExempt =
        taxRate.rate == 0 && taxRate.name.toLowerCase().contains('exento');

    if (existingIndex >= 0) {
      // Deselecting
      newTaxes.removeAt(existingIndex);
    } else {
      // Selecting
      if (isExempt) {
        // If exempt is selected, clear everything else
        newTaxes.clear();
        newTaxes.add(ProductTax(taxRateId: taxRate.id!, applyOrder: 1));
      } else {
        // If normal tax is selected, exclude exempt if present
        final exemptTaxIds = taxRates
            .where(
              (t) => t.rate == 0 && t.name.toLowerCase().contains('exento'),
            )
            .map((t) => t.id)
            .toSet();

        newTaxes.removeWhere((t) => exemptTaxIds.contains(t.taxRateId));

        newTaxes.add(
          ProductTax(taxRateId: taxRate.id!, applyOrder: newTaxes.length + 1),
        );
      }
    }

    ref.read(productFormProvider(product).notifier).setTaxes(newTaxes);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = productFormProvider(product);
    final selectedTaxes = ref.watch(provider.select((s) => s.selectedTaxes));
    final taxRatesAsync = ref.watch(taxRateListProvider);

    return taxRatesAsync.when(
      data: (taxRates) {
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
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (_) =>
                      _toggleTax(ref, taxRates, taxRate, selectedTaxes),
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
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Text('Error al cargar impuestos: $e'),
    );
  }
}
