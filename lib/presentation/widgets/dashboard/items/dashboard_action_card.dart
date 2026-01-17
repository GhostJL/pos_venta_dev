import 'package:flutter/material.dart';

class DashboardActionCard extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  final bool isTablet;

  const DashboardActionCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
    this.color,
    this.isTablet = false,
  });

  @override
  State<DashboardActionCard> createState() => _DashboardActionCardState();
}

class _DashboardActionCardState extends State<DashboardActionCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onEnter(_) {
    setState(() => _isHovered = true);
    _controller.forward();
  }

  void _onExit(_) {
    setState(() => _isHovered = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final effectiveColor = widget.color ?? colorScheme.primary;

    // Subtle gradient background
    final gradient = LinearGradient(
      colors: [
        colorScheme.surfaceContainerLow,
        Color.alphaBlend(
          effectiveColor.withAlpha(10),
          colorScheme.surfaceContainer,
        ),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return MouseRegion(
      onEnter: _onEnter,
      onExit: _onExit,
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _isHovered
                        ? effectiveColor.withAlpha(100)
                        : colorScheme.outlineVariant.withAlpha(60),
                    width: _isHovered ? 1.5 : 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _isHovered
                          ? effectiveColor.withAlpha(30)
                          : Colors.black.withAlpha(5),
                      blurRadius: _isHovered ? 12 : 4,
                      offset: Offset(0, _isHovered ? 4 : 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: widget.isTablet
                      ? _buildHorizontalLayout(
                          theme,
                          colorScheme,
                          effectiveColor,
                        )
                      : _buildVerticalLayout(
                          theme,
                          colorScheme,
                          effectiveColor,
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHorizontalLayout(
    ThemeData theme,
    ColorScheme colorScheme,
    Color color,
  ) {
    return Row(
      children: [
        _buildIcon(color),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                widget.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Icon(
          Icons.arrow_forward_rounded,
          color: _isHovered
              ? color
              : colorScheme.onSurfaceVariant.withAlpha(100),
        ),
      ],
    );
  }

  Widget _buildVerticalLayout(
    ThemeData theme,
    ColorScheme colorScheme,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIcon(color),
            Icon(
              Icons.arrow_outward_rounded,
              size: 20,
              color: _isHovered
                  ? color
                  : colorScheme.onSurfaceVariant.withAlpha(80),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
                letterSpacing: -0.3,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              widget.description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIcon(Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(widget.icon, color: color, size: 28),
    );
  }
}
