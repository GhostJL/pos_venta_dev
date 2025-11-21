import 'package:flutter/material.dart';
import 'package:posventa/app/theme.dart';

class ScannerButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String? tooltip;
  final bool isCompact;
  final bool showLabel;

  const ScannerButton({
    super.key,
    required this.onPressed,
    this.tooltip,
    this.isCompact = false,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return IconButton(
        icon: const Icon(Icons.qr_code_scanner),
        onPressed: onPressed,
        tooltip: tooltip ?? 'Escanear código',
        color: AppTheme.primary,
      );
    }

    if (showLabel) {
      return ElevatedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.qr_code_scanner, size: 20),
        label: const Text('Escanear'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }

    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: tooltip ?? 'Escanear código',
      backgroundColor: AppTheme.primary,
      child: const Icon(Icons.qr_code_scanner),
    );
  }
}
