import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    PurchaseStatus.pending: Colors.orange,
    PurchaseStatus.partial: Colors.blue,
    PurchaseStatus.completed: Colors.green,
    PurchaseStatus.cancelled: Colors.red,
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
                    color: isSelected ? chipColor : Colors.grey.shade700,
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
                backgroundColor: Colors.grey.shade100,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: isSelected
                        ? chipColor ?? Theme.of(context).primaryColor
                        : Colors.grey.shade300,
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
