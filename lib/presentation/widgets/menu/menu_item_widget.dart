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

    // Material 3 State Colors
    final backgroundColor = isSelected
        ? colorScheme.secondaryContainer
        : _isHovered
        ? colorScheme.onSurface.withValues(alpha: 0.08)
        : Colors.transparent;

    final foregroundColor = isSelected
        ? colorScheme.onSecondaryContainer
        : colorScheme.onSurfaceVariant;

    final iconColor = isSelected
        ? colorScheme.onSecondaryContainer
        : colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 4,
      ), // Increased vertical spacing slightly
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          // height: 56, // Let it size itself
          decoration: ShapeDecoration(
            color: backgroundColor,
            shape: StadiumBorder(
              side: isSelected
                  ? BorderSide(
                      color: colorScheme.secondaryContainer.withValues(
                        alpha: 0.5,
                      ),
                      width: 1,
                    )
                  : BorderSide.none,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _handleTap(context),
              customBorder: const StadiumBorder(),
              splashColor: colorScheme.onSurface.withValues(alpha: 0.1),
              highlightColor: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                ), // Increased horizontal padding
                child: Row(
                  children: [
                    // Icono
                    Icon(widget.menuItem.icon, size: 24, color: iconColor),
                    const SizedBox(width: 12),
                    // Texto
                    Expanded(
                      child: Text(
                        widget.menuItem.title,
                        style: textTheme.labelLarge?.copyWith(
                          color: foregroundColor,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                          letterSpacing: 0.5,
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
