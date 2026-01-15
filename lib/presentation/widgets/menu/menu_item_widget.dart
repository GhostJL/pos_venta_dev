import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/core/config/menu_config.dart';

/// Widget para items del menú - Adaptable a tema claro/oscuro
class MenuItemWidget extends StatefulWidget {
  final MenuItem menuItem;
  final String currentPath;
  final VoidCallback? onTap;
  final bool isCollapsed;

  const MenuItemWidget({
    super.key,
    required this.menuItem,
    required this.currentPath,
    this.onTap,
    this.isCollapsed = false,
  });

  @override
  State<MenuItemWidget> createState() => _MenuItemWidgetState();
}

class _MenuItemWidgetState extends State<MenuItemWidget> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final currentUri = GoRouterState.of(context).uri;
    final String currentPath = currentUri.path;
    final String route = widget.menuItem.route;

    bool isSelected;
    // Strict match for root/home to prevent matching everything
    if (route == '/' || route == '/home') {
      isSelected = currentPath == route;
    } else {
      // Prefix matching for other routes (e.g. /products matches /products/form)
      isSelected = currentPath == route;
      if (!isSelected && currentPath.startsWith(route)) {
        // Check boundary to ensure exact path segment match
        if (route.endsWith('/') ||
            (currentPath.length > route.length &&
                currentPath[route.length] == '/')) {
          isSelected = true;
        }
      }
    }

    // Material 3 Styling
    final selectedColor = colorScheme.primaryContainer;
    final unselectedColor = Colors.transparent;
    final selectedOnColor = colorScheme.onPrimaryContainer;
    final unselectedOnColor = colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Tooltip(
        message: widget.isCollapsed ? widget.menuItem.title : '',
        waitDuration: const Duration(milliseconds: 500),
        child: Material(
          color: isSelected ? selectedColor : unselectedColor,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: () {
              if (widget.onTap != null) {
                widget.onTap!();
              } else {
                context.go(route);
                final scaffold = Scaffold.maybeOf(context);
                if (scaffold?.isDrawerOpen ?? false) {
                  scaffold!.closeDrawer();
                }
              }
            },
            borderRadius: BorderRadius.circular(12),
            hoverColor: colorScheme.onSurface.withValues(alpha: 0.08),
            splashColor: colorScheme.primary.withValues(alpha: 0.12),
            child: Container(
              height: 50, // Standard height for touch targets
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisAlignment: widget.isCollapsed
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.start,
                children: [
                  // Icon
                  Icon(
                    widget.menuItem.icon,
                    color: isSelected ? selectedOnColor : unselectedOnColor,
                    size: 22,
                  ),

                  // Text
                  if (!widget.isCollapsed) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.menuItem.title,
                        style: textTheme.labelLarge?.copyWith(
                          color: isSelected
                              ? selectedOnColor
                              : unselectedOnColor,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    // Badge (if any)
                    if (widget.menuItem.badgeCount != null &&
                        widget.menuItem.badgeCount! > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? colorScheme.primary
                              : colorScheme.error,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${widget.menuItem.badgeCount}',
                          style: textTheme.labelSmall?.copyWith(
                            color: isSelected
                                ? colorScheme.onPrimary
                                : colorScheme.onError,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
