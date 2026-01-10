import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/cash_movement.dart';
import 'package:posventa/presentation/providers/di/sale_di.dart';

class CashMovementDialog extends ConsumerStatefulWidget {
  final int sessionId;
  final String movementType; // 'entry' or 'withdrawal'
  final int userId;

  const CashMovementDialog({
    super.key,
    required this.sessionId,
    required this.movementType,
    required this.userId,
  });

  @override
  ConsumerState<CashMovementDialog> createState() => _CashMovementDialogState();
}

class _CashMovementDialogState extends ConsumerState<CashMovementDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedReason;
  bool _isLoading = false;

  late final List<String> _reasons;

  @override
  void initState() {
    super.initState();
    _reasons = widget.movementType == 'entry'
        ? ['Ingreso de Efectivo', 'Cambio Inicial', 'Otro']
        : ['Retiro de Efectivo', 'Gasto', 'Pago a Proveedor', 'Otro'];
    _selectedReason = _reasons.first;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final amount = double.tryParse(_amountController.text) ?? 0;
      final amountCents = (amount * 100).round();

      final movement = CashMovement(
        cashSessionId: widget.sessionId,
        movementType: widget.movementType,
        amountCents: amountCents,
        reason: _selectedReason!,
        description: _descriptionController.text.trim(),
        performedBy: widget.userId,
        movementDate: DateTime.now(),
      );

      final repo = ref.read(cashSessionRepositoryProvider);
      await repo.addCashMovement(movement);

      // Refresh session details
      ref.invalidate(currentCashSessionProvider);

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.movementType == 'entry'
                  ? 'Ingreso registrado correctamente'
                  : 'Retiro registrado correctamente',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al registrar movimiento: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEntry = widget.movementType == 'entry';
    final color = isEntry ? Colors.green : Colors.orange;
    final title = isEntry ? 'Ingreso de Dinero' : 'Retiro de Efectivo';
    final icon = isEntry
        ? Icons.add_circle_outline
        : Icons.remove_circle_outline;

    return AlertDialog(
      title: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Text(title),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Monto',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Requerido';
                  final v = double.tryParse(value);
                  if (v == null || v <= 0) return 'Monto inválido';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedReason,
                decoration: const InputDecoration(
                  labelText: 'Motivo',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: _reasons.map((r) {
                  return DropdownMenuItem(value: r, child: Text(r));
                }).toList(),
                onChanged: (v) => setState(() => _selectedReason = v),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Descripción (Opcional)',
                  prefixIcon: Icon(Icons.description_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton.icon(
          onPressed: _isLoading ? null : _submit,
          style: FilledButton.styleFrom(backgroundColor: color),
          icon: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.check),
          label: Text(isEntry ? 'Registrar Ingreso' : 'Registrar Retiro'),
        ),
      ],
    );
  }
}
