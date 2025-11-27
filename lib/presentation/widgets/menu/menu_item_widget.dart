import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import 'package:posventa/core/theme/theme.dart';
import 'package:posventa/core/config/menu_config.dart';

/// Widget for rendering individual menu items with hover effects
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
    final bool isSelected = widget.currentPath == widget.menuItem.route;

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: SlideInLeft(
          duration: const Duration(milliseconds: 200),
          from: _isHovered && !isSelected ? -4 : 0,
          animate: true,
          child: Stack(
            children: [
              // Barra lateral izquierda para indicar selección
              if (isSelected)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: FadeIn(
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      width: 4,
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                leading: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    widget.menuItem.icon,
                    color: isSelected
                        ? AppTheme.primary
                        : _isHovered
                        ? AppTheme.primary.withValues(alpha: 0.7)
                        : AppTheme.textSecondary,
                    size: _isHovered ? 24 : 22,
                  ),
                ),
                title: Row(
                  children: [
                    Expanded(
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: isSelected
                              ? AppTheme.primary
                              : _isHovered
                              ? AppTheme.primary.withValues(alpha: 0.7)
                              : AppTheme.textPrimary,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                          fontSize: 14,
                        ),
                        child: Text(widget.menuItem.title),
                      ),
                    ),
                    if (widget.menuItem.badgeCount != null &&
                        widget.menuItem.badgeCount! > 0)
                      Pulse(
                        infinite: true,
                        duration: const Duration(seconds: 2),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.error,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${widget.menuItem.badgeCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                onTap:
                    widget.onTap ??
                    () {
                      context.go(widget.menuItem.route);
                      if (Scaffold.of(context).isDrawerOpen) {
                        Scaffold.of(context).closeDrawer();
                      }
                    },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                tileColor: isSelected
                    ? AppTheme.primary.withAlpha(15)
                    : _isHovered
                    ? AppTheme.primary.withAlpha(8)
                    : Colors.transparent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
