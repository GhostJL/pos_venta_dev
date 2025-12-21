import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/core/config/menu_config.dart';
import 'package:posventa/presentation/widgets/menu/menu_item_widget.dart';
import 'package:posventa/presentation/providers/menu_state_provider.dart';

/// Widget para grupos de menú - usa colorScheme en lugar de colores fijos
class MenuGroupWidget extends ConsumerStatefulWidget {
  final MenuGroup menuGroup;
  final String currentPath;

  const MenuGroupWidget({
    super.key,
    required this.menuGroup,
    required this.currentPath,
  });

  @override
  ConsumerState<MenuGroupWidget> createState() => _MenuGroupWidgetState();
}

class _MenuGroupWidgetState extends ConsumerState<MenuGroupWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _isHovered = false;
  bool? _previousExpandedState;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final hasSelected = _hasSelectedItem();
      if (hasSelected) {
        ref
            .read(menuStateProvider.notifier)
            .setExpandedGroup(widget.menuGroup.id);
      }

      final isExpanded =
          ref.read(menuStateProvider).expandedGroupId == widget.menuGroup.id;
      _controller.value = isExpanded ? 1.0 : 0.0;
      _previousExpandedState = isExpanded;
    });
  }

  @override
  void didUpdateWidget(covariant MenuGroupWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.currentPath != widget.currentPath) {
      if (_hasSelectedItem() && !_isCurrentlyExpanded()) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          ref
              .read(menuStateProvider.notifier)
              .setExpandedGroup(widget.menuGroup.id);
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _hasSelectedItem() {
    return widget.menuGroup.items.any(
      (item) => widget.currentPath.startsWith(item.route),
    );
  }

  bool _isCurrentlyExpanded() {
    return ref.read(menuStateProvider).expandedGroupId == widget.menuGroup.id;
  }

  void _updateAnimation(bool isExpanded) {
    if (_previousExpandedState == isExpanded) return;

    _previousExpandedState = isExpanded;

    if (isExpanded) {
      if (_controller.status != AnimationStatus.forward &&
          _controller.status != AnimationStatus.completed) {
        _controller.forward();
      }
    } else {
      if (_controller.status != AnimationStatus.reverse &&
          _controller.status != AnimationStatus.dismissed) {
        _controller.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final bool isRouteActive =
        widget.menuGroup.route != null &&
        widget.currentPath.startsWith(widget.menuGroup.route!);

    final isExpanded = ref.watch(
      menuStateProvider.select(
        (state) => state.expandedGroupId == widget.menuGroup.id,
      ),
    );

    // Use active state for styling if it's a direct link
    final isActive = isRouteActive || isExpanded;

    _updateAnimation(isExpanded);

    // M3 Colors for Group Header
    final headerColor = isActive
        ? colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.5,
          ) // Subtle highlight for open group
        : _isHovered
        ? colorScheme.onSurface.withValues(alpha: 0.08)
        : Colors.transparent;

    final headerTextColor = isActive
        ? colorScheme.onSurface
        : colorScheme.onSurfaceVariant;

    final iconColor = isActive
        ? colorScheme.primary
        : colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 4,
      ), // Consistent vertical spacing
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header del grupo
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: MouseRegion(
              onEnter: (_) => setState(() => _isHovered = true),
              onExit: (_) => setState(() => _isHovered = false),
              cursor: SystemMouseCursors.click,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                height: 56, // Match MenuItem height
                decoration: ShapeDecoration(
                  color: headerColor,
                  shape: const StadiumBorder(),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      if (widget.menuGroup.route != null) {
                        GoRouter.of(context).go(widget.menuGroup.route!);
                      } else {
                        ref
                            .read(menuStateProvider.notifier)
                            .toggleGroup(widget.menuGroup.id);
                      }
                    },
                    customBorder: const StadiumBorder(),
                    splashColor: colorScheme.onSurface.withValues(alpha: 0.1),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                      ), // Match MenuItem padding
                      child: Row(
                        children: [
                          if (widget.menuGroup.groupIcon != null) ...[
                            Icon(
                              widget.menuGroup.groupIcon,
                              size: 24,
                              color: iconColor,
                            ),
                            const SizedBox(width: 12),
                          ],
                          Expanded(
                            child: Text(
                              widget.menuGroup.title,
                              style: textTheme.labelLarge?.copyWith(
                                // Use labelLarge like items
                                color: headerTextColor,
                                fontWeight: isActive
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          if (widget.menuGroup.route == null)
                            Icon(
                              isExpanded
                                  ? Icons.expand_less_rounded
                                  : Icons.expand_more_rounded,
                              size: 24,
                              color: iconColor,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Items del grupo (sin línea, solo indentación)
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity, height: 0),
            secondChild: Padding(
              padding: const EdgeInsets.only(
                top: 2,
              ), // Small gap between header and children
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: widget.menuGroup.items
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(
                          left: 0,
                        ), // Flat list look, indentation handled by item itself being generic? No, keeping distinct list.
                        // Ideally strictly following M3 drawer groups, items are just items.
                        // But here we want indentation to show hierarchy.
                        // Let's add left padding to the wrapper of MenuItemWidget?
                        // Or just render them.
                        // Actually, M3 guidelines often show nested items with same left alignment but maybe different icon or text style?
                        // Usually indenting the whole item is common.
                        child: MenuItemWidget(
                          menuItem: item,
                          currentPath: widget.currentPath,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
            sizeCurve: Curves.easeInOut,
            alignment: Alignment.topCenter,
          ),
        ],
      ),
    );
  }
}
