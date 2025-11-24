import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/core/theme/theme.dart';
import 'package:posventa/core/config/menu_config.dart';

/// Widget for rendering individual menu items
class MenuItemWidget extends StatelessWidget {
  final MenuItem menuItem;
  final String currentPath;
  final VoidCallback? onTap;

  const MenuItemWidget({
    super.key,
    required this.menuItem,
    required this.currentPath,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSelected = currentPath == menuItem.route;

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Icon(
          menuItem.icon,
          color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
          size: 22,
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                menuItem.title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isSelected ? AppTheme.primary : AppTheme.textPrimary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
            if (menuItem.badgeCount != null && menuItem.badgeCount! > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.error,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${menuItem.badgeCount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        onTap:
            onTap ??
            () {
              context.go(menuItem.route);
              if (Scaffold.of(context).isDrawerOpen) {
                Scaffold.of(context).closeDrawer();
              }
            },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: isSelected
            ? AppTheme.primary.withAlpha(15)
            : Colors.transparent,
        hoverColor: AppTheme.primary.withAlpha(5),
      ),
    );
  }
}
