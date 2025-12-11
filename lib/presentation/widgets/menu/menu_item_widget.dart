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
    final currentPath = GoRouterState.of(context).uri.toString();
    final isSelected = currentPath == widget.menuItem.route;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: MouseRegion(
        onEnter: (_) {
          if (mounted) setState(() => _isHovered = true);
        },
        onExit: (_) {
          if (mounted) setState(() => _isHovered = false);
        },
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            // Fondo adaptado al tema
            color: isSelected
                ? colorScheme.primary.withValues(alpha: 0.12)
                : _isHovered
                ? colorScheme.primary.withValues(alpha: 0.06)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: colorScheme.shadow.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _handleTap(context),
              borderRadius: BorderRadius.circular(12),
              splashColor: colorScheme.primary.withValues(alpha: 0.08),
              highlightColor: colorScheme.primary.withValues(alpha: 0.05),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 11,
                ),
                child: Row(
                  children: [
                    // Icono
                    Icon(
                      widget.menuItem.icon,
                      size: 20,
                      color: isSelected
                          ? colorScheme.onSurface
                          : _isHovered
                          ? colorScheme.onSurface.withValues(alpha: 0.7)
                          : colorScheme.onSurface,
                    ),
                    const SizedBox(width: 12),
                    // Texto
                    Expanded(
                      child: Text(
                        widget.menuItem.title,
                        style: TextStyle(
                          color: isSelected
                              ? colorScheme.onSurface
                              : colorScheme.onSurface,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          fontSize: 14,
                          letterSpacing: -0.1,
                        ),
                      ),
                    ),
                    // Indicador de selección
                    if (isSelected)
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colorScheme.onSurface,
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.4,
                              ),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      )
                    // Badge si existe
                    else if (widget.menuItem.badgeCount != null &&
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
