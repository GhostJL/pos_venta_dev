import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/purchase.dart';
import 'package:posventa/presentation/providers/purchase_filter_chip_provider.dart';

class PurchaseFilterChips extends ConsumerWidget {
  final PurchaseStatus? selectedFilter;
  const PurchaseFilterChips({super.key, required this.selectedFilter});

  static const _filters = {
    null: 'Todas',
    PurchaseStatus.pending: 'Pendientes',
    PurchaseStatus.partial: 'Parciales',
    PurchaseStatus.completed: 'Recibidas',
    PurchaseStatus.cancelled: 'Canceladas',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final entry = _filters.entries.elementAt(index);
          final status = entry.key;
          final label = entry.value;
          final isSelected = selectedFilter == status;

          return FilterChip(
            label: Text(label),
            selected: isSelected,
            onSelected: (selected) {
              ref.read(purchaseFilterProvider.notifier).state = selected
                  ? status
                  : null;
            },
            showCheckmark: false,
            labelStyle: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSurfaceVariant,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 4),
          );
        },
      ),
    );
  }
}
