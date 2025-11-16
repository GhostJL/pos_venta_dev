import 'package:flutter/material.dart';

class DashboardCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final bool isKpi;

  const DashboardCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.onTap,
    this.color = Colors.deepPurple,
    this.isKpi = false, // Por defecto es una tarjeta de acción
  });

  @override
  State<DashboardCard> createState() => _DashboardCardState();
}

class _DashboardCardState extends State<DashboardCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onTap != null) _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onTap != null) {
      _animationController.reverse().then((_) => widget.onTap!());
    }
  }

  void _onTapCancel() {
    if (widget.onTap != null) _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: widget.isKpi ? _buildKpiLayout(textTheme) : _buildActionLayout(textTheme),
        ),
      ),
    );
  }

  Widget _buildKpiLayout(TextTheme textTheme) {
    return Row(
      children: [
        _buildIcon(),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.title,
                style: textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                widget.value,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionLayout(TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildIcon(),
        const SizedBox(height: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              widget.value,
              style: textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIcon() {
    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: widget.color.withOpacity(0.1),
      ),
      child: Icon(widget.icon, color: widget.color, size: 22),
    );
  }
}
