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
  final bool isCollapsed;

  const MenuGroupWidget({
    super.key,
    required this.menuGroup,
    required this.currentPath,
    this.isCollapsed = false,
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

    // Initial state setup
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
    // Removed auto-expansion logic on update to respect user's manual toggle state
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

    final isActive = isRouteActive || isExpanded;

    _updateAnimation(isExpanded);

    // If collapsed, we just show the items and maybe a divider interaction
    if (widget.isCollapsed) {
      return Column(
        children: [
          // Optional: Show a subtle divider or spacing if grouped
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Divider(height: 1),
          ),

          ...widget.menuGroup.items.map(
            (item) => MenuItemWidget(
              menuItem: item,
              currentPath: widget.currentPath,
              isCollapsed: true,
            ),
          ),
        ],
      );
    }

    // NORMAL EXPANDED BEHAVIOR

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
      padding: const EdgeInsets.symmetric(vertical: 4),
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
                    borderRadius: BorderRadius.circular(12),
                    splashColor: colorScheme.onSurface.withValues(alpha: 0.1),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ), // Adjusted padding to match Item
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
          // Items del grupo (EXPANDED)
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity, height: 0),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: widget.menuGroup.items
                    .map(
                      (item) => MenuItemWidget(
                        menuItem: item,
                        currentPath: widget.currentPath,
                        isCollapsed: false, // Explicitly false
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
