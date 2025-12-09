import 'package:flutter/material.dart';
import 'package:posventa/core/theme/theme.dart';

class CashSessionCloseSummaryDialog extends StatelessWidget {
  final dynamic
  session; // Using dynamic to match original code, but ideally should be a typed model

  const CashSessionCloseSummaryDialog({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final openingBalance = session.openingBalanceCents / 100;
    final expectedBalance = (session.expectedBalanceCents ?? 0) / 100;
    final closingBalance = (session.closingBalanceCents ?? 0) / 100;
    final difference = (session.differenceCents ?? 0) / 100;
    final isBalanced = difference.abs() < 0.01; // Tolerancia de 1 centavo

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(
            isBalanced ? Icons.check_circle : Icons.warning,
            color: isBalanced
                ? AppTheme.transactionSuccess
                : AppTheme.transactionPending,
            size: 32,
          ),
          const SizedBox(width: 12),
          const Expanded(child: Text('Resumen de Cierre de Caja')),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSummaryRow('Fondo Inicial:', openingBalance),
          const Divider(height: 24),
          _buildSummaryRow('Efectivo Esperado:', expectedBalance, isBold: true),
          const SizedBox(height: 8),
          _buildSummaryRow('Efectivo Contado:', closingBalance, isBold: true),
          const Divider(height: 24),
          _buildSummaryRow(
            'Diferencia:',
            difference,
            isBold: true,
            color: difference == 0
                ? AppTheme.transactionSuccess
                : (difference > 0 ? Colors.blue : AppTheme.transactionFailed),
          ),
          if (!isBalanced) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: difference > 0
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    difference > 0 ? Icons.arrow_upward : Icons.arrow_downward,
                    color: difference > 0
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      difference > 0
                          ? 'Sobrante de efectivo'
                          : 'Faltante de efectivo',
                      style: TextStyle(
                        color: difference > 0
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('ACEPTAR'),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(
    String label,
    double amount, {
    bool isBold = false,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.bold,
          ),
        ),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: isBold ? 18 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: color,
          ),
        ),
      ],
    );
  }
}
