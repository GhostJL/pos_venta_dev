import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class QuickActionWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback? onAdd;
  final VoidCallback? onRemove;
  final VoidCallback? onDelete;
  final FocusNode? focusNode;

  const QuickActionWrapper({
    super.key,
    required this.child,
    this.onAdd,
    this.onRemove,
    this.onDelete,
    this.focusNode,
  });

  @override
  State<QuickActionWrapper> createState() => _QuickActionWrapperState();
}

class _QuickActionWrapperState extends State<QuickActionWrapper> {
  late FocusNode _node;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _node = widget.focusNode ?? FocusNode();
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _node.dispose();
    }
    super.dispose();
  }

  void _handleHover(bool isHovering) {
    if (isHovering != _isHovering) {
      setState(() => _isHovering = isHovering);
      if (isHovering) {
        _node.requestFocus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _handleHover(true),
      onExit: (_) => _handleHover(false),
      child: CallbackShortcuts(
        bindings: {
          // Add Action (+ and Numpad +)
          if (widget.onAdd != null) ...{
            const SingleActivator(LogicalKeyboardKey.add): widget.onAdd!,
            const SingleActivator(LogicalKeyboardKey.numpadAdd): widget.onAdd!,
            const SingleActivator(LogicalKeyboardKey.equal, shift: true):
                widget.onAdd!, // Standard '+' (Shift + =)
          },
          // Remove Action (- and Numpad -)
          if (widget.onRemove != null) ...{
            const SingleActivator(LogicalKeyboardKey.minus): widget.onRemove!,
            const SingleActivator(LogicalKeyboardKey.numpadSubtract):
                widget.onRemove!,
          },
          // Delete Action (Delete)
          if (widget.onDelete != null) ...{
            const SingleActivator(LogicalKeyboardKey.delete): widget.onDelete!,
          },
        },
        child: Focus(focusNode: _node, child: widget.child),
      ),
    );
  }
}
