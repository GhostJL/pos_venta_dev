import 'package:flutter/material.dart';

class PaymentActionButtons extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback? onConfirm;
  final bool isLoading;
  final bool showCancel;

  const PaymentActionButtons({
    super.key,
    required this.onCancel,
    required this.onConfirm,
    this.isLoading = false,
    this.showCancel = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (showCancel) ...[
          Expanded(
            child: OutlinedButton(
              onPressed: onCancel,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Cancelar'),
            ),
          ),
          const SizedBox(width: 16),
        ],
        Expanded(
          flex: 2,
          child: FilledButton(
            onPressed: onConfirm,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              disabledBackgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest,
            ),
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Confirmar Pago',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ],
    );
  }
}
