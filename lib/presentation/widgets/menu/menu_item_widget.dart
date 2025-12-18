import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/core/config/menu_config.dart';

/// Widget para items del menú - Adaptable a tema claro/oscuro
class MenuItemWidget extends StatefulWidget {
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
  State<MenuItemWidget> createState() => _MenuItemWidgetState();
}

class _MenuItemWidgetState extends State<MenuItemWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final currentPath = GoRouterState.of(context).uri.toString();
    final isSelected = currentPath == widget.menuItem.route;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 48, // Standard M3 Drawer item height
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primaryContainer
                : _isHovered
                ? colorScheme.onSurface.withValues(alpha: 0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(24), // Pill shape
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _handleTap(context),
              borderRadius: BorderRadius.circular(24),
              splashColor: colorScheme.onSurface.withValues(alpha: 0.1),
              highlightColor: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    // Icono
                    Icon(
                      widget.menuItem.icon,
                      size: 24, // M3 standard icon size
                      color: isSelected
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 12),
                    // Texto
                    Expanded(
                      child: Text(
                        widget.menuItem.title,
                        style: textTheme.labelLarge?.copyWith(
                          color: isSelected
                              ? colorScheme.onPrimaryContainer
                              : colorScheme.onSurface,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                    // Badge si existe
                    if (widget.menuItem.badgeCount != null &&
                        widget.menuItem.badgeCount! > 0)
                      _buildBadge(colorScheme),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(ColorScheme colorScheme) {
    return Container(
      constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: colorScheme.error,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          widget.menuItem.badgeCount! > 99
              ? '99+'
              : '${widget.menuItem.badgeCount}',
          style: TextStyle(
            color: colorScheme.onError,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            height: 1,
          ),
        ),
      ),
    );
  }

  void _handleTap(BuildContext context) {
    if (widget.onTap != null) {
      widget.onTap!();
    } else {
      context.go(widget.menuItem.route);
      final scaffold = Scaffold.maybeOf(context);
      if (scaffold?.isDrawerOpen ?? false) {
        scaffold!.closeDrawer();
      }
    }
  }
}
