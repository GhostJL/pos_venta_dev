import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    final isExpanded = ref.watch(
      menuStateProvider.select(
        (state) => state.expandedGroupId == widget.menuGroup.id,
      ),
    );

    _updateAnimation(isExpanded);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header del grupo
          MouseRegion(
            onEnter: (_) => setState(() => _isHovered = true),
            onExit: (_) => setState(() => _isHovered = false),
            cursor: SystemMouseCursors.click,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 48,
                decoration: BoxDecoration(
                  color: isExpanded
                      ? colorScheme.surfaceContainer
                      : _isHovered
                      ? colorScheme.onSurface.withValues(alpha: 0.05)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      ref
                          .read(menuStateProvider.notifier)
                          .toggleGroup(widget.menuGroup.id);
                    },
                    borderRadius: BorderRadius.circular(24),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          if (widget.menuGroup.groupIcon != null) ...[
                            Icon(
                              widget.menuGroup.groupIcon,
                              size: 24,
                              color: isExpanded
                                  ? colorScheme.primary
                                  : colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 12),
                          ],
                          Expanded(
                            child: Text(
                              widget.menuGroup.title,
                              style: textTheme.titleSmall?.copyWith(
                                color: isExpanded
                                    ? colorScheme.onSurface
                                    : colorScheme.onSurface,
                                fontWeight: isExpanded
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                letterSpacing: 0.1,
                              ),
                            ),
                          ),
                          Icon(
                            isExpanded
                                ? Icons.expand_less_rounded
                                : Icons.expand_more_rounded,
                            size: 24,
                            color: isExpanded
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant,
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
              padding: const EdgeInsets.only(top: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: widget.menuGroup.items
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(left: 12),
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
