import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/core/theme/theme.dart';
import 'package:posventa/domain/entities/purchase.dart';
import 'package:posventa/presentation/providers/purchase_filter_chip_provider.dart';

class PurchaseFilterChips extends ConsumerWidget {
  final PurchaseStatus? selectedFilter;
  const PurchaseFilterChips({super.key, required this.selectedFilter});

  static const _filters = {
    null: 'Todas',
    PurchaseStatus.pending: 'Pendiente',
    PurchaseStatus.partial: 'Parcial',
    PurchaseStatus.completed: 'Recibida',
    PurchaseStatus.cancelled: 'Cancelada',
  };

  static const _colors = {
    PurchaseStatus.pending: AppTheme.transactionPending,
    PurchaseStatus.partial: AppTheme.alertInfo,
    PurchaseStatus.completed: AppTheme.transactionSuccess,
    PurchaseStatus.cancelled: AppTheme.transactionFailed,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _filters.entries.map((entry) {
            final status = entry.key;
            final label = entry.value;
            final isSelected = selectedFilter == status;
            final chipColor = _colors[status];

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(
                  label,
                  style: TextStyle(
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: isSelected
                        ? chipColor
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  ref.read(purchaseFilterProvider.notifier).state = selected
                      ? status
                      : null;
                },
                selectedColor: chipColor?.withValues(alpha: 0.1),
                backgroundColor: Theme.of(context).colorScheme.outline,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: isSelected
                        ? chipColor ?? Theme.of(context).primaryColor
                        : Theme.of(context).colorScheme.outline,
                  ),
                ),
                pressElevation: 0,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
