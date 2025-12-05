import 'package:flutter/material.dart';
import 'custom_data_table_search_bar.dart';
import 'custom_data_table_action_button.dart';

class CustomDataTableHeader extends StatelessWidget {
  final String title;
  final int itemCount;
  final bool isSmallScreen;
  final ValueChanged<String>? onSearch;
  final VoidCallback onAddItem;

  const CustomDataTableHeader({
    super.key,
    required this.title,
    required this.itemCount,
    required this.isSmallScreen,
    required this.onSearch,
    required this.onAddItem,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isSmallScreen)
            _buildMobileLayout(context)
          else
            _buildDesktopLayout(context),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            _buildCountBadge(context),
          ],
        ),
        const SizedBox(height: 16),
        if (onSearch != null) ...[
          CustomDataTableSearchBar(onSearch: onSearch),
          const SizedBox(height: 16),
        ],
        SizedBox(
          width: double.infinity,
          child: CustomDataTableActionButton(onAddItem: onAddItem),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 24,
              ),
            ),
            const SizedBox(width: 12),
            _buildCountBadge(context),
          ],
        ),
        Row(
          children: [
            if (onSearch != null) ...[
              SizedBox(
                width: 250,
                child: CustomDataTableSearchBar(onSearch: onSearch),
              ),
              const SizedBox(width: 16),
            ],
            CustomDataTableActionButton(onAddItem: onAddItem),
          ],
        ),
      ],
    );
  }

  Widget _buildCountBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withAlpha(10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$itemCount',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
