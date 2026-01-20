import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A wrapper that adds keyboard navigation capabilities to a grid of products.
/// Handles arrow key navigation, Tab navigation, and action shortcuts (Enter, Space).
class FocusableProductGrid extends StatefulWidget {
  final Widget Function(int index, bool isFocused) itemBuilder;
  final int itemCount;
  final int crossAxisCount;
  final VoidCallback? onFocusLost;
  final Function(int index)? onItemSelected;
  final FocusNode? focusNode;

  const FocusableProductGrid({
    super.key,
    required this.itemBuilder,
    required this.itemCount,
    required this.crossAxisCount,
    this.onFocusLost,
    this.onItemSelected,
    this.focusNode,
  });

  @override
  State<FocusableProductGrid> createState() => _FocusableProductGridState();
}

class _FocusableProductGridState extends State<FocusableProductGrid> {
  late FocusNode _focusNode;
  int _focusedIndex = 0;
  final GlobalKey _gridKey = GlobalKey();

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

  void _handleFocusChange() {
    if (!_focusNode.hasFocus && widget.onFocusLost != null) {
      widget.onFocusLost!();
    }
  }

  void _moveFocus(int delta) {
    setState(() {
      _focusedIndex = (_focusedIndex + delta).clamp(0, widget.itemCount - 1);
      _ensureVisible();
    });
  }

  void _moveFocusVertical(int rowDelta) {
    setState(() {
      final newIndex = _focusedIndex + (rowDelta * widget.crossAxisCount);
      _focusedIndex = newIndex.clamp(0, widget.itemCount - 1);
      _ensureVisible();
    });
  }

  void _moveFocusHorizontal(int colDelta) {
    setState(() {
      final currentRow = _focusedIndex ~/ widget.crossAxisCount;
      final currentCol = _focusedIndex % widget.crossAxisCount;
      final newCol = (currentCol + colDelta).clamp(
        0,
        widget.crossAxisCount - 1,
      );
      final newIndex = (currentRow * widget.crossAxisCount) + newCol;
      _focusedIndex = newIndex.clamp(0, widget.itemCount - 1);
      _ensureVisible();
    });
  }

  void _ensureVisible() {
    // Trigger a rebuild to ensure the focused item is visible
    // The actual scrolling will be handled by the parent ScrollView
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Find the context of the grid
        final context = _gridKey.currentContext;
        if (context != null) {
          // Request focus to ensure keyboard events are captured
          _focusNode.requestFocus();
        }
      }
    });
  }

  void _selectCurrentItem() {
    if (widget.onItemSelected != null && _focusedIndex < widget.itemCount) {
      widget.onItemSelected!(_focusedIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        // Arrow navigation
        const SingleActivator(LogicalKeyboardKey.arrowUp): () =>
            _moveFocusVertical(-1),
        const SingleActivator(LogicalKeyboardKey.arrowDown): () =>
            _moveFocusVertical(1),
        const SingleActivator(LogicalKeyboardKey.arrowLeft): () =>
            _moveFocusHorizontal(-1),
        const SingleActivator(LogicalKeyboardKey.arrowRight): () =>
            _moveFocusHorizontal(1),

        // Tab navigation
        const SingleActivator(LogicalKeyboardKey.tab): () => _moveFocus(1),
        const SingleActivator(LogicalKeyboardKey.tab, shift: true): () =>
            _moveFocus(-1),

        // Selection
        const SingleActivator(LogicalKeyboardKey.enter): _selectCurrentItem,
        const SingleActivator(LogicalKeyboardKey.space): _selectCurrentItem,
      },
      child: Focus(
        focusNode: _focusNode,
        child: Builder(
          key: _gridKey,
          builder: (context) {
            return Column(
              children: List.generate(
                widget.itemCount,
                (index) => widget.itemBuilder(index, index == _focusedIndex),
              ),
            );
          },
        ),
      ),
    );
  }
}
