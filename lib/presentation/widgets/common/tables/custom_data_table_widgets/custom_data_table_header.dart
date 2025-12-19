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
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isSmallScreen)
            _buildMobileLayout(context, theme)
          else
            _buildDesktopLayout(context, theme),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, ThemeData theme) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            _buildCountBadge(context, theme),
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

  Widget _buildDesktopLayout(BuildContext context, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(width: 16),
            _buildCountBadge(context, theme),
          ],
        ),
        Row(
          children: [
            if (onSearch != null) ...[
              SizedBox(
                width: 300,
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

  Widget _buildCountBadge(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withAlpha(150),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$itemCount',
        style: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}
