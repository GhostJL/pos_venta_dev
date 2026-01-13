import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/customer.dart';
import 'package:posventa/domain/entities/customer_payment.dart';
import 'package:posventa/presentation/providers/customer_providers.dart';
import 'package:posventa/presentation/providers/debtors_provider.dart';
import 'package:posventa/presentation/providers/di/customer_di.dart';
import 'package:posventa/presentation/providers/auth_provider.dart';

class CustomerPaymentDialog extends ConsumerStatefulWidget {
  final Customer customer;

  const CustomerPaymentDialog({super.key, required this.customer});

  @override
  ConsumerState<CustomerPaymentDialog> createState() =>
      _CustomerPaymentDialogState();
}

class _CustomerPaymentDialogState extends ConsumerState<CustomerPaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  String _selectedMethod = 'Efectivo';
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final amount = double.parse(_amountController.text);
        final user = ref.read(authProvider).user;

        final payment = CustomerPayment(
          customerId: widget.customer.id!,
          amount: amount,
          paymentMethod: _selectedMethod,
          paymentDate: DateTime.now(),
          processedBy:
              user?.id ??
              1, // Fallback to 1 if no user (should not happen in real app)
          notes: _notesController.text,
          createdAt: DateTime.now(),
        );

        await ref.read(customerRepositoryProvider).registerPayment(payment);

        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Abono registrado correctamente')),
          );
          // Refresh customer list to update balance
          ref.invalidate(customerProvider);
          ref.invalidate(debtorsProvider);
          ref.invalidate(customerByIdProvider(widget.customer.id!));
          // Assuming we have a provider for transactions, invalidate it too if it exists
          // ref.invalidate(customerTransactionsProvider(widget.customer.id!));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al registrar abono: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Abonar a: ${widget.customer.firstName}'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Deuda Actual: \$${widget.customer.creditUsed.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Monto a Abonar',
                  prefixText: '\$ ',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese un monto';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Monto inválido';
                  }
                  if (amount > widget.customer.creditUsed) {
                    return 'El monto no puede ser mayor a la deuda';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedMethod,
                decoration: const InputDecoration(
                  labelText: 'Método de Pago',
                  border: OutlineInputBorder(),
                ),
                items: ['Efectivo', 'Transferencia', 'Tarjeta']
                    .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedMethod = val);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notas (Opcional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? _submit : _submit,
          child: _isLoading
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Registrar Abono'),
        ),
      ],
    );
  }
}
