import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/presentation/providers/pos_providers.dart';
import 'package:posventa/presentation/widgets/pos/payment/widgets/payment_action_buttons.dart';
import 'package:posventa/presentation/widgets/pos/payment/widgets/payment_amount_input.dart';
import 'package:posventa/presentation/widgets/pos/payment/widgets/payment_change_display.dart';
import 'package:posventa/presentation/widgets/pos/payment/widgets/payment_summary_card.dart';
import 'package:posventa/core/theme/theme.dart';
import 'package:go_router/go_router.dart';

class PaymentPage extends ConsumerStatefulWidget {
  const PaymentPage({super.key});

  @override
  ConsumerState<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends ConsumerState<PaymentPage> {
  String _selectedPaymentMethod = 'Efectivo';
  final TextEditingController _amountController = TextEditingController();
  double _change = 0.0;

  final List<double> _frequentValues = [20, 50, 100, 200, 500];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final total = ref.read(pOSProvider).total;
      _amountController.text = total.toStringAsFixed(2);
      _calculateChange(total);
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _calculateChange(double total) {
    final amountPaid = double.tryParse(_amountController.text) ?? 0.0;
    setState(() {
      _change = amountPaid - total;
    });
  }

  void _handleConfirmPayment(double total) {
    final amountPaid = double.tryParse(_amountController.text) ?? 0.0;
    if (amountPaid < total) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('El monto recibido es insuficiente'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    ref
        .read(pOSProvider.notifier)
        .completeSale(_selectedPaymentMethod, amountPaid);
  }

  void _setFrequentValue(double value, double total) {
    _amountController.text = value.toStringAsFixed(2);
    _calculateChange(total);
  }

  @override
  Widget build(BuildContext context) {
    final posState = ref.watch(pOSProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    ref.listen(pOSProvider, (previous, next) {
      if (next.successMessage != null && next.successMessage!.isNotEmpty) {
        context.go('/sales'); // go back to POS
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.successMessage!),
            backgroundColor: AppTheme.transactionSuccess,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      if (next.errorMessage != null && next.errorMessage!.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: theme.colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLow,
      appBar: AppBar(
        title: Text(
          'Procesar Pago',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PaymentSummaryCard(
                    subtotal: posState.subtotal,
                    tax: posState.tax,
                    total: posState.total,
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Método de Pago',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // More prominent method selection
                  Row(
                    children: [
                      Expanded(
                        child: _buildMethodButton(
                          context,
                          'Efectivo',
                          Icons.payments_outlined,
                          _selectedPaymentMethod == 'Efectivo',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMethodButton(
                          context,
                          'Tarjeta',
                          Icons.credit_card_outlined,
                          _selectedPaymentMethod == 'Tarjeta',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMethodButton(
                          context,
                          'Transf.',
                          Icons.account_balance_wallet_outlined,
                          _selectedPaymentMethod == 'Transferencia',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  PaymentAmountInput(
                    controller: _amountController,
                    onChanged: (value) => _calculateChange(posState.total),
                  ),
                  PaymentChangeDisplay(change: _change),
                  // Frequent values in a container
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colorScheme.outlineVariant),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cambios rápidos',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _frequentValues.map((value) {
                            return ActionChip(
                              label: Text('\$${value.toInt()}'),
                              onPressed: () =>
                                  _setFrequentValue(value, posState.total),
                              backgroundColor: colorScheme.primaryContainer,
                              side: BorderSide.none,
                              labelStyle: TextStyle(
                                color: colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.05),
                  offset: const Offset(0, -4),
                  blurRadius: 16,
                ),
              ],
            ),
            child: PaymentActionButtons(
              onCancel: () => context.pop(),
              onConfirm: posState.isLoading || _change < 0
                  ? null
                  : () => _handleConfirmPayment(posState.total),
              isLoading: posState.isLoading,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodButton(
    BuildContext context,
    String method,
    IconData icon,
    bool isSelected,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => setState(() => _selectedPaymentMethod = method),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outlineVariant,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? colorScheme.onPrimary : colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              method,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
