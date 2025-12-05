import 'package:flutter/material.dart';

class CustomDataTableEmptyState extends StatelessWidget {
  final String emptyText;
  final bool isSmallScreen;

  const CustomDataTableEmptyState({
    super.key,
    required this.emptyText,
    required this.isSmallScreen,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(isSmallScreen ? 40.0 : 80.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.surface,
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              size: 48,
              color: Theme.of(
                context,
              ).colorScheme.onSurfaceVariant.withAlpha(100),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            emptyText,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Comienza agregando un nuevo elemento a la lista',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
