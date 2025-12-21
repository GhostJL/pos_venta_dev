import 'package:flutter/material.dart';

class NumericKeypad extends StatelessWidget {
  final ValueSetter<String> onKeyPress;
  final VoidCallback onDelete;
  final VoidCallback onClear;
  final VoidCallback? onEnter;

  const NumericKeypad({
    super.key,
    required this.onKeyPress,
    required this.onDelete,
    required this.onClear,
    this.onEnter,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildRow(context, ['1', '2', '3']),
        const SizedBox(height: 12),
        _buildRow(context, ['4', '5', '6']),
        const SizedBox(height: 12),
        _buildRow(context, ['7', '8', '9']),
        const SizedBox(height: 12),
        _buildRow(context, ['.', '0', 'DEL']),
      ],
    );
  }

  Widget _buildRow(BuildContext context, List<String> keys) {
    return Row(
      children: keys.map((key) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: _buildKey(context, key),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildKey(BuildContext context, String key) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isAction = key == 'DEL' || key == 'C';

    return SizedBox(
      height: 64, // Good touch target height
      child: FilledButton.tonal(
        onPressed: () {
          if (key == 'DEL') {
            onDelete();
          } else if (key == 'C') {
            onClear();
          } else {
            onKeyPress(key);
          }
        },
        style: FilledButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: isAction
              ? colorScheme.errorContainer
              : colorScheme.surfaceContainerHigh,
          foregroundColor: isAction
              ? colorScheme.onErrorContainer
              : colorScheme.onSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: isAction
            ? const Icon(Icons.backspace_outlined, size: 24)
            : Text(
                key,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
