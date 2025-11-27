import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/core/theme/theme.dart';
import 'package:posventa/core/config/menu_config.dart';
import 'package:posventa/presentation/widgets/menu/menu_item_widget.dart';
import 'package:posventa/presentation/providers/menu_state_provider.dart';

/// Widget for rendering collapsible menu groups with single-open behavior
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
  late AnimationController _animationController;
  late Animation<double> _iconRotation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _iconRotation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.menuGroup.collapsible) {
      // Non-collapsible group - just show items
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGroupHeader(),
          ...widget.menuGroup.items.map(
            (item) =>
                MenuItemWidget(menuItem: item, currentPath: widget.currentPath),
          ),
        ],
      );
    }

    // Collapsible group with Riverpod state management
    final menuState = ref.watch(menuStateProvider);
    final isExpanded = menuState.expandedGroupId == widget.menuGroup.id;

    // Sincronizar animación con el estado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        if (isExpanded &&
            _animationController.status != AnimationStatus.completed) {
          _animationController.forward();
        } else if (!isExpanded &&
            _animationController.status != AnimationStatus.dismissed) {
          _animationController.reverse();
        }
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          cursor: SystemMouseCursors.click,
          child: InkWell(
            onTap: () {
              ref
                  .read(menuStateProvider.notifier)
                  .toggleGroup(widget.menuGroup.id);
            },
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: _isHovered
                    ? AppTheme.primary.withAlpha(8)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  if (widget.menuGroup.groupIcon != null) ...[
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        widget.menuGroup.groupIcon,
                        size: _isHovered ? 20 : 18,
                        color: _isHovered
                            ? AppTheme.primary.withOpacity(0.8)
                            : AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        color: _isHovered
                            ? AppTheme.primary.withOpacity(0.8)
                            : AppTheme.textSecondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        letterSpacing: 1.2,
                      ),
                      child: Text(widget.menuGroup.title.toUpperCase()),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: RotationTransition(
                      turns: _iconRotation,
                      child: Icon(
                        Icons.expand_more,
                        size: 20,
                        color: _isHovered
                            ? AppTheme.primary.withOpacity(0.8)
                            : AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          child: isExpanded
              ? Column(
                  children: widget.menuGroup.items
                      .map(
                        (item) => MenuItemWidget(
                          menuItem: item,
                          currentPath: widget.currentPath,
                        ),
                      )
                      .toList(),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildGroupHeader() {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 8, top: 4),
      child: Row(
        children: [
          if (widget.menuGroup.groupIcon != null) ...[
            Icon(
              widget.menuGroup.groupIcon,
              size: 16,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(width: 8),
          ],
          Text(
            widget.menuGroup.title.toUpperCase(),
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.bold,
              fontSize: 11,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
