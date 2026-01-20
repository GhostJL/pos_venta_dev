import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A wrapper that adds keyboard navigation capabilities to a cart items list.
/// Handles arrow key navigation and action shortcuts (+, -, Delete).
class FocusableCartList extends StatefulWidget {
  final Widget Function(int index, bool isFocused) itemBuilder;
  final int itemCount;
  final VoidCallback? onFocusLost;
  final Function(int index)? onIncrement;
  final Function(int index)? onDecrement;
  final Function(int index)? onDelete;
  final FocusNode? focusNode;

  const FocusableCartList({
    super.key,
    required this.itemBuilder,
    required this.itemCount,
    this.onFocusLost,
    this.onIncrement,
    this.onDecrement,
    this.onDelete,
    this.focusNode,
  });

  @override
  State<FocusableCartList> createState() => _FocusableCartListState();
}

class _FocusableCartListState extends State<FocusableCartList> {
  late FocusNode _focusNode;
  int _focusedIndex = 0;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(FocusableCartList oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Adjust focused index if items were removed
    if (widget.itemCount < oldWidget.itemCount) {
      setState(() {
        _focusedIndex = _focusedIndex.clamp(0, widget.itemCount - 1);
      });
    }
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus && widget.onFocusLost != null) {
      widget.onFocusLost!();
    }
  }

  void _moveFocus(int delta) {
    if (widget.itemCount == 0) return;

    setState(() {
      _focusedIndex = (_focusedIndex + delta).clamp(0, widget.itemCount - 1);
    });
  }

  void _incrementCurrentItem() {
    if (widget.onIncrement != null && _focusedIndex < widget.itemCount) {
      widget.onIncrement!(_focusedIndex);
    }
  }

  void _decrementCurrentItem() {
    if (widget.onDecrement != null && _focusedIndex < widget.itemCount) {
      widget.onDecrement!(_focusedIndex);
    }
  }

  void _deleteCurrentItem() {
    if (widget.onDelete != null && _focusedIndex < widget.itemCount) {
      widget.onDelete!(_focusedIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.itemCount == 0) {
      return Focus(focusNode: _focusNode, child: const SizedBox.shrink());
    }

    return CallbackShortcuts(
      bindings: {
        // Arrow navigation
        const SingleActivator(LogicalKeyboardKey.arrowUp): () => _moveFocus(-1),
        const SingleActivator(LogicalKeyboardKey.arrowDown): () =>
            _moveFocus(1),

        // Quantity adjustments
        const SingleActivator(LogicalKeyboardKey.add): _incrementCurrentItem,
        const SingleActivator(LogicalKeyboardKey.numpadAdd):
            _incrementCurrentItem,
        const SingleActivator(LogicalKeyboardKey.equal, shift: true):
            _incrementCurrentItem, // Standard '+' (Shift + =)

        const SingleActivator(LogicalKeyboardKey.minus): _decrementCurrentItem,
        const SingleActivator(LogicalKeyboardKey.numpadSubtract):
            _decrementCurrentItem,

        // Delete item
        const SingleActivator(LogicalKeyboardKey.delete): _deleteCurrentItem,
      },
      child: Focus(
        focusNode: _focusNode,
        child: Column(
          children: List.generate(
            widget.itemCount,
            (index) => widget.itemBuilder(index, index == _focusedIndex),
          ),
        ),
      ),
    );
  }
}
