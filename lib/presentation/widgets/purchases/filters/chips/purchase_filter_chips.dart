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
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: colorScheme.outlineVariant, width: 0.5),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _filters.entries.map((entry) {
            final status = entry.key;
            final label = entry.value;
            final isSelected = selectedFilter == status;
            final chipColor = _colors[status] ?? colorScheme.primary;

            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: ChoiceChip(
                label: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? chipColor : colorScheme.onSurface,
                  ),
                ),
                selected: isSelected,

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: isSelected ? chipColor : colorScheme.outlineVariant,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                checkmarkColor: chipColor,
                selectedShadowColor: chipColor,

                backgroundColor: colorScheme.surface,
                selectedColor: colorScheme.surface,

                labelPadding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 2,
                ),

                onSelected: (selected) {
                  ref.read(purchaseFilterProvider.notifier).state = selected
                      ? status
                      : null;
                },
                pressElevation: 0,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
