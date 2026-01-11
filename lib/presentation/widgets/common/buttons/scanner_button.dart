import 'dart:io';
import 'package:flutter/material.dart';
import 'package:posventa/presentation/widgets/common/base/base_button.dart';

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
    if (!Platform.isAndroid && !Platform.isIOS) {
      return const SizedBox.shrink();
    }

    if (isCompact) {
      return IconButton(
        icon: const Icon(Icons.qr_code_scanner),
        onPressed: onPressed,
        tooltip: tooltip ?? 'Escanear código',
        color: Theme.of(context).colorScheme.primary,
      );
    }

    if (showLabel) {
      return BaseButton.elevated(
        icon: Icons.qr_code_scanner,
        label: 'Escanear',
        onPressed: onPressed,
        backgroundColor: Theme.of(context).colorScheme.primary,
      );
    }

    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: tooltip ?? 'Escanear código',
      backgroundColor: Theme.of(context).colorScheme.primary,
      child: const Icon(Icons.qr_code_scanner),
    );
  }
}
