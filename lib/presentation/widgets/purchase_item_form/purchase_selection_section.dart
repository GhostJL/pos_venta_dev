import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/presentation/providers/purchase_providers.dart';

class PurchaseSelectionSection extends ConsumerWidget {
  final int? selectedPurchaseId;
  final ValueChanged<int?> onChanged;

  const PurchaseSelectionSection({
    super.key,
    required this.selectedPurchaseId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final purchasesAsync = ref.watch(purchaseProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Compra Asociada', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        DropdownButtonFormField<int>(
          initialValue: selectedPurchaseId,
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
          onChanged: onChanged,
          validator: (value) => value == null ? 'Requerido' : null,
        ),
      ],
    );
  }
}
