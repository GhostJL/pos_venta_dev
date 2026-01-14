import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/customer.dart';
import 'package:posventa/domain/entities/customer_payment.dart';
import 'package:posventa/presentation/providers/customer_providers.dart';
import 'package:posventa/presentation/providers/debtors_provider.dart';
import 'package:posventa/presentation/providers/auth_provider.dart';
import 'package:posventa/presentation/providers/providers.dart'; // For storeRepositoryProvider
import 'package:printing/printing.dart'; // For Printer class
import 'package:posventa/presentation/providers/di/printer_di.dart';
import 'package:posventa/presentation/providers/settings_provider.dart';

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
  int? _selectedSaleId;
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

        // Validation: If Cash payment, verify active session
        int? cashSessionId;
        if (_selectedMethod == 'Efectivo') {
          final activeSession = await ref.read(
            currentCashSessionProvider.future,
          );
          if (activeSession == null) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'No hay sesión de caja abierta. Abra la caja para recibir efectivo.',
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            }
            return;
          }
          cashSessionId = activeSession.id;
        }

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
          saleId: _selectedSaleId,
          createdAt: DateTime.now(),
        );

        final paymentId = await ref
            .read(customerRepositoryProvider)
            .registerPayment(payment, cashSessionId: cashSessionId);

        // Print Receipt
        try {
          final printerService = ref.read(printerServiceProvider);
          final settings = await ref.read(settingsProvider.future);
          final printerName = settings.printerName;

          Printer? targetPrinter;
          if (printerName != null) {
            final printers = await printerService.getPrinters();
            targetPrinter = printers
                .where((p) => p.name == printerName)
                .firstOrNull;
          }

          if (targetPrinter != null || !Platform.isAndroid) {
            // Construct payment with ID
            final paymentWithId = CustomerPayment(
              id: paymentId,
              customerId: payment.customerId,
              amount: payment.amount,
              paymentMethod: payment.paymentMethod,
              reference: payment.reference,
              paymentDate: payment.paymentDate,
              processedBy: payment.processedBy,
              notes: payment.notes,
              saleId: payment.saleId,
              createdAt: payment.createdAt,
            );

            await printerService.printPaymentReceipt(
              payment: paymentWithId,
              customer: widget.customer,
              printer: targetPrinter,
            );
          }
        } catch (e) {
          debugPrint('Error printing receipt: $e');
        }

        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Abono registrado correctamente')),
          );

          // Refresh customer list to update balance
          ref.invalidate(customerProvider);
          ref.invalidate(debtorsProvider);
          ref.invalidate(customerByIdProvider(widget.customer.id!));
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
              ref
                  .watch(unpaidSalesProvider(widget.customer.id!))
                  .when(
                    data: (sales) {
                      return DropdownButtonFormField<int?>(
                        initialValue: _selectedSaleId,
                        decoration: const InputDecoration(
                          labelText: 'Asignar a Venta (Opcional)',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem<int?>(
                            value: null,
                            child: Text('Abono General'),
                          ),
                          ...sales.map(
                            (s) => DropdownMenuItem<int?>(
                              value: s.id,
                              child: Text(
                                'Venta #${s.saleNumber} - Bal: \$${s.balance.toStringAsFixed(2)}',
                              ),
                            ),
                          ),
                        ],
                        onChanged: (val) {
                          setState(() => _selectedSaleId = val);
                        },
                      );
                    },
                    loading: () => const LinearProgressIndicator(),
                    error: (err, stack) => Text('Error cargando ventas: $err'),
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
