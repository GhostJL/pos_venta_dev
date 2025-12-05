import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

class QuickActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const QuickActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<QuickActionButton> createState() => _QuickActionButtonState();
}

class _QuickActionButtonState extends State<QuickActionButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: ZoomIn(
        duration: const Duration(milliseconds: 200),
        from: _isHovered ? 1.0 : 1.05,
        animate: true,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: widget.color.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.color.withAlpha(_isHovered ? 100 : 50),
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Icon(widget.icon, color: widget.color, size: 24),
                const SizedBox(height: 4),
                Text(
                  widget.label,
                  style: TextStyle(
                    color: widget.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
