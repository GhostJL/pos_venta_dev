import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/presentation/providers/pos_providers.dart';
import 'package:posventa/presentation/widgets/pos/payment/widgets/payment_action_buttons.dart';
import 'package:posventa/presentation/widgets/pos/payment/widgets/payment_amount_input.dart';
import 'package:posventa/presentation/widgets/pos/payment/widgets/payment_change_display.dart';
import 'package:posventa/presentation/widgets/pos/payment/widgets/payment_header.dart';
import 'package:posventa/presentation/widgets/pos/payment/widgets/payment_method_selector.dart';
import 'package:posventa/presentation/widgets/pos/payment/widgets/payment_summary_card.dart';

class PaymentDialog extends ConsumerStatefulWidget {
  const PaymentDialog({super.key});

  @override
  ConsumerState<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends ConsumerState<PaymentDialog> {
  String _selectedPaymentMethod = 'Efectivo';
  final TextEditingController _amountController = TextEditingController();
  double _change = 0.0;

  @override
  void initState() {
    super.initState();
    // Defer the state read to the next frame to avoid build phase issues if any
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
        const SnackBar(
          content: Text('El monto recibido es insuficiente'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    ref
        .read(pOSProvider.notifier)
        .completeSale(_selectedPaymentMethod, amountPaid);
  }

  @override
  Widget build(BuildContext context) {
    final posState = ref.watch(pOSProvider);
    final isMobile = MediaQuery.of(context).size.width < 600;

    ref.listen(pOSProvider, (previous, next) {
      if (next.successMessage != null && next.successMessage!.isNotEmpty) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.successMessage!),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      if (next.errorMessage != null && next.errorMessage!.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: isMobile ? double.infinity : 450,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PaymentHeader(onClose: () => Navigator.of(context).pop()),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    PaymentSummaryCard(
                      subtotal: posState.subtotal,
                      tax: posState.tax,
                      total: posState.total,
                    ),
                    const SizedBox(height: 24),
                    PaymentMethodSelector(
                      selectedMethod: _selectedPaymentMethod,
                      onMethodChanged: (value) {
                        setState(() {
                          _selectedPaymentMethod = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    PaymentAmountInput(
                      controller: _amountController,
                      onChanged: (value) => _calculateChange(posState.total),
                    ),
                    const SizedBox(height: 20),
                    PaymentChangeDisplay(change: _change),
                  ],
                ),
              ),
            ),
            PaymentActionButtons(
              onCancel: () => Navigator.of(context).pop(),
              onConfirm: posState.isLoading || _change < 0
                  ? null
                  : () => _handleConfirmPayment(posState.total),
              isLoading: posState.isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
