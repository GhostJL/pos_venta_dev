import 'package:flutter/material.dart';

class ChipFilterWidget extends StatelessWidget {
  final String label;
  final int activeFilterCount;
  final Function onSelected;
  const ChipFilterWidget({
    super.key,
    required this.label,
    required this.activeFilterCount,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: activeFilterCount > 0,
        onSelected: (selected) {
          if (selected) {
            onSelected();
          } else {
            onSelected();
          }
        },
        backgroundColor: Theme.of(context).colorScheme.surface,
        selectedColor: Theme.of(context).colorScheme.primary.withAlpha(50),
        checkmarkColor: Theme.of(context).colorScheme.primary,
        labelStyle: TextStyle(
          color: activeFilterCount > 0
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.bold,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide.none,
      ),
    );
  }
}
