import 'package:flutter/material.dart';
import 'package:posventa/presentation/widgets/common/money_input_field.dart';
import 'package:posventa/presentation/widgets/common/error_message_box.dart';

class CashSessionCloseForm extends StatefulWidget {
  final Future<void> Function(double amount) onCloseSession;
  final bool isLoading;
  final String? errorMessage;

  const CashSessionCloseForm({
    super.key,
    required this.onCloseSession,
    this.isLoading = false,
    this.errorMessage,
  });

  @override
  State<CashSessionCloseForm> createState() => _CashSessionCloseFormState();
}

class _CashSessionCloseFormState extends State<CashSessionCloseForm> {
  final TextEditingController _amountController = TextEditingController();
  String? _localErrorMessage;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CashSessionCloseForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.errorMessage != oldWidget.errorMessage) {
      setState(() {
        _localErrorMessage = widget.errorMessage;
      });
    }
  }

  Future<void> _handleSubmit() async {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      setState(() {
        _localErrorMessage = 'Debe ingresar el efectivo contado';
      });
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount < 0) {
      setState(() {
        _localErrorMessage = 'El monto debe ser un número válido y no negativo';
      });
      return;
    }

    setState(() {
      _localErrorMessage = null;
    });

    await widget.onCloseSession(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MoneyInputField(
          controller: _amountController,
          label: 'Conteo de Efectivo',
          helpText: 'Ingrese el total de efectivo contado en caja',
          autofocus: true,
        ),
        const SizedBox(height: 24),
        if (_localErrorMessage != null) ...[
          ErrorMessageBox(message: _localErrorMessage!),
          const SizedBox(height: 16),
        ],
        SizedBox(
          height: 50,
          child: ElevatedButton(
            onPressed: widget.isLoading ? null : _handleSubmit,

            child: widget.isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  )
                : const Text('CERRAR CAJA'),
          ),
        ),
      ],
    );
  }
}
